
#
# WordPress �C���X�g�[��
#

# �@Apache, MySQL, PHP�̃C���X�g�[��
# ���{��������̂�PHP��mbstring���C���X�g�[�����Ă���
# �p�X���[�h�����̃R�}���h���C���X�g�[�����Ă���
yum -y install httpd mysql-server php php-mysql php-mbstring || exit 1
yum -y install expect || exit 1

# �AMySQL�̏���
# 2.1 �T�[�o�[�N�����ɃT�[�r�X�������オ��悤�ɐݒ�
# 2.2 �T�[�r�X�J�n
# 2.3 �Z�L�����e�B�ݒ�i��Ŏ��{���邱�Ɓj
chkconfig mysqld on || exit 1
service mysqld start || exit 1
#mysql_secure_installation

# �BWordPress�p�f�[�^�x�[�X�̏���
# 3.1 WordPress����MySQL�ɐڑ����郆�[�U�[���쐬
# 3.2 WordPress�p�f�[�^�x�[�X�̍쐬
# 3.3 ���[�U�[��DB�A�N�Z�X�̌��������蓖��
MYSQL_PASSWORD=`mkpasswd -s 0 -l 8`
mysql -u root -e "CREATE USER 'wordpress'@'localhost' IDENTIFIED BY $MYSQL_PASSWORD;" || exit 1
mysql -u root -e 'CREATE DATABASE IF NOT EXISTS `wordpress` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;' || exit 1
mysql -u root -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost' IDENTIFIED BY 'wordpress';" || exit 1

# �CWordPress�z�u
# 4.1 �f�B���N�g���ړ�
# 4.3 WordPress�̓��{��ł��_�E�����[�h
# 4.3 tar.gz�̓W
# 4.4 wordpress�f�B���N�g���Ɉړ�
# 4.5 �e���v���[�g���R�s�[���Đݒ�t�@�C�����쐬
# 4.6 �f�[�^�x�[�X�ڑ�����ݒ�
cd /var/www/html
wget http://ja.wordpress.org/latest-ja.tar.gz || exit 1
tar xvzf latest-ja.tar.gz
cd wordpress
cp wp-config-sample.php wp-config.php
sed -i 's/database_name_here/wordpress/g' wp-config.php || exit 1
sed -i 's/username_here/wordpress/g' wp-config.php || exit 1
sed -i 's/password_here/'$MYSQL_PASSWORD'/g' wp-config.php || exit 1

# �DApache��WordPress���Q�Ƃł���悤�I�[�i�[�ύX
chown -R apache:apache /var/www/html/wordpress || exit 1

# �EApache�̃T�[�r�X�J�n
# 6.1 �T�[�o�[�N�����Ɏ����I�ɃT�[�r�X�������オ��悤�ɐݒ�
# 6.2 �T�[�r�X�J�n
# 6.3 FW��http������ / �ۑ�
chkconfig httpd on || exit 1
service httpd start || exit 1
iptables -I INPUT 1 -p tcp --dport http -j ACCEPT || exit 1
service iptables save || exit 1

