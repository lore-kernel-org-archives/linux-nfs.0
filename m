From: <courier@telica.com>
Subject: NFS Client hung when NFS server down.
Date: Sat, 9 Nov 2002 16:06:55 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <2066.130.215.192.254.1036876015.squirrel@wmail.telica.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from wmail.telica.com ([4.19.224.200])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Acok-0003iy-00
	for <nfs@lists.sourceforge.net>; Sat, 09 Nov 2002 13:06:58 -0800
To: <nfs@lists.sourceforge.net>
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

Hello ALL:

First here is what we have in our environment:

NFS server: netapp F820 with export 6 /home1, /home2,.../home6

NFS Client:

12 Linux Redhat7.2

15 Solaris8 Sun Ultra10.

My question is: why all Linux Redhat7.2 client hung when NFS server is
down, but not Solaris8.

All Linux and Solaris are using nfsV3 and Netapp has services as NFS v3
and v2.

When I said hung: meaning that on Linux server my users can login, but
they can't do any things after login. On the other hand if they login to
Solaris box then it is not hangs, but their home dir is not there. I
though NFS clients on Linux should do the same as Solaris. Meaning no
mount point when users are login.

Can someone help or educated me on this?

Thank you in advanced.

Vinh






-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
