From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 18/24] text-based mount.nfs: add a function to do
	foreground	retries
Date: Wed, 12 Sep 2007 12:16:03 -0400
Message-ID: <20070912161603.23491.45099.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVUsp-0004YD-Vf
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:16:08 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVUst-0002oD-8C
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:16:12 -0700
Received: from manray.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l8CGFDSb029739
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 09:15:13 -0700
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id l8CGG33H023615
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 12:16:03 -0400
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

Make the differences between the foreground and background mount logic
explicit by creating separate functions to handle each -- think of them as
separate scripts for doing a foreground or a background mount.

NFS foreground mounts are supposed to retry for a little while before
giving up.  Add a function that handles this.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   50 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 7f5a5bc..892790e 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -426,6 +426,56 @@ parse_err:
 }
 
 /*
+ * Handle "foreground" NFS mounts.
+ *
+ * Retry the mount request for as long as the 'retry=' option says.
+ *
+ * Returns a valid mount command return code: zero if successful,
+ * EX_FAIL if a failure occurred.
+ */
+static int nfsmount_fg(const char *spec, const char *node,
+		       int flags, struct mount_options *options,
+		       int fake, char **extra_opts)
+{
+	unsigned int secs = 1;
+	time_t timeout = time(NULL);
+	char *retry;
+
+	retry = po_get(options, "retry");
+	if (!retry)
+		timeout += 60 * 2;	/* default: 2 minutes */
+	else
+		timeout += 60 * atoi(retry);
+
+	for (;;) {
+		if (try_nfsmount(spec, node, flags, options,
+						fake, extra_opts))
+			return 0;
+
+		if (is_permanent_error(errno))
+			break;
+
+		if (time(NULL) > timeout) {
+			errno = ETIMEDOUT;
+			break;
+		}
+
+		if (verbose)
+			printf(_("%s: will retry until %s\n"),
+				progname, ctime(&timeout));
+
+		if (sleep(secs))
+			break;
+		secs <<= 1;
+		if (secs > 5)
+			secs = 5;
+	};
+
+	mount_error(spec, node, errno);
+	return EX_FAIL;
+}
+
+/*
  * nfsmount_s - Mount an NFSv2 or v3 file system using C string options
  *
  * @spec:	C string hostname:path specifying remoteshare to mount


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
