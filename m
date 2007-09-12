From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 17/24] text-based mount.nfs: sort between permanent
	and	temporary errors
Date: Wed, 12 Sep 2007 12:15:58 -0400
Message-ID: <20070912161558.23491.20040.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVUsi-0004TU-BX
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:16:00 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVUsm-0000rN-Q5
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:16:05 -0700
Received: from manray.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l8CGF8uY029467
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 09:15:08 -0700
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id l8CGFwkI023609
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 12:15:58 -0400
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

The text-based mount.nfs program must distinguish between different types
of errors returned from the kernel.  Permanent errors, like bad mount
options, should cause an immediate failure.  Temporary errors, such as a
connection timeout, should result in a retry of some type.

Add a function that sorts between the two types of errors.  The list of
permanent errors can be adjusted later if needed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index d4777df..7f5a5bc 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -210,6 +210,26 @@ static int fix_up_mounthost_opt(struct mount_options *options)
 }
 
 /*
+ * Distinguish between permanent and temporary errors.
+ *
+ * Returns 0 if the passed-in error code represents a
+ * temporary error that can be retried, and one if
+ * the error code represents a permanent error.
+ */
+static int is_permanent_error(int error)
+{
+	switch (error) {
+	case EACCES:
+	case ESTALE:
+	case ETIMEDOUT:
+	case ECONNREFUSED:
+		return 0;	/* temporary */
+	default:
+		return 1;	/* permanent */
+	}
+}
+
+/*
  * Reconstruct the mount option string based on a portmapper probe
  * of the server.  Returns one if the server's portmapper returned
  * something we can use, otherwise zero.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
