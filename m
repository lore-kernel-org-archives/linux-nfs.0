From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/19] text-based mount.nfs: add a function to do
	foreground	retries
Date: Mon, 10 Sep 2007 20:59:38 -0400
Message-ID: <20070911005937.24927.32744.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUu6N-00033e-AF
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 17:59:39 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUu6R-00089v-WE
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 17:59:44 -0700
Received: from monet.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi102.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l8B0xR2U028851
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 17:59:27 -0700
Received: from monet.1015granger.net (monet.1015granger.net [127.0.0.1])
	by monet.1015granger.net (8.14.1/8.14.1) with ESMTP id l8B0xcSY025068
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 20:59:38 -0400
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

 utils/mount/stropts.c |   55 ++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 54 insertions(+), 1 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 99d48cf..dd68f9a 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -350,7 +350,10 @@ static int rewrite_mount_opts(struct mount_options *options)
 }
 
 /*
- * Attempt an NFS mount via a mount(2) system call.
+ * Attempt an NFS mount via a mount(2) system call.  If the kernel
+ * claims the requested service isn't supported on the server, probe
+ * the server to see what's supported, rewrite the mount options,
+ * and retry the request.
  *
  * Returns 1 if successful.  Otherwise, returns zero.
  * "errno" is set to reflect the individual error.
@@ -399,6 +402,56 @@ parse_err:
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
+		if (errno == EINVAL)
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
