From: devzero@web.de
Subject: stale nfs file handle with exported loopback mounts
Date: Sat, 27 Oct 2007 18:13:52 +0200
Message-ID: <2051050286@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: NFS@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hello !

with 2.6.22 i`m trying to export loopback mounted iso-images.

this is /etc/exports:

/export *(ro,crossmnt,subtree_check)

in /export, i have loopback mounted iso-images

after mounting on the client side under /mnt (tried one older and one recent system) , i`m getting:

vmhost:/mnt # ls -la
/bin/ls: iso1: Input/output error
/bin/ls: iso2  Input/output error
/bin/ls: iso3: Input/output error
total 10128
drwxrwxrwt   18 root root  270336 Oct 26 08:45 .
drwxrwxrwt  186 root root   20760 Oct 27 17:45 ..
drwxr-xr-x    2 root root   16384 Jan  1  1970 iso1
drwxr-xr-x    2 root root   16384 Jan  1  1970 iso2
drwxr-xr-x    2 root root   16384 Jan  1  1970 iso3

vmhost:/mnt/iso1 # ls
/bin/ls: .: Stale NFS file handle
vmhost:/mnt/iso1 # ls -la
/bin/ls: .: Input/output error

i`m unsure if i should blame suse here (it`s an opensuse 10.3 box which seems to have nfs-utils 1.1.0)

does somebody have such setup up and running and can tell his distro / kernel and nfs-utils version ?
maybe i change distro then.

any clues what`s going wrong here and how to resolve ?

regards
roland

_____________________________________________________________________
Der WEB.DE SmartSurfer hilft bis zu 70% Ihrer Onlinekosten zu sparen!
http://smartsurfer.web.de/?mc=100071&distributionid=000000000066


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
