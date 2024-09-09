# This is a sample commands.py.  You can add your own commands here.
#
# Please refer to commands_full.py for all the default commands and a complete
# documentation.  Do NOT add them all here, or you may end up with defunct
# commands when upgrading ranger.

# A simple command for demonstration purposes follows.
# -----------------------------------------------------------------------------

from __future__ import (absolute_import, division, print_function)

# You can import any python module as needed.
# import os

# You always need to import ranger.api.commands here to get the Command class:
from ranger.api.commands import Command

# class bulkrename(Command):
#     """:bulkrename
#
#     This command opens a list of selected files in an external editor.
#     After you edit and save the file, it will generate a shell script
#     which does bulk renaming according to the changes you did in the file.
#
#     This shell script is opened in an editor for you to review.
#     After you close it, it will be executed.
#     """
#
#     def execute(self):
#         # pylint: disable=too-many-locals,too-many-statements,too-many-branches
#         import sys
#         import tempfile
#         from ranger.container.file import File
#         from ranger.ext.shell_escape import shell_escape as esc
#         py3 = sys.version_info[0] >= 3
#
#         # Create and edit the file list
#         filenames = [f.relative_path for f in self.fm.thistab.get_selection()]
#         with tempfile.NamedTemporaryFile(delete=False) as listfile:
#             listpath = listfile.name
#             if py3:
#                 listfile.write("\n".join(filenames).encode(
#                     encoding="utf-8", errors="surrogateescape"))
#             else:
#                 listfile.write("\n".join(filenames))
#         try:
#             self.fm.execute_file([File(listpath)], app='editor')
#         except Exception:
#             pass
#
#         with (open(listpath, 'r', encoding="utf-8", errors="surrogateescape") if
#               py3 else open(listpath, 'r')) as listfile:
#             new_filenames = listfile.read().split("\n")
#         os.unlink(listpath)
#         if all(a == b for a, b in zip(filenames, new_filenames)):
#             self.fm.notify("No renaming to be done!")
#             return
#
#         # Generate script
#         with tempfile.NamedTemporaryFile() as cmdfile:
#             script_lines = []
#             script_lines.append("# This file will be executed when you close"
#                                 " the editor.")
#             script_lines.append("# Please double-check everything, clear the"
#                                 " file to abort.")
#             new_dirs = []
#             for old, new in zip(filenames, new_filenames):
#                 if old != new:
#                     basepath, _ = os.path.split(new)
#                     if (basepath and basepath not in new_dirs
#                             and not os.path.isdir(basepath)):
#                         script_lines.append("mkdir -vp -- {dir}".format(
#                             dir=esc(basepath)))
#                         new_dirs.append(basepath)
#                     script_lines.append("mv -vi -- {old} {new}".format(
#                         old=esc(old), new=esc(new)))
#             # Make sure not to forget the ending newline
#             script_content = "\n".join(script_lines) + "\n"
#             if py3:
#                 cmdfile.write(script_content.encode(encoding="utf-8",
#                                                     errors="surrogateescape"))
#             else:
#                 cmdfile.write(script_content)
#             cmdfile.flush()
#
#             # Open the script and let the user review it, then check if the
#             # script was modified by the user
#             try:
#                 self.fm.execute_file([File(cmdfile.name)], app='editor')
#             except Exception:
#                 pass
#             cmdfile.seek(0)
#             script_was_edited = (script_content != cmdfile.read())
#
#             # Do the renaming
#             self.fm.run(['/bin/sh', cmdfile.name], flags='w')
#
#         # Retag the files, but only if the script wasn't changed during review,
#         # because only then we know which are the source and destination files.
#         if not script_was_edited:
#             tags_changed = False
#             for old, new in zip(filenames, new_filenames):
#                 if old != new:
#                     oldpath = self.fm.thisdir.path + '/' + old
#                     newpath = self.fm.thisdir.path + '/' + new
#                     if oldpath in self.fm.tags:
#                         old_tag = self.fm.tags.tags[oldpath]
#                         self.fm.tags.remove(oldpath)
#                         self.fm.tags.tags[newpath] = old_tag
#                         tags_changed = True
#             if tags_changed:
#                 self.fm.tags.dump()
#         else:
#             fm.notify("files have not been retagged")


class fzf_select(Command):
    """
    :fzf_select
    Find a file using fzf.
    With a prefix argument to select only directories.

    See: https://github.com/junegunn/fzf
    """

    def execute(self):
        import subprocess
        import os
        from ranger.ext.get_executables import get_executables

        if 'fzf' not in get_executables():
            self.fm.notify('Could not find fzf in the PATH.', bad=True)
            return

        fd = None
        if 'fdfind' in get_executables():
            fd = 'fdfind'
        elif 'fd' in get_executables():
            fd = 'fd'

        if fd is not None:
            hidden = ('--hidden' if self.fm.settings.show_hidden else '')
            exclude = "--no-ignore-vcs --exclude '.git' --exclude '*.py[co]' --exclude '__pycache__'"
            only_directories = '--type directory'
            fzf_default_command = '{} --follow {} {} {} --color=always'.format(
                fd, hidden, exclude, only_directories
            )
        else:
            hidden = ('-false' if self.fm.settings.show_hidden else r"-path '*/\.*' -prune")
            exclude = r"\( -name '\.git' -o -iname '\.*py[co]' -o -fstype 'dev' -o -fstype 'proc' \) -prune"
            only_directories = '-type d'
            fzf_default_command = 'find -L . -mindepth 1 {} -o {} -o {} -print | cut -b3-'.format(
                hidden, exclude, only_directories
            )

        env = os.environ.copy()
        env['FZF_DEFAULT_COMMAND'] = fzf_default_command
        env['FZF_DEFAULT_OPTS'] = '--height=40% --layout=reverse --ansi --preview="{}"'.format('''
            (
                batcat --color=always {} ||
                bat --color=always {} ||
                cat {} ||
                tree -ahpCL 3 -I '.git' -I '*.py[co]' -I '__pycache__' {}
            ) 2>/dev/null | head -n 100
        ''')

        fzf = self.fm.execute_command('fzf --no-multi', env=env,
                                      universal_newlines=True, stdout=subprocess.PIPE)
        stdout, _ = fzf.communicate()
        if fzf.returncode == 0:
            selected = os.path.abspath(stdout.strip())
            if os.path.isdir(selected):
                self.fm.cd(selected)
            else:
                self.fm.select_file(selected)
