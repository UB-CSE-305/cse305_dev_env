#set page(numbering: "1")
#set heading(numbering: "1.")

#let CodeBloc(content) = block(
  fill: luma(240),
  inset: 1em,
  radius: 0.5em,
  width: 100%,
  content,
)

#show raw.where(block: true): CodeBloc
#show link: it => underline(text(fill: blue)[#it])
#show ref: it => text(fill: blue)[#it]

#align(center)[
  #text(size: 1.8em, weight: "bold")[OCaml Environment Setup]

  CSE 305 Introduction to Programming Languages

  Spring 2026

  Last update: #datetime.today().display("[month]-[day]-[year]")
]

= Introduction
<Intro>
This document has a lot of information in it, we recommend you read
through it before actually doing anything. The order of operations is
very important for setting up your environment, and the order of
sections in this document is intentional.

We will cover installation instructions for different platforms in
different sections. Linux and macOS users should read
@MacLinuxInstall, and Windows users should read
@DockerSetup.

#pagebreak()
= Installing OCaml on Linux/macOS
<MacLinuxInstall>
== macOS: Install package manager Homebrew
<macos-install-package-manager-homebrew>
Homebrew is the most popular "unofficial" package manager for macOS. If
you don't have it installed already, you should click on the
#link("https://brew.sh/")[Homebrew website], copy the install script and
run it in `Terminal.app` or any terminal emulator you have.

Close and reopen your terminal after the installation is complete.

== Install `opam`
<install-opam>
For macOS / Linux users, open any terminal emulator you have, and use
your package manager to install `opam`.

macOS:

```bash
$ brew install opam
```

Debian/Ubuntu:

```bash
$ sudo apt update & sudo apt upgrade -y
$ sudo apt install -y opam
```

When the installation is complete, run the following command in your
terminal:

```bash
$ opam init -a
$ opam switch create cse305_4.14.2 ocaml-base-compiler.4.14.2 && opam switch cse305_4.14.2
```

When the installation is complete, restart your machine and open a new
terminal. Verify that the installation was successful by running
`which ocaml` in your terminal, it should look like this:

```bash
$ which ocaml
<your_home_dir>/.opam/default/bin/ocaml
```

If the terminal says `ocaml: command not found`, it means there's
something wrong with the initialization of `opam`. Try to redo the steps
and come to the office hours if the problem persists.

If the terminal says `/usr/bin/ocaml` or anything else not related to
`.opam`, it means the system OCaml installation is being used instead of
the one installed by `opam`. You may need to restart your machine to
make sure the system is reading the updated `.profile`.

If `which ocaml` prompt the path successfully, in your terminal run:

```bash
$ opam install -y ocaml-lsp-server ocamlformat utop ounit2
```

== Setting up text editor
<TextEditorSetup>
You can use whatever editor you are comfortable with. However, we found
Visual Studio Code (VS Code) to be the easiest editor to set up for use with OCaml.
#link("https://marketplace.visualstudio.com/items?itemName=ocamllabs.ocaml-platform")[OCaml Platform]
is an extension we recommend for syntax highlighting and code auto
completion. The extension can be found in the VS Code Extension Store.

For macOS/Linux users, choose `cse305_4.14.2` when VS Code asks for
sandbox configuration. This should enable syntax highlighting and
autocomplete. Proceed to @TestEnv to test your environment.

#pagebreak()
= Using provided Docker images on Windows
<DockerSetup>
Setup for Windows is a little more complicated than other platforms, so
we provide a Docker image with all necessary tools, Emacs development
environment is also pre-installed. We recommend using Visual Studio Code
(VS Code) or Emacs as the text editor for this course.

== Install Docker Desktop
<InstallDocker>
Docker will prompt you several times to log in to an account, you
#strong[do not need a docker account] to use Docker Desktop, or any of
its features for this course.

Note that the Docker engine, and Docker Desktop #strong[are not the
  same], and Docker Desktop is the only option we support. You should go
through
#link("https://docs.docker.com/desktop/setup/install/windows-install/")[the documentation],
read through it first, and then follow the instructions to install
Docker Desktop. You should also read through
#link("https://docs.docker.com/desktop/setup/install/windows-permission-requirements/")[this documentation]
if you have concerns about permissions on Windows. In general, if you
are unsure about a command you are running, you can find documentation
using the man pages, i.e. `man docker-build` or `man docker-run`, etc.

== Build the container from `cse305_dev_env` repository
<BuildContainer>
A Docker image is the standard for which Docker containers are built
from. You should only have to build this image once, and use it to
create containers to develop within.

You need to clone the
#link("https://github.com/UB-CSE-305/cse305_dev_env")[course repository]
first. If you would like to use Emacs as your text editor, read
@EmacsSetup, otherwise, if you would like to use VS Code, read
@VSCodeSetup.

