From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/15] nfs(5) man page: Add a MOUNT OPTIONS section.
Date: Mon, 05 Nov 2007 20:03:07 -0500
Message-ID: <20071106010307.5037.77022.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: steved@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpCqT-0004eS-Cy
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:03:09 -0800
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpCqW-0005s9-2A
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:03:13 -0800
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

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs.man |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 06bd3be..45c6da1 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -73,6 +73,16 @@ and
 .B nfs4
 file system types share similar mount options,
 which are described below. 
+.SH "MOUNT OPTIONS"
+See
+.BR mount (8)
+for a description of generic mount options
+available for all file systems.
+Use the
+.B defaults
+generic option in
+.I /etc/fstab
+if you do not need to specify any mount options. 
 .DT
 .SS Options for the nfs file system type
 .TP 1.5i


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
