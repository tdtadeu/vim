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
end
