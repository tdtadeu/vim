include_recipe "apt"

package "vim" do
  options "--force-yes"
  action :upgrade
end

node['vim']['users'].each do |user|
  remote_file "Create .vimrc" do
    path "/home/#{user}/.vimrc"
    user user
    source "#{node['vim']['gist']}"
    not_if { File.exists?("/home/#{user}/.vimrc") }
  end

  directory "/home/#{user}/.vim" do
    owner user
    group user
  end

  directory "/home/#{user}/.vim/bundle" do
    owner user
    group user
  end

  git "/home/#{user}/.vim/bundle/vim-colors-solarized" do
    repository "git://github.com/altercation/vim-colors-solarized"
    action :sync
    user user
  end

  execute "run-vundle-#{user}" do
    action :nothing
    command "vim +PluginInstall +qall"
    timeout 600
    user user
  end

  git "/home/#{user}/.vim/bundle/Vundle.vim" do
    repository "git://github.com/gmarik/Vundle.vim.git"
    action :sync
    notifies :run, "execute[run-vundle-#{user}]"
    user user
  end
end
