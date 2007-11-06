From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/15] nfs(5) man page: Update the NAME section
Date: Mon, 05 Nov 2007 20:02:51 -0500
Message-ID: <20071106010251.5037.29257.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: steved@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpCqD-0004Z4-De
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:02:53 -0800
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpCqI-0004FD-1Y
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:02:59 -0800
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

 utils/mount/nfs.man |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index d92da19..2d96c5c 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -3,7 +3,11 @@
 .\" patches. "
 .TH NFS 5 "20 November 1993" "Linux 0.99" "Linux Programmer's Manual"
 .SH NAME
-nfs \- nfs and nfs4 fstab format and options
+nfs \- fstab format and options for the
+.B nfs
+and
+.B nfs4
+file systems
 .SH SYNOPSIS
 .B /etc/fstab
 .SH DESCRIPTION


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
