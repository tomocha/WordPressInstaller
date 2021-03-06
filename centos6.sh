
#
# WordPress インストール
#

# �@Apache, MySQL, PHPのインストール
# 日本語を扱うのでPHPのmbstringもインストールしておく
# パスワード生成のコマンドもインストールしておく
yum -y install httpd mysql-server php php-mysql php-mbstring || exit 1
yum -y install expect || exit 1

# �AMySQLの準備
# 2.1 サーバー起動時にサービスが立ち上がるように設定
# 2.2 サービス開始
# 2.3 セキュリティ設定（後で実施すること）
chkconfig mysqld on || exit 1
service mysqld start || exit 1
#mysql_secure_installation

# �BWordPress用データベースの準備
# 3.1 WordPressからMySQLに接続するユーザーを作成
# 3.2 WordPress用データベースの作成
# 3.3 ユーザーにDBアクセスの権限を割り当て
MYSQL_PASSWORD=`mkpasswd -s 0 -l 8`
mysql -u root -e "CREATE USER 'wordpress'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';" || exit 1
mysql -u root -e 'CREATE DATABASE IF NOT EXISTS `wordpress` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;' || exit 1
mysql -u root -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';" || exit 1

# �CWordPress配置
# 4.1 ディレクトリ移動
# 4.3 WordPressの日本語版をダウンロード
# 4.3 tar.gzの展
# 4.4 wordpressディレクトリに移動
# 4.5 テンプレートをコピーして設定ファイルを作成
# 4.6 データベース接続情報を設定
cd /var/www/html
wget http://ja.wordpress.org/latest-ja.tar.gz || exit 1
tar xvzf latest-ja.tar.gz
cd wordpress
cp wp-config-sample.php wp-config.php
sed -i 's/database_name_here/wordpress/g' wp-config.php || exit 1
sed -i 's/username_here/wordpress/g' wp-config.php || exit 1
sed -i 's/password_here/'$MYSQL_PASSWORD'/g' wp-config.php || exit 1

# �DApacheがWordPressを参照できるようオーナー変更
chown -R apache:apache /var/www/html/wordpress || exit 1

# �EApacheのサービス開始
# 6.1 サーバー起動時に自動的にサービスが立ち上がるように設定
# 6.2 サービス開始
# 6.3 FWでhttpを許可 / 保存
chkconfig httpd on || exit 1
service httpd start || exit 1
iptables -I INPUT 1 -p tcp --dport http -j ACCEPT || exit 1
service iptables save || exit 1

