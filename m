From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 21/31] mount.nfs: Don't update extra_opts after text-based
	negotiation
Date: Mon, 29 Jun 2009 13:38:07 -0400
Message-ID: <20090629173806.2076.47736.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:39664 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756947AbZF2RkH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:40:07 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The umount.nfs command will negotiate the mount options again, so all
that is needed in /etc/mnttab is the original set of options used for
the mount, plus the additional mandatory options like addr=''.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index e94265a..8d168db 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -283,7 +283,16 @@ static int nfs_validate_options(struct nfsmount_info *mi)
 	if (!nfs_append_sloppy_option(mi->options))
 		return 0;
 
-	return nfs_append_addr_option(sap, salen, mi->options);
+	if (!nfs_append_addr_option(sap, salen, mi->options))
+		return 0;
+
+	/*
+	 * Update option string to be recorded in /etc/mnttab
+	 */
+	if (po_join(mi->options, mi->extra_opts) == PO_FAILED)
+		return 0;
+
+	return 1;
 }
 
 /*
@@ -476,7 +485,7 @@ out:
  */
 static int nfs_try_mount(struct nfsmount_info *mi)
 {
-	char **extra_opts = mi->extra_opts;
+	char *options = NULL;
 	int result;
 
 	if (strncmp(mi->type, "nfs4", 4) != 0) {
@@ -484,20 +493,20 @@ static int nfs_try_mount(struct nfsmount_info *mi)
 			return 0;
 	}
 
-	if (po_join(mi->options, extra_opts) == PO_FAILED) {
+	if (po_join(mi->options, &options) == PO_FAILED) {
 		errno = EIO;
 		return 0;
 	}
 
 	if (verbose)
 		printf(_("%s: trying text-based options '%s'\n"),
-			progname, *extra_opts);
+			progname, options);
 
 	if (mi->fake)
 		return 1;
 
 	result = mount(mi->spec, mi->node, mi->type,
-			mi->flags & ~(MS_USER|MS_USERS), *extra_opts);
+			mi->flags & ~(MS_USER|MS_USERS), options);
 	if (verbose && result) {
 		int save = errno;
 		nfs_error(_("%s: mount(2): %s"), progname, strerror(save));

