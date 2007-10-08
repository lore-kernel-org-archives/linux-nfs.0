From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/12] text-based mount.nfs: sort between permanent
	and	temporary errors
Date: Mon, 08 Oct 2007 11:54:23 -0400
Message-ID: <20071008155423.15051.45449.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ieuw4-0007ko-LB
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 08:54:25 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ieuw9-0001FT-Ok
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 08:54:30 -0700
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

 utils/mount/stropts.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 2d43e18..2cf62a3 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -238,6 +238,27 @@ static int set_mandatory_options(const char *type,
 }
 
 /*
+ * Distinguish between permanent and temporary errors.
+ *
+ * Returns 0 if the passed-in error is temporary, thus the
+ * mount system call should be retried; returns one if the
+ * passed-in error is permanent, thus the mount system call
+ * should not be retried.
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
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
