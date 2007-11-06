From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/15] nfs(5) man page: Update nfs(5) author
	information.
Date: Mon, 05 Nov 2007 20:04:04 -0500
Message-ID: <20071106010404.5037.40665.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: steved@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpCrO-0004l1-Dg
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:04:06 -0800
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpCrS-0006Fd-W5
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:04:12 -0800
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

 utils/mount/nfs.man |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 67ecc94..f9393e8 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -1,7 +1,5 @@
-.\" nfs.5 "Rick Sladkey" <jrs@world.std.com>
-.\" Wed Feb  8 12:52:42 1995, faith@cs.unc.edu: updates for Ross Biro's
-.\" patches. "
-.TH NFS 5 "20 November 1993" "Linux 0.99" "Linux Programmer's Manual"
+.\"@(#)nfs.5"
+.TH NFS 5 "2 November 2007"
 .SH NAME
 nfs \- fstab format and options for the
 .B nfs
@@ -1123,5 +1121,3 @@ RFC 1833 for the RPC bind specification.
 RFC 2203 for the RPCSEC GSS API protocol specification.
 .br
 RFC 3530 for the NFS version 4 specification. 
-.SH AUTHOR
-"Rick Sladkey" <jrs@world.std.com>


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
