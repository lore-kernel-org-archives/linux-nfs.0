From: Patrick O'Reilly <patrick.oreilly@uni.edu>
Subject: Solaris 8 - RH 7.1 NFS Bugs
Date: Mon, 03 Jun 2002 16:21:59 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <017501c20b44$b291b390$66f1a186@OREILLY>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from viper.uni.edu ([134.161.1.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17EzHE-0000ze-00
	for <nfs@lists.sourceforge.net>; Mon, 03 Jun 2002 14:22:08 -0700
Received: from OREILLY ([134.161.241.102]) by uni.edu (PMDF V6.1-1 #39731)
 with SMTP id <01KII0SZTMXA8Y5MQ9@uni.edu> for nfs@lists.sourceforge.net; Mon,
 03 Jun 2002 16:22:06 -0500 (CDT)
To: nfs@lists.sourceforge.net
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hello,

I have a Sun Sparc (Solaris 8) NFS server serving to 3 identical Sun Sparcs
and 25 PC's with RH Linux 7.1.  The NFS mounts from Solaris to Solaris work
and persist, but the linux boxes do not.  The filesystem on the linux boxes
mounts correctly at boot, and the data persists ONLY when the user 'root'
logs on.  If another user logs on, the data 'disappears' while the mount
persists.  Below are the results from 2 df -k commands (/mnt/gemdata is the
NFS mount):

[root@xxxxxxx weather]# df
Filesystem 1k-blocks Used Available Use% Mounted on
/dev/hdb6 25205252 10785776 13139100 46% /
/dev/hdb7 13108468 1179272 11263304 10% /usr
xxxxxxx.xxxxx.xxx.edu:/space
12899648 4451328 8319328 35% /mnt/gemdata

5 minutes later, logged on as a regular user......

[weather@xxxxxxx ~]$ df
Filesystem 1k-blocks Used Available Use% Mounted on
/dev/hdb6 25205252 10785760 13139116 46% /
/dev/hdb7 13108468 1179272 11263304 10% /usr
xxxxxxx.xxxx.xxx.edu:/space
0 1 0 0% /mnt/gemdata

Also, the following messages show up in /var/log/messages:

johnstown kernel: nfs_statfs: statfs error = 13
johnstown kernel: call_verify: server requires stronger authentication.

Apparently, the Sun has no problem with the 'root' user on the linux boxes,
but any other 'less qualified' user logs on and there are problems.  Has
anyone heard of/experienced this?  Is there an option I could add to my
'share' command on the NFS server, or my /etc/fstab on my linux boxes that
would help this situation?  Thanks!

Patrick

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Patrick O'Reilly                               Support Scientist
The STORM Project            patrick.oreilly@uni.edu
208 Latham Hall                             ph: 319-273-3789
University of Northern Iowa
Cedar Falls, IA 50614
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
