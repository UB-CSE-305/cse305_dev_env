ARG  BASE_IMAGE=ubuntu:24.04
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.authors="Vincent Chan <vichan39@buffalo.edu>"
LABEL org.opencontainers.image.title="CSE305 Intro to Programming Languages Course Image"
LABEL org.opencontainers.image.description="Provides Opam, OCaml, and Utop with a preconfigured Emacs development environment"

ARG OCAML_VERSION=4.14.2
ARG USER_NAME=cse305
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

# Prerequisites & Utilities
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    apt-utils build-essential \
    ca-certificates curl git python3 \
    opam bubblewrap rsync unzip \
    emacs-nox clangd ssh-client sudo

# Delete the unused Ubuntu user ‘ubuntu’ introduced since 24.04
RUN userdel -r ubuntu \
    && groupadd --gid ${USER_GID} ${USER_NAME} \
    && useradd -s /bin/bash --uid ${USER_UID} --gid ${USER_GID} -m ${USER_NAME} \
    && echo ${USER_NAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USER_NAME} \
    && chmod 0440 /etc/sudoers.d/${USER_NAME}
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

# Configuration for OCaml
ENV PATH=/home/${USER_NAME}/.opam/${USER_NAME}_${OCAML_VERSION}/bin:$PATH
RUN opam init --bare -ay \
    && opam switch create ${USER_NAME}_${OCAML_VERSION} ocaml-base-compiler.${OCAML_VERSION} \
    && opam install -y merlin ocaml-lsp-server ocamlformat utop \
    && chmod +x .opam/opam-init/*.sh \
    && echo 'eval $(opam env)' >> .bashrc \
    && echo "version = `ocamlformat --version`" >> .ocamlformat

# Configuration for Emacs
COPY --chown=${USER_NAME}:${USER_NAME} emacs /home/${USER_NAME}/.config/emacs
RUN emacs --batch -l .config/emacs/init.el

# Check installation
RUN which opam \
    && ocamlc -v \
    && emacs --version
