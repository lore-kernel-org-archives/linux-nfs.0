From: Hua Qin <qinhua@poisson.ecse.rpi.edu>
Subject: NetApp nfs server support tcp v3 root file system?
Date: Wed, 4 Sep 2002 18:44:03 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.10.10209041833310.15635-100000@poisson.ecse.rpi.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.rpi.edu ([128.113.22.40])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17misf-0000AC-00
	for <nfs@lists.sourceforge.net>; Wed, 04 Sep 2002 15:44:13 -0700
Received: from poisson.ecse.rpi.edu (poisson.ecse.rpi.edu [128.113.50.30])
	by mail.rpi.edu (8.12.1/8.12.1) with ESMTP id g84Mi88Y049898
	for <nfs@lists.sourceforge.net>; Wed, 4 Sep 2002 18:44:08 -0400
Received: from localhost (qinhua@localhost)
	by poisson.ecse.rpi.edu (8.9.1/8.9.1) with ESMTP id SAA15648
	for <nfs@lists.sourceforge.net>; Wed, 4 Sep 2002 18:44:03 -0400 (EDT)
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


I have NetApp as a nfs server, and on the NetApp, /etc/exports  shows the
correct configure: /vol/vol0/dev/  anon=0
I can mount /dev from  linuxA using v3 tcp nfs, then I try to use /dev as
root file to boot linuxB, I [Bcan not boot successfully.
I can see it got the ip address from dhcp server, then after that:

Looking up port of RPC 100003/3 on 172.29.255.1  
Looking up port of RPC 100005/3 on 172.29.255.1
mount: server 172.29.255.1 not responding, timed out
Root-NFS: Server returned error -5 while mounting /dev
VFS: Unable to mount root fs via NFS, trying floppy.
VFS: Insert root floppy and press ENTER
VFS: Cannot open root device "nfs" or 02:00
Please append a correct "root=" boot option
Kernel panic: VFS: Unable to mount root fs on 02:00

But I can use udp v3 to boot it. so I am wondering, what will cause this
problem, someone has the same setup?

Thanks!
Hua





-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
