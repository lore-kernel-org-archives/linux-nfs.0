From: Jeff Garzik <jgarzik@pobox.com>
Subject: recent NFS problems?
Date: Sat, 05 Nov 2005 01:28:14 -0500
Message-ID: <436C50FE.3030600@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EYHXQ-00070Z-3Y
	for nfs@lists.sourceforge.net; Fri, 04 Nov 2005 22:28:28 -0800
Received: from mail.dvmed.net ([216.237.124.58])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EYHXP-0005d2-PR
	for nfs@lists.sourceforge.net; Fri, 04 Nov 2005 22:28:28 -0800
To: Trond.Myklebust@netapp.com,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a bit weird.  Running 2.6.14-g6037d6bb (libata-dev.git branch 
'upstream') on both client and server.  Its latest Linux 
(7015faa7df829876a0f931cd18aa6d7c24a1b581) plus one libata patch.  All 
NFSv4 kernel options are enabled, on both client and server.

On Host A, I mirror a local directory /garz/nsmail to an NFS directory 
Host_B:/g/g/nsmail via rsync+ssh.  Host A also NFS mounts Host_B:/g 
locally.  mount on Host A says

	host_b:/g on /g type nfs (rw,tcp,intr,posix,addr=10.10.10.1)

Seeing some directory weirdness, where wildcard matches fail 
(NFS-related dcache bugs?) but direct accesses succeed:

[jgarzik@host_a~]$ ssh host_b "ls -d /g/g/nsmail/Trash.sbd/*11*"
/g/g/nsmail/Trash.sbd/Sent.20051105
/g/g/nsmail/Trash.sbd/Sent.20051105.msf
/g/g/nsmail/Trash.sbd/Sent.20051105.sbd
/g/g/nsmail/Trash.sbd/Trash.20051105
/g/g/nsmail/Trash.sbd/Trash.20051105.msf
/g/g/nsmail/Trash.sbd/Trash.20051105.sbd

[jgarzik@host_a ~]$ ls -d /g/g/nsmail/Trash.sbd/*11*
ls: /g/g/nsmail/Trash.sbd/*11*: No such file or directory

[jgarzik@host_a ~]$ ls -l /g/g/nsmail/Trash.sbd/Trash.20051105
-rw-rw-r--  1 jgarzik jgarzik 67484129 Nov  5 00:02 
/g/g/nsmail/Trash.sbd/Trash.20051105

[jgarzik@host_a~]$ wc -l /g/g/nsmail/Trash.sbd/Trash.20051105
1739088 /g/g/nsmail/Trash.sbd/Trash.20051105


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
