# Note: You can use any Debian/Ubuntu based image you want. 
FROM mcr.microsoft.com/vscode/devcontainers/base:0-buster

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"
# [Option] Enable non-root Docker access in container
ARG ENABLE_NONROOT_DOCKER="true"
# [Option] Use the OSS Moby Engine instead of the licensed Docker Engine
ARG USE_MOBY="true"
# [Option] Engine/CLI Version
ARG DOCKER_VERSION="latest"

# Enable new "BUILDKIT" mode for Docker CLI
ENV DOCKER_BUILDKIT=1

# Install needed packages and setup non-root user. Use a separate RUN statement to add your
# own dependencies. A user of "automatic" attempts to reuse an user ID if one already exists.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
COPY library-scripts/*.sh /tmp/library-scripts/
RUN apt-get update \
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    # Use Docker script from script library to set things up
    && /bin/bash /tmp/library-scripts/docker-in-docker-debian.sh "${ENABLE_NONROOT_DOCKER}" "${USERNAME}" "${USE_MOBY}" "${DOCKER_VERSION}" \
    # Clean up
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts/

VOLUME [ "/var/lib/docker" ]

# Setting the ENTRYPOINT to docker-init.sh will start up the Docker Engine 
# inside the container "overrideCommand": false is set in devcontainer.json. 
# The script will also execute CMD if you need to alter startup behaviors.
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

ARG AWS_CLI_VERSION=$AWS_CLI_VERSION
ARG TERRAGRUNT_VERSION=$TERRAGRUNT_VERSION
ARG TERRAFORM_VERSION=$TERRAFORM_VERSION

USER $USERNAME
RUN mkdir -p ~/.local/bin \
    && echo "export PATH=\$PATH:~/.local/bin" >> ~/.bashrc

# ** [Optional] Uncomment this section to install additional packages. **
RUN sudo apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && sudo apt-get -y install --no-install-recommends unzip less sudo gnupg software-properties-common curl build-essential procps file git gnupg \
    && sudo apt-get autoremove -y \
    && sudo apt-get clean

# Set env for tracking that we're running in a devcontainer
ENV DEVCONTAINER=true

# Save command line history
RUN echo "export HISTFILE=/home/$USERNAME/commandhistory/.bash_history" >> "/home/$USERNAME/.bashrc" \
    && echo "export PROMPT_COMMAND='history -a'" >> "/home/$USERNAME/.bashrc" \
    && mkdir -p /home/$USERNAME/commandhistory \
    && touch /home/$USERNAME/commandhistory/.bash_history \
    && chown -R $USERNAME /home/$USERNAME/commandhistory

# Install AWS CLI
RUN sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip" \
    && sudo unzip awscliv2.zip \
    && sudo ./aws/install

# Install Terraform
RUN sudo curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - \
    && sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    && sudo apt-get update && sudo apt-get install terraform=$TERRAFORM_VERSION

# Install TF lint 
ENV TFLINT_VERSION=$TFLINT_VERSION
RUN sudo curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash 

# Install Terragrunt
RUN sudo curl -o /usr/local/bin/terragrunt -fsSL "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" \
    && sudo chmod +x /usr/local/bin/terragrunt