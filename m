From: "Antoniu-George SAVU" <santoniu@ftml.net>
Subject: Annoying rename() problem
Date: Sat, 21 Oct 2006 21:53:21 +0200
Message-ID: <003f01c6f54a$90506250$020010ac@athlon64>
Reply-To: Antoniu-George SAVU <antoniu-george.savu@linux-expert.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GbMuP-0004iX-BH
	for nfs@lists.sourceforge.net; Sat, 21 Oct 2006 12:53:29 -0700
Received: from adm.linux-expert.eu
	([88.191.16.97] helo=smtp.linux-expert.eu ident=postfix)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GbMuO-0005ip-TM
	for nfs@lists.sourceforge.net; Sat, 21 Oct 2006 12:53:30 -0700
Received: from athlon64 (adm.fr.linux-expert.eu [82.224.29.57])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by smtp.linux-expert.eu (Postfix) with ESMTP id 492C356C1CB
	for <nfs@lists.sourceforge.net>; Sat, 21 Oct 2006 21:53:27 +0200 (CEST)
To: <nfs@lists.sourceforge.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hello,

I am using NFS to store Courier mailboxes in Maildir format on a NFS 
exported disk. As some of you might already know, Courier has two main 
folders inside each Maildir, new/ and cur/. The new/ directory one is used 
to incoming messages and the cur/ directory is used to store already seen 
messages for a given folder. When an user access its mailbox, Courier IMAP 
will rename all the files found in new/ to the cur/ directory.

Now, when a user has more than 50 files inside the new/ directory and 
Courier IMAP rename those files to cur/ directory, I get strange errors 
inside the Courier log complaining that the rename() has failed with the 
errno=ENOENT (no such file or directory). The most amazing part is that the 
files are moved just fine from new/ to cur/ and I just can not understand 
why I keep getting those rename() errors and most important, how can I fix 
this.

My setup follows:

The NFS server runs under Debian Sarge with custom 2.6.18 kernel, NFSv4 
support with NFSv3 support. The psyhical machine is an AMD Opteron 64 and 
the NFS exports are stored on a RAID-5 array. /etc/exports contains:

/nfs-exported    192.168.0.2(rw,all_squash,anonuid=10000,anongid=10000,sync)

The versions of Debian packages:
portmap : Version: 5-9 / Architecture: amd64
nfs-kernel-server: Version: 1:1.0.6-3.1 / Architecture: amd64
nfs-common : Version: 1:1.0.6-3.1 / Architecture: amd64

The NFS client runs under Debian Sarge with custom 2.6.18 kernel, NFSv4 
support with NFSv3 support inside a VMWare virtual machine with bridged 
networking and vmware-tools correctly installed.

Client mount options from /etc/fstab:

192.168.0.1:/nfs-exported   /nfs   nfs 
rw,hard,intr,nfsvers=3,sync,noac,nodev,nosuid 0 0

The nfs-common and portmap packages have the same version like on the NFS 
server. On the client, I've tried most of the mont nfs's combinations and 
tried using the pseudo-fileystem nfs4. No luck, the errors are still there.

My problem perfectly fits this description: 
http://lists.freebsd.org/pipermail/freebsd-bugs/2003-October/003461.html but 
the bug reports dates from 2003.

Anyone has a suggestion of what I could try or do ? I've searched the NFS 
mailinglist, nothing, nada. Any suggestion is more than welcome.

Thank you,
George







-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
