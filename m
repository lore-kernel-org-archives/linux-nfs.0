From: Avishay Traeger <atraeger@cs.sunysb.edu>
Subject: Linux Generation Numbers
Date: Sat, 6 Dec 2003 12:13:53 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.53.0312061212090.10106@compserv2>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ASg0U-0001hZ-F0
	for nfs@lists.sourceforge.net; Sat, 06 Dec 2003 09:14:14 -0800
Received: from sbcs.cs.sunysb.edu ([130.245.1.15])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1ASg0U-0005Cc-3c
	for nfs@lists.sourceforge.net; Sat, 06 Dec 2003 09:14:14 -0800
Received: from compserv2 (compserv2 [130.245.1.58])
	by sbcs.cs.sunysb.edu (8.12.3/8.12.3) with ESMTP id hB6HDpnR024474
	for <nfs@lists.sourceforge.net>; Sat, 6 Dec 2003 12:13:52 -0500 (EST)
To: nfs@lists.sourceforge.net
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

Hello,

I am trying to figure out exactly how Linux assigns generation numbers to
inodes.  In most filesystems (such as ext2/ext3) the generation number is
assigned to event++.  This variable is declared in kernel/timer.c, but
apparently not initialized.  I made 3 files, each one immediately after a
reboot, and this is the information I got:

generation#
10417bbc
bf612079
8cf4b829

>From what I can tell, event is only incremented in a few places in the fs
directory.  Can someone please explain if event is actually initialized,
and if so, to what?  And if it is initialized to a specific number, how
are these generation numbers so big and varied?

tia.

Avishay Traeger

File System and Storage Lab
Computer Science Department
Stony Brook University





-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
