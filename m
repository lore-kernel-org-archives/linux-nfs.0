From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/12] text-based mount.nfs: Add functions to
	handle	background mounting
Date: Mon, 08 Oct 2007 11:54:33 -0400
Message-ID: <20071008155433.15051.32426.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IeuwF-0007lV-Kz
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 08:54:35 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IeuwK-0006ZU-PV
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 08:54:41 -0700
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

Add helper functions that handle background mounts; one each for
foreground processing (to try the request, and determine when to fork);
and one for background processing (retry the request multiple times as
a forked background daemon).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   89 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 89 insertions(+), 0 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index e9be78d..27ada39 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -558,6 +558,95 @@ static int nfsmount_fg(const char *spec, const char *node,
 	return EX_FAIL;
 }
 
+/*
+ * Handle "background" NFS mount [first try]
+ *
+ * Returns a valid mount command exit code.
+ *
+ * EX_BG should cause the caller to fork and invoke nfsmount_child.
+ */
+static int nfsmount_parent(const char *spec, const char *node,
+			   const char *type, char *hostname, int flags,
+			   struct mount_options *options,
+			   int fake, char **extra_opts)
+{
+	if (try_mount(spec, node, type, flags, options,
+					fake, extra_opts))
+		return EX_SUCCESS;
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
+ * Handle "background" NFS mount [retry daemon]
+ *
+ * Returns a valid mount command exit code: EX_SUCCESS if successful,
+ * EX_FAIL if a failure occurred.  There's nothing to catch the
+ * error return, though, so we use sys_mount_errors to log the
+ * failure.
+ */
+static int nfsmount_child(const char *spec, const char *node,
+			  const char *type, char *hostname, int flags,
+			  struct mount_options *options,
+			  int fake, char **extra_opts)
+{
+	unsigned int secs = 1;
+	time_t timeout = time(NULL);
+	char *retry;
+
+	timeout += 60 * 10000;		/* default: 10,000 minutes */
+	retry = po_get(options, "retry");
+	if (retry)
+		timeout += 60 * atoi(retry);
+
+	for (;;) {
+		if (sleep(secs))
+			break;
+		secs <<= 1;
+		if (secs > 120)
+			secs = 120;
+
+		if (try_mount(spec, node, type, flags, options,
+							fake, extra_opts))
+			return EX_SUCCESS;
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
+ * Handle "background" NFS mount
+ *
+ * Returns a valid mount command exit code.
+ */
+static int nfsmount_bg(const char *spec, const char *node,
+			  const char *type, char *hostname, int flags,
+			  struct mount_options *options,
+			  int fake, int child, char **extra_opts)
+{
+	if (!child)
+		return nfsmount_parent(spec, node, type, hostname, flags,
+					options, fake, extra_opts);
+	else
+		return nfsmount_child(spec, node, type, hostname, flags,
+					options, fake, extra_opts);
+}
+
 /**
  * nfsmount_string - Mount an NFS file system using C string options
  * @spec: C string specifying remote share to mount ("hostname:path")


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
