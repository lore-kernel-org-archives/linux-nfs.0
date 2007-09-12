From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 20/24] text-based mount.nfs: Add functions to
	handle	background NFS v2/3 mounts
Date: Wed, 12 Sep 2007 12:16:13 -0400
Message-ID: <20070912161613.23491.84807.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVUsx-0004aM-6j
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:16:15 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVUt1-0002ta-Qz
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:16:20 -0700
Received: from manray.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l8CGFOsW030308
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 09:15:24 -0700
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id l8CGGDpD023627
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 12:16:13 -0400
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

Add two helper functions that handle background NFS mounts; one for the
foreground processing (to try the request, and determine when to fork) and
one for the background processing (retry the request as a forked child).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   73 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 73 insertions(+), 0 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 6658308..e5be243 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -472,6 +472,79 @@ static int nfsmount_fg(const char *spec, const char *node,
 }
 
 /*
+ * Handle "background" NFSv2/3 mount [first try]
+ *
+ * Returns a valid mount command return code: zero if successful,
+ * EX_BG if a temporary failure occurred, EX_FAIL if a permanent
+ * error occurred.
+ *
+ * EX_BG should cause the caller to fork and invoke nfsmount_child.
+ */
+static int nfsmount_parent(const char *spec, const char *node,
+			   char *hostname, int flags,
+			   struct mount_options *options,
+			   int fake, char **extra_opts)
+{
+	if (try_nfsmount(spec, node, flags, options, fake, extra_opts))
+		return 0;
+
+	if (is_permanent_error(errno)) {
+		mount_error(spec, node, errno);
+		return EX_FAIL;
+	}
+
+	sys_mount_errors(hostname, errno, 1, 1);
+	return EX_BG;
+}
+
+/*
+ * Handle "background" NFSv2/3 mount [retry daemon]
+ *
+ * Returns a valid mount command return code: zero if successful,
+ * EX_FAIL if a failure occurred.  There's nothing to catch the
+ * error return, though, so we use sys_mount_errors to log the
+ * failure.
+ */
+static int nfsmount_child(const char *spec, const char *node,
+			  char *hostname, int flags,
+			  struct mount_options *options,
+			  int fake, char **extra_opts)
+{
+	unsigned int secs = 1;
+	time_t timeout = time(NULL);
+	char *retry;
+
+	retry = po_get(options, "retry");
+	if (!retry)
+		timeout += 60 * 10000;	/* default: 10,000 minutes */
+	else
+		timeout += 60 * atoi(retry);
+
+	for (;;) {
+		if (sleep(secs))
+			break;
+		secs <<= 1;
+		if (secs > 30)
+			secs = 30;
+
+		if (!try_nfsmount(spec, node, flags, options,
+					fake, extra_opts))
+			return 0;
+
+		if (is_permanent_error(errno))
+			break;
+
+		if (time(NULL) > timeout)
+			break;
+
+		sys_mount_errors(hostname, errno, 1, 1);
+	};
+
+	sys_mount_errors(hostname, errno, 1, 0);
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