=== Using Emacs in terminal
<EmacsSetup>
You need to build and run the Docker image from the terminal.

While being in the same directory as the repository, you can build the
image with the following command in a terminal:

```bash
$ docker build . -t 305image
```

You may replace `305image` with any appropriate name for how you want to
organize it. The `-t` flag in this instance refers to tagging the image
with the name you provided.

To create a container from the image you just built:

```bash
$ docker run --name 305container -it \
  --mount type=bind,source="$(pwd)"/local_workspace,target=/home/cse305/workspace \
  305image
```

In this command, we are naming the container `305container`. The flags
`-it` tell docker to run the container with an interactive terminal.

`--mount` allows you to mount our `local_workspace` folder into the
container at `/home/cse305/workspace`. This setup allows most of the
compilation and development work to happen within the Docker container,
while any code saved in the workspace folder inside the container
actually resides on the host machine. As a result, the code persists
independently of the container lifecycle and will not be lost when the
container is removed. Therefore, the workspace folder
`/home/cse305/workspace` is the primary location for you to develop your
code.

`305image` being appended after the flags tells docker which image we
want to create the container from. After running that, you should
shortly see something resembling a Linux command prompt.

If you have created a container before (and have not deleted it), you
can run it with the following command:

```bash
$ docker start -i 305container
```

To attach your current terminal session to the container:

```bash
$ docker attach 305container
```

To list all containers you have created:

```bash
$ docker ps -a
```

`-a` flag here shows all containers, including those that are stopped.

Pre-installed Emacs development environment provides out-of-the-box
Language Server Protocol (LSP) support and auto code formatting. The red
highlighting means that there's a syntax error, and LSP will provide
error/warning messages when you move your cursor to the highlighted
code. When you save the file (`C-x C-s`), `ocamlformat` will
automatically format your code if there are no syntax errors.

Some other useful Emacs commands when writing OCaml in the container:

- `C-x C-l`: Jump to the definition of the symbol under cursor.

- `C-c C-i`: Jump to the declaration of the symbol under cursor.

- `C-c C-x`: Jump to next error in buffer.

- `C-c C-c`: Jump to previous error in buffer.

To add your own Emacs configurations, you should edit the file
#strong[`/home/cse305/.config/emacs/user.el`].

Proceed to @TestEnv after setting up your preferred method.

=== Using VS Code with plugins
<VSCodeSetup>
You need to install
#link("https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers")[Dev Containers]
in order to access the full functionality if you are using Visual Studio
Code.

We use the Dev Container plugin to connect the `/home/cse305/workspace`
folder inside the Docker container with the `local_workspace` in our
repository. This setup allows most of the compilation and development
work to happen within the Docker container, while any code saved in the
workspace folder inside the container actually resides on the host
machine. As a result, the code persists independently of the container
lifecycle and will not be lost when the container is removed. Therefore,
the workspace folder `/home/cse305/workspace` is the primary location
for you to develop your code.

After installing the plugin, open the repository folder you just cloned
in VS Code. Then, open the VS Code Command Palette
(`Ctrl+P` on Linux/Windows or `Cmd+P` on macOS) and type
"`> Dev Container: Reopen in Container`" to connect to your container.

#figure(image("images/vscode_cmd_pat.png", width: 60.0%))

A new window will open and attach to the container. It will then pull
and build the latest release image that matches your architecture and
install the necessary extensions automatically. Depending on your
internet connection and system performance, this process may take some
time.

To connect to a previously created container, open a new VS Code window,
open the "Containers" tab on the left sidebar, find your container,
right-click on it and select "Start".

#figure(image("images/vscode_start_container.png", width: 50.0%))

After the container is started, right-click on it again and select
"Attach Visual Studio Code", a new window will open and attach to the
container.

#figure(image("images/vscode_attach_editor.png", width: 50.0%))

The new window will open and attach to the container, but it may not
open the workspace folder automatically. To open the workspace folder,
click on "Open Folder" or go to `File > Open Folder`$dots.h$, then
choose `/home/cse305/workspace` and click "OK". Workspace folder with
pre-existing "`test.ml`" should open.

#figure(image("images/vscode_open_workspace.png", width: 50.0%))
#figure(image("images/vscode_click_ok.png", width: 60.0%))

#pagebreak()
= Run your code
<CompileRun>
To run your OCaml code in the terminal, go to the correct directory with
your `<filename.ml>` code file, and type:

```bash
$ ocamlc -o <output_filename> <filename.ml>
$ ./<output_filename>
```

You can also run your OCaml code without compiling it first using the
OCaml interpreter:

```bash
$ ocaml <filename.ml>
```

Another way is to use the OCaml top-level `utop`, which is an
interactive REPL environment. After starting `utop`, you can run your
code:

```
#use "filename.ml";;
```

To exit `utop`:

