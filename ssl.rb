dep 'passwordless ssh logins' do
  met? { shell "grep '#{var(:your_ssh_public_key)}' ~/.ssh/authorized_keys" }
  before { shell "mkdir -p -m 700 ~/.ssh" }
  meet { append_to_file var(:your_ssh_public_key), '~/.ssh/authorized_keys' }
  after { shell "chmod 600 ~/.ssh/authorized_keys" }
end

dep 'public key' do
  met? { grep(/^ssh-dss/, '~/.ssh/id_dsa.pub') }
  meet { log shell("ssh-keygen -t dsa -f ~/.ssh/id_dsa -N ''") }
end

dep 'bad certificates removed' do
  def cert_names
    %w[
      DigiNotar_Root_CA
    ]
  end
  def existing_certs
    cert_names.map {|name|
      "/etc/ssl/certs/#{name}.pem".p
    }.select {|cert|
      cert.exists?
    }
  end
  setup {
    unless [:debian, :ubuntu].include?(Babushka::Base.host.flavour)
      unmeetable "Not sure where to find certs on a #{Babushka::Base.host.description} system."
    end
  }
  met? { existing_certs.empty? }
  meet { existing_certs.each(&:rm) }
end