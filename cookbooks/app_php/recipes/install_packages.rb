%w{build-essential php5 php5-mysql php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt libapache2-mod-php5 apache2 }.each do |pkg|
  package pkg do
    action :install
  end
end