```
#quit;;
```

#figure(image("images/utop_run_code.png", width: 60.0%))

Check out @TestEnv for a concrete example.

#pagebreak()
= Testing your environment
<TestEnv>
Open your text editor and create a file named `test.ml`. In the file
write:

```
print_endline "Hello, World!";;
```

Save your code, and then in your terminal navigate to the directory
where you saved `test.ml`, and run:

```bash
$ ocamlc -o hello test.ml
$ ./hello
```

This should print 'Hello, World!' in the terminal:

#figure(image("images/compile_success.png", width: 60.0%))

If your syntax highlighting and autocomplete are setup properly it
should look like this:

#figure(image("images/emacs_autocomplete.png", width: 60.0%))

When you write code with errors, `ocamllsp` will show static type errors
in your text editor:

#figure(image("images/static_check.png", width: 60.0%))

#pagebreak()
= Troubleshoot
<Troubleshoot>
== I ran `which ocaml` and it said `ocaml: command not found!`
<i-ran-which-ocaml-and-it-said-ocaml-command-not-found>
If closing and reopening the terminal or restarting machine doesn't
help, run `opam env` in your terminal, normally it should look like
this:

```bash
[22:23:20] Vincent@ArchLinux ~ % opam env
OPAM_LAST_ENV='/home/Vincent/.opam/.last-env/env-bf2bef-0'; export OPAM_LAST_ENV;
OPAM_SWITCH_PREFIX='/home/Vincent/.opam/default'; export OPAM_SWITCH_PREFIX;
CAML_LD_LIBRARY_PATH='/home/Vincent/.opam/default/lib/stublibs:
                      /home/Vincent/.opam/default/lib/ocaml/stublibs:
                      /home/Vincent/.opam/default/lib/ocaml';
                      export CAML_LD_LIBRARY_PATH;
OCAML_TOPLEVEL_PATH='/home/Vincent/.opam/default/lib/toplevel';
                    export OCAML_TOPLEVEL_PATH;
MANPATH=':/home/Vincent/.opam/default/man'; export MANPATH;
PATH='/home/Vincent/.opam/default/bin:/usr/local/sbin:/usr/local/bin:/usr/bin';
      export PATH;
```

If the output is empty, something went wrong when `opam` initialized the
environment.

If the output looks correct, but `which ocaml` still doesn't work, You
can manually add the following line to your shell configuration file
(`.bashrc`, `.zshrc`, etc.~depending on which shell you are using, you
can find it out by running `echo $SHELL`):

```bash
eval $(opam env)
```

After adding that line, close and reopen your terminal and try
`which ocaml` again.

== VSCode syntax highlighting and autocomplete not working
<vscode-syntax-highlighting-and-autocomplete-not-working>
You need to install `ocaml-lsp-server` and `ocamlformat` by running:

```bash
opam install -y ocaml-lsp-server ocamlformat
```

== I tried to build the Docker image, but it failed with an error.
<i-tried-to-build-the-docker-image-but-it-failed-with-an-error.>
Make sure you read the error message carefully. It often provides clues
about what went wrong. Please let us know if you are unable to resolve
the issue.

== Received an error "`Cannot connect to the Docker daemon at docker.sock. Is the docker daemon running?`"/"`Docker error the docker daemon is not running`"
<received-an-error-cannot-connect-to-the-docker-daemon-at-docker.sock.-is-the-docker-daemon-runningdocker-error-the-docker-daemon-is-not-running>
Make sure Docker Desktop is running before you try to run any Docker
commands.

== Docker Desktop shows an error "`WSL needs updating: Your version of Windows Subsystem for Linux is too old`"
<docker-desktop-shows-an-error-wsl-needs-updating-your-version-of-windows-subsystem-for-linux-is-too-old>
Go to
#link("https://github.com/microsoft/WSL/releases")[WSL GitHub Releases],
download the `.msi` installer from the latest stable release under the
Assets section, if you are using amd64 architecture, download
`wsl.#.#.#.x64.msi`, if you are using arm64 architecture, download
`wsl.#.#.#.arm64.msi`. Run the installer and follow the setup
instructions, and restart your machine when it's done.

=== VS Code cannot connect to the container, shows error "`ERROR: failed to solve: error getting credentials`/`gpg: public key decryption failed: No secret key`/`gpg: decryption failed: No secret key`"
<vs-code-cannot-connect-to-the-container-shows-credentials-error>
This error is caused by a broken GPG key in the Docker credentials. Try running the command
```bash
docker logout ghcr.io
```
in your terminal, and then reconnect to the container in VS Code.

#pagebreak()
= About
<about>
The docker setup part of this document is adapted from CSE 421/521:
Operating Systems, and part of the Emacs setup configuration is adapted
from
#link("https://github.com/ub-cse220/emacs-config")[CSE 220: System Programming].
