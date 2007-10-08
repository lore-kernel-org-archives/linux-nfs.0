From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/12] text-based mount.nfs: add function to do
	foreground	retries
Date: Mon, 08 Oct 2007 11:54:28 -0400
Message-ID: <20071008155428.15051.72113.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ieuw9-0007l6-Vz
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 08:54:30 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IeuwF-0001Hn-5R
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 08:54:35 -0700
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
giving up.  Add a function to handle this.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   51 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 51 insertions(+), 0 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 2cf62a3..e9be78d 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -507,6 +507,57 @@ static int try_mount(const char *spec, const char *node, const char *type,
 					options, fake, extra_opts);
 }
 
+/*
+ * Handle "foreground" NFS mounts.
+ *
+ * Retry the mount request for as long as the 'retry=' option says.
+ *
+ * Returns a valid mount command exit code.
+ */
+static int nfsmount_fg(const char *spec, const char *node,
+		       const char *type, int flags,
+		       struct mount_options *options, int fake,
+		       char **extra_opts)
+{
+	unsigned int secs = 1;
+	time_t timeout = time(NULL);
+	char *retry;
+
+	timeout += 60 * 2;		/* default: 2 minutes */
+	retry = po_get(options, "retry");
+	if (retry)
+		timeout += 60 * atoi(retry);
+
+	if (verbose)
+		printf(_("%s: timeout set for %s"),
+			progname, ctime(&timeout));
+
+	for (;;) {
+		if (try_mount(spec, node, type, flags,
+					options, fake, extra_opts))
+			return EX_SUCCESS;
+
+		if (is_permanent_error(errno))
+			break;
+
+		if (time(NULL) > timeout) {
+			errno = ETIMEDOUT;
+			break;
+		}
+
+		if (errno != ETIMEDOUT) {
+			if (sleep(secs))
+				break;
+			secs <<= 1;
+			if (secs > 10)
+				secs = 10;
+		}
+	};
+
+	mount_error(spec, node, errno);
+	return EX_FAIL;
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
