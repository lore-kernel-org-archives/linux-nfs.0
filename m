From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/12] text-based mount.nfs: Implement falling back to
	NFSv2	and UDP
Date: Mon, 08 Oct 2007 11:54:12 -0400
Message-ID: <20071008155412.15051.69209.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ieuvu-0007kG-AJ
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 08:54:15 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ieuvz-0001AD-F1
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 08:54:19 -0700
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

If the initial user-specified options fail (with EOPNOTSUPP or
EPROTONOSUPPORT) then the server has rejected the requested NFS version
or transport protocol.

In that case, probe the server, then construct a fresh set of mount
options that ask for the specific mountd and NFS version and transport
protocol that the server supports.  Rewrite the mount options based on
the results of the probe, then try the request again.

An additional kernel patch is required to cause the kernel to return
EOPNOTSUPP when an rpcbind fails during a NULL request.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   66 ++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 64 insertions(+), 2 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index d000695..62eca87 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -351,10 +351,64 @@ err:
 }
 
 /*
- * Attempt an NFSv2/3 mount via a mount(2) system call.
+ * Retry an NFS mount that failed because the requested service isn't
+ * available on the server.
  *
  * Returns 1 if successful.  Otherwise, returns zero.
  * "errno" is set to reflect the individual error.
+ *
+ * Side effect: If the retry is successful, both 'options' and
+ * 'extra_opts' are updated to reflect the mount options that worked.
+ * If the retry fails, 'options' and 'extra_opts' are left unchanged.
+ */
+static int retry_nfsmount(const char *spec, const char *node,
+			int flags, struct mount_options *options,
+			int fake, char **extra_opts)
+{
+	struct mount_options *retry_options;
+	char *retry_str = NULL;
+
+	retry_options = rewrite_mount_options(*extra_opts);
+	if (!retry_options) {
+		errno = EIO;
+		return 0;
+	}
+
+	if (po_join(retry_options, &retry_str) == PO_FAILED) {
+		po_destroy(retry_options);
+		errno = EIO;
+		return 0;
+	}
+
+	if (verbose)
+		printf(_("%s: text-based options (retry): '%s'\n"),
+			progname, retry_str);
+
+	if (!mount(spec, node, "nfs",
+				flags & ~(MS_USER|MS_USERS), retry_str)) {
+		free(*extra_opts);
+		*extra_opts = retry_str;
+		po_replace(options, retry_options);
+		return 1;
+	}
+
+	po_destroy(retry_options);
+	free(retry_str);
+	return 0;
+}
+
+/*
+ * Attempt an NFSv2/3 mount via a mount(2) system call.  If the kernel
+ * claims the requested service isn't supported on the server, probe
+ * the server to see what's supported, rewrite the mount options,
+ * and retry the request.
+ *
+ * Returns 1 if successful.  Otherwise, returns zero.
+ * "errno" is set to reflect the individual error.
+ *
+ * Side effect: If the retry is successful, both 'options' and
+ * 'extra_opts' are updated to reflect the mount options that worked.
+ * If the retry fails, 'options' and 'extra_opts' are left unchanged.
  */
 static int try_nfs23mount(const char *spec, const char *node,
 			  int flags, struct mount_options *options,
@@ -375,7 +429,15 @@ static int try_nfs23mount(const char *spec, const char *node,
 	if (!mount(spec, node, "nfs",
 				flags & ~(MS_USER|MS_USERS), *extra_opts))
 		return 1;
-	return 0;
+
+	/*
+	 * The kernel returns EOPNOTSUPP if the RPC bind failed,
+	 * and EPROTONOSUPPORT if the version isn't supported.
+	 */
+	if (errno != EOPNOTSUPP && errno != EPROTONOSUPPORT)
+		return 0;
+
+	return retry_nfsmount(spec, node, flags, options, fake, extra_opts);
 }
 
 /*


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
