From: Tremesberger Oliver <oliver.tremesberger@fh-joanneum.at>
Subject: nfsv4 Kerberos with netapp doesn't work
Date: Wed, 17 Sep 2003 15:21:23 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <29638132053DD711A6C70002A5F069818EC3A2@hubble>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19zcFo-0007lN-00
	for <nfs@lists.sourceforge.net>; Wed, 17 Sep 2003 06:21:57 -0700
Received: from roswell.fh-joanneum.at ([62.218.221.21])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 19zcFo-0004uD-6i
	for nfs@lists.sourceforge.net; Wed, 17 Sep 2003 06:21:56 -0700
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hey,

I'm working on a single sign on szenario of windows and linux clients. until
now everything works fine. but the last thing wont work. i try to put all
homedirectories to a fileserver. this fileserver is a netapp simulator
6.4.1. with this simulator it should be possible to authenticate the users
through kerberos 5. but it doesn't work.

I use a windows 2000 KDC with MKSADPlugin to store attributes which linux
clients need, e.g. UID, GID, Home Directory,...

As linux client I use a RedHat 7.3 machine with the nfsv4 release two patch
from www.citi.umich.edu. 
on this machine I get my kerberosticket from the W2K KDC each time I log on
or if I type kinit in the console.

does anyone of you have expirience with a single sign on szenario like this
or do you know how to configure netapp simulator with kerberos
funktionality?

in my case i always get the error message...:
mount: wrong fs type, bad option, bad superblock on
192.168.0.25:/vol/vol0/home, or too many mounted file systems 

...when i try to mount the directory with this command:
[root@rh90admin root]# mount -t nfs4 -o sec=krb5 192.168.0.25:/vol/vol0/home
/mnt/test

thx
oliver



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
