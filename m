From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] mount.nfs: Assume v2/v3 if mount-related options are
	present
Date: Mon, 26 Oct 2009 17:03:19 -0400
Message-ID: <20091026210319.14346.20494.stgit@matisse.1015granger.net>
References: <20091026210110.14346.90636.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:49893 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128AbZJZVFU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Oct 2009 17:05:20 -0400
In-Reply-To: <20091026210110.14346.90636.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't try NFSv4 if any MNT protocol related options were presented by
the user.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   52 +++++++++++++++++++++++++++++++++++--------------
 1 files changed, 37 insertions(+), 15 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index ceefdb0..0f1061c 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -259,24 +259,11 @@ static int nfs_append_sloppy_option(struct mount_options *options)
 	return 1;
 }
 
-/*
- * Set up mandatory non-version specific NFS mount options.
- *
- * Returns 1 if successful; otherwise zero.
- */
-static int nfs_validate_options(struct nfsmount_info *mi)
+static int nfs_set_version(struct nfsmount_info *mi)
 {
-	struct sockaddr *sap = (struct sockaddr *)&mi->address;
-
-	if (!nfs_parse_devname(mi->spec, &mi->hostname, NULL))
-		return 0;
-
-	mi->salen = sizeof(mi->address);
-	if (!nfs_name_to_address(mi->hostname, sap, &mi->salen))
-		return 0;
-
 	if (!nfs_nfs_version(mi->options, &mi->version))
 		return 0;
+
 	if (strncmp(mi->type, "nfs4", 4) == 0)
 		mi->version = 4;
 	else {
@@ -284,6 +271,19 @@ static int nfs_validate_options(struct nfsmount_info *mi)
 		if (option && strcmp(option, "rdma") == 0)
 			mi->version = 3;
 	}
+
+	/*
+	 * If we still don't know, check for version-specific
+	 * mount options.
+	 */
+	if (mi->version == 0) {
+		if (po_contains(mi->options, "mounthost") ||
+		    po_contains(mi->options, "mountaddr") ||
+		    po_contains(mi->options, "mountvers") ||
+		    po_contains(mi->options, "mountproto"))
+			mi->version = 3;
+	}
+
 	/*
 	 * Use the default value set in the config file when
 	 * the version has not been explicitly set.
@@ -293,6 +293,28 @@ static int nfs_validate_options(struct nfsmount_info *mi)
 			mi->version = config_default_vers;
 	}
 
+	return 1;
+}
+
+/*
+ * Set up mandatory non-version specific NFS mount options.
+ *
+ * Returns 1 if successful; otherwise zero.
+ */
+static int nfs_validate_options(struct nfsmount_info *mi)
+{
+	struct sockaddr *sap = (struct sockaddr *)&mi->address;
+
+	if (!nfs_parse_devname(mi->spec, &mi->hostname, NULL))
+		return 0;
+
+	mi->salen = sizeof(mi->address);
+	if (!nfs_name_to_address(mi->hostname, sap, &mi->salen))
+		return 0;
+
+	if (!nfs_set_version(mi))
+		return 0;
+
 	if (!nfs_append_sloppy_option(mi->options))
 		return 0;
 

