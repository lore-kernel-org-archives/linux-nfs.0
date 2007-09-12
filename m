From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/24] text-based mount.nfs: Create helpers for
	invoking	mount(2) system call
Date: Wed, 12 Sep 2007 12:15:37 -0400
Message-ID: <20070912161537.23491.36033.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVUsM-0004RV-Ri
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:15:39 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVUsR-0002Yp-Fh
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:15:43 -0700
Received: from manray.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l8CGEltw028614
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 09:14:48 -0700
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id l8CGFbds023585
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 12:15:37 -0400
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

Add a simple helper functions that invoke the mount(2) system call for
text-based mounts.  These functions will become more complex over the
following patches as we implement fallback and background mounting.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   64 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 64 insertions(+), 0 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index ecd9045..7c1d3ac 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -210,6 +210,38 @@ static int fix_up_mounthost_opt(struct mount_options *options)
 }
 
 /*
+ * Attempt an NFS mount via a mount(2) system call.
+ *
+ * Returns 1 if successful.  Otherwise, returns zero.
+ * "errno" is set to reflect the individual error.
+ */
+static int try_nfsmount(const char *spec, const char *node,
+			int flags, struct mount_options *options,
+			int fake, char **extra_opts)
+{
+	free(*extra_opts);
+	*extra_opts = po_join(options);
+	if (!*extra_opts) {
+		nfs_error(_("%s: internal option parsing error"), progname);
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
+
+	mount_error(spec, node, errno);
+	return 0;
+}
+
+/*
  * nfsmount_s - Mount an NFSv2 or v3 file system using C string options
  *
  * @spec:	C string hostname:path specifying remoteshare to mount
@@ -276,6 +308,38 @@ out:
 }
 
 /*
+ * Attempt an NFS v4 mount via a mount(2) system call.
+ *
+ * Returns 1 if successful.  Otherwise, returns zero.
+ * "errno" is set to reflect the individual error.
+ */
+static int try_nfs4mount(const char *spec, const char *node,
+			 int flags, struct mount_options *options,
+			 int fake, char **extra_opts)
+{
+	free(*extra_opts);
+	*extra_opts = po_join(options);
+	if (!*extra_opts) {
+		nfs_error(_("%s: internal option parsing error"), progname);
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
+
+	mount_error(spec, node, errno);
+	return 0;
+}
+
+/*
  * nfs4mount_s - Mount an NFSv4 file system using C string options
  *
  * @spec:	C string hostname:path specifying remoteshare to mount


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
