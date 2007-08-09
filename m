From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/5] umount.nfs: Update umount.nfs(8)
Date: Thu, 09 Aug 2007 17:37:01 -0400
Message-ID: <20070809213701.16767.95368.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IJFgm-0007ko-TU
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 14:37:05 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IJFgn-0005oa-IQ
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 14:37:08 -0700
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

Account for recent changes to the umount.nfs command.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/umount.nfs.man |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/utils/mount/umount.nfs.man b/utils/mount/umount.nfs.man
index 8214c9a..ee4cdaf 100644
--- a/utils/mount/umount.nfs.man
+++ b/utils/mount/umount.nfs.man
@@ -1,4 +1,4 @@
-.\"@(#)mount.nfs.8"
+.\"@(#)umount.nfs.8"
 .TH UMOUNT.NFS 8 "6 Jun 2006"
 .SH NAME
 umount.nfs, umount.nfs4 \- unmount a Network File System
@@ -66,9 +66,8 @@ table of mounted file systems
 .BR nfs (5),
 .BR umount (8),
 
-.SH BUGS
-Please notify current developers of NFS of any bugs in the current software or mail nfs@lists.sourceforge.net
+.SH "BUGS"
+Please notify nfs@lists.sourceforge.net of any bugs found in this software.
 
 .SH "AUTHOR"
 Amit Gud <agud@redhat.com>
-


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
