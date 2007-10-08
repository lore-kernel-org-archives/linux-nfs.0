From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/12] text-based mount.nfs: Create helpers for
	invoking	mount(2) system call
Date: Mon, 08 Oct 2007 11:54:02 -0400
Message-ID: <20071008155402.15051.82181.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ieuvl-0007iq-Jx
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 08:54:05 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ieuvq-0006Js-NT
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 08:54:10 -0700
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

Add simple helper functions that invoke the mount(2) system call for
text-based mounts.  These look the same right now, but the NFSv2/v3 helper
will become more complex over the following patches as we implement version
and transport protocol fallback.


Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   74 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 74 insertions(+), 0 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 6f57e86..c048be0 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -237,6 +237,80 @@ static int set_mandatory_options(const char *type,
 	return 1;
 }
 
+/*
+ * Attempt an NFSv2/3 mount via a mount(2) system call.
+ *
+ * Returns 1 if successful.  Otherwise, returns zero.
+ * "errno" is set to reflect the individual error.
+ */
+static int try_nfs23mount(const char *spec, const char *node,
+			  int flags, struct mount_options *options,
+			  int fake, char **extra_opts)
+{
+	if (po_join(options, extra_opts) == PO_FAILED) {
+		errno = EIO;
+		return 0;
+	}
+
+	if (verbose)
+		printf(_("%s: text-based options: '%s'\n"),
+			progname, *extra_opts);
+
+	if (fake)
+		return 1;
+
+	if (!mount(spec, node, "nfs",
+				flags & ~(MS_USER|MS_USERS), *extra_opts))
+		return 1;
+	return 0;
+}
+
+/*
+ * Attempt an NFS v4 mount via a mount(2) system call.
+ *
+ * Returns 1 if successful.  Otherwise, returns zero.
+ * "errno" is set to reflect the individual error.
+ */
+static int try_nfs4mount(const char *spec, const char *node,
+			 int flags, struct mount_options *options,
+			 int fake, char **extra_opts)
+{
+	if (po_join(options, extra_opts) == PO_FAILED) {
+		errno = EIO;
+		return 0;
+	}
+
+	if (verbose)
+		printf(_("%s: text-based options: '%s'\n"),
+			progname, *extra_opts);
+
+	if (fake)
+		return 1;
+
+	if (!mount(spec, node, "nfs4",
+				flags & ~(MS_USER|MS_USERS), *extra_opts))
+		return 1;
+	return 0;
+}
+
+/*
+ * Try the mount(2) system call.
+ *
+ * Returns 1 if successful.  Otherwise, returns zero.
+ * "errno" is set to reflect the individual error.
+ */
+static int try_mount(const char *spec, const char *node, const char *type,
+		     int flags, struct mount_options *options, int fake,
+		     char **extra_opts)
+{
+	if (strncmp(type, "nfs4", 4) == 0)
+		return try_nfs4mount(spec, node, flags,
+					options, fake, extra_opts);
+	else
+		return try_nfs23mount(spec, node, flags,
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
