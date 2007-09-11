From: "Chris Carlson" <c.carlson@aristoslogic.com>
Subject: nfs_refresh_inode: inode number mismatch
Date: Tue, 11 Sep 2007 09:41:51 -0700
Message-ID: <46E6C54F.4020100@aristoslogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IV8oS-0007ZI-7r
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 09:42:08 -0700
Received: from 65-119-21-40.dia.static.qwest.net ([65.119.21.40]
	helo=gabriel.aristoslogic.com)
	by mail.sourceforge.net with smtp (Exim 4.44) id 1IV8oV-0006Q2-SE
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 09:42:13 -0700
Received: from gabriel.aristoslogic.com (localhost [127.0.0.1])
	by localhost.aristoslogic.com (Postfix) with ESMTP id E081C221F
	for <nfs@lists.sourceforge.net>; Tue, 11 Sep 2007 09:42:05 -0700 (PDT)
Received: from daak.aristoslogic.com (unknown [172.31.1.2])
	by gabriel.aristoslogic.com (Postfix) with SMTP id A8E592204
	for <nfs@lists.sourceforge.net>; Tue, 11 Sep 2007 09:42:05 -0700 (PDT)
Received: from [172.31.10.74] ([172.31.10.74]) by
	daak.aristoslogic.com (Netscape Messaging Server 4.1) with ESMTP
	id JO7QE500.AC2 for <nfs@lists.sourceforge.net>; Tue, 11 Sep
	2007 09:42:05 -0700
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


We are running MontaVista Embedded Linux 2.4 with NetApps NFS servers as 
the root filesystem and Linux 2.6 mounted filesystems.  A simple test 
runs to copy files from one mount point to another (both are different 
directories on the same NFS server mounted at differet points).

After 30 copies of a hundred files are made, the system is rebooted and 
the test repeats.

After 2 reboots, an NFS file is created, and we get the following error 
from the kernel:

nfs_refresh_inode: inode number mismatch
expected (0x11/0xdacea3), got (0x11/0xb8d5e3)

We're just trying to figure out what to do to figure out what the 
problem is.  Is there a good place to place printks or breakpoints?

Thanks for any assistance you can provide.

Chris Carlson


CONFIDENTIALITY NOTICE:

This email, together with any attachments, is intended only for use by Aristos Logic Corporation and the
individual(s) to which it is addressed and may contain information that is privileged, confidential or 
exempt from disclosure. If you are not the intended recipient, you are hereby notified that any dissemination,
distribution, or copying of this email, or any attachment, is strictly prohibited. If you have received this
email in error, please notify Aristos Logic Corporation by sending an email to sysadm@aristoslogic.com
and delete this email, along with any attachments, from your computer.

Thank you.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
