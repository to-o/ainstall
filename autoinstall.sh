#!/bin/sh
#控制那些需要进行安装 根据选择进行安装

SMABA=1
GIT_ALIAS=1
GIOTRASH=1
CRE_SSH=1
ZSH=1
DNSSEVER=1

echo "----------------自动化安装脚本----------------"

echo "----------------进行更新源----------------"

#配置DNS服务
if [ $DNSSEVER ];then
	echo "-------------配置DNS服务-----------"
	sudo sh -c 'echo nameserver 172.20.191.2 >> /etc/resolv.conf'
	sudo sh -c 'echo nameserver 172.17.50.100 >> /etc/resolv.conf'
fi

sudo apt update -y


#进行判断ssh是否安装
if [! type ssh >/dev/null 2>&1 ]; then
	echo "----------------安装SSH----------------"
	sudo apt install ssh -y
fi

#samba新建的目录名字为share 在用户目录之下
#判断是否需要安装和是否已经安装
if [ $SMABA ]; then
	if [! type samba >/dev/null 2>&1 ]; then 
		echo "----------------进行安装samba----------------"
		mkdir ~/share
		chmod 777 share 
		sudo apt install samba -y
		echo "-------------注意此处需要输入两次密码-----------"
		sudo smbpasswd -a $LOGNAME
		#导入配置
		sudo sed '174 a[home]\npath = /home\nwritable = yes\ndirectory mask = 0777\ncreate mask = 0777\nbrowseable = yes\navailable = yes\nread only = no\nguest ok = yes\ncomment = xxx' -i /etc/samba/smb.conf
		sudo service smbd restart

		echo "-------------安装samba成功-----------"
	else
		echo 'samba 已安装';
	fi
fi 

#进行git的配置 看个人的习惯
if [ $GIT ];then
	echo "-------------git 全局配置-----------"
	git config --global alias.co checkout
	git config --global alias.br branch
	git config --global alias.ci commit
	git config --global alias.st status
	git config --global alias.unstage 'reset HEAD --'
	git config --global alias.last 'log -1 HEAD'
	git config --global alias.logl 'log --oneline'
fi

#是否需要生成SSH密匙
if [ $CRE_SSH ];then
	echo "-------------生成SSH密匙 需要连续按三次回车默认参数-----------"
	ssh-keygen -t rsa -C "wangsong@kylinos.cn"
	cat /home/kylin/.ssh/id_rsa.pub > ~/ssh
fi

#zsh的安装
if [ $ZSH ];then
	echo "-------------zsh的安装中-----------"
	sudo apt install zsh -y
	wget https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh
	chmod +x install.sh
	./install.sh
	cd ~/.oh-my-zsh/custom/plugins
	git clone https://github.com/zsh-users/zsh-syntax-highlighting
	sudo sed -e '/plugins/d' ~/.zshrc
	sudo sed '73 aplugins=(git zsh-syntax-highlighting colored-man-pages)' -i ~/.zshrc
	source ./.zshrc
fi
