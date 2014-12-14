include_recipe "apt"
include_recipe "git"

def setup_vim(users, gist)
  install_vim

  users.each do |user|
    install_vimrc(user, gist)

    create_bundle_directory(user)

    install_and_run_vundle(user)
  end
end

def install_vim
  package "vim" do
    options "--force-yes"
    action :upgrade
  end
end

def install_vimrc(user, gist)
  if gist && gist.length > 0
    remote_file "Create .vimrc" do
      path "/home/#{user}/.vimrc"
      user user
      source gist
      not_if { File.exists?("/home/#{user}/.vimrc") }
    end
  else
    template "/home/#{user}/.vimrc" do
      source "vimrc.erb"
      owner user
      mode "644"
      action :create_if_missing
      not_if { File.exists?("/home/#{user}/.vimrc") }
    end
  end
end

def create_bundle_directory(user)
  directory "/home/#{user}/.vim" do
    owner user
    group user
  end

  directory "/home/#{user}/.vim/bundle" do
    owner user
    group user
  end
end

def install_and_run_vundle(user)
  install_solarized_theme(user)

  install_vundle(user)
end

def install_solarized_theme(user)
  git "/home/#{user}/.vim/bundle/vim-colors-solarized" do
    repository "git://github.com/altercation/vim-colors-solarized"
    action :sync
    user user
  end

end

def install_vundle(user)
  git "/home/#{user}/.vim/bundle/Vundle.vim" do
    repository "git://github.com/gmarik/Vundle.vim.git"
    action :sync
    user user
  end

  run_plugin_install(user)
end

def run_plugin_install(user)
  execute "run-vundle-#{user}" do
    action :run
    command "vim -c 'set shortmess=at' +PluginInstall +qall"
    timeout node[:vim][:timeout]
    environment 'HOME' => "/home/#{user}"
    user user
    only_if { File.exists?("/home/#{user}/.vim/bundle/Vundle.vim") }
  end
end

users = node[:vim][:users]
gist = node[:vim][:gist]

setup_vim(users, gist)
