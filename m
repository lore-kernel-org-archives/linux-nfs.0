From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/5] text-based mount command: fix mount option rewriting logic
Date: Thu, 08 Jan 2009 12:32:58 -0500
Message-ID: <20090108173258.19893.81986.stgit@ingres.1015granger.net>
References: <20090108172526.19893.91621.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:60508 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752197AbZAHRdd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jan 2009 12:33:33 -0500
In-Reply-To: <20090108172526.19893.91621.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix a bunch of corner cases in the text-based mount option rewriting logic.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |  113 ++++++++++++++++++++++++++++++++++---------------
 1 files changed, 79 insertions(+), 34 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 99be0f3..319be71 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -309,6 +309,81 @@ static int nfs_is_permanent_error(int error)
 	}
 }
 
+static int nfs_construct_new_options(struct mount_options *options,
+				     struct pmap *nfs_pmap,
+				     struct pmap *mnt_pmap)
+{
+	char new_option[64];
+
+	po_remove_all(options, "nfsprog");
+	po_remove_all(options, "mountprog");
+
+	po_remove_all(options, "v2");
+	po_remove_all(options, "v3");
+	po_remove_all(options, "vers");
+	po_remove_all(options, "nfsvers");
+	snprintf(new_option, sizeof(new_option) - 1,
+		 "vers=%lu", nfs_pmap->pm_vers);
+	if (po_append(options, new_option) == PO_FAILED)
+		return 0;
+
+	po_remove_all(options, "proto");
+	po_remove_all(options, "udp");
+	po_remove_all(options, "tcp");
+	switch (nfs_pmap->pm_prot) {
+	case IPPROTO_TCP:
+		snprintf(new_option, sizeof(new_option) - 1,
+			 "proto=tcp");
+		if (po_append(options, new_option) == PO_FAILED)
+			return 0;
+		break;
+	case IPPROTO_UDP:
+		snprintf(new_option, sizeof(new_option) - 1,
+			 "proto=udp");
+		if (po_append(options, new_option) == PO_FAILED)
+			return 0;
+		break;
+	}
+
+	po_remove_all(options, "port");
+	if (nfs_pmap->pm_port != NFS_PORT) {
+		snprintf(new_option, sizeof(new_option) - 1,
+			 "port=%lu", nfs_pmap->pm_port);
+		if (po_append(options, new_option) == PO_FAILED)
+			return 0;
+	}
+
+	po_remove_all(options, "mountvers");
+	snprintf(new_option, sizeof(new_option) - 1,
+		 "mountvers=%lu", mnt_pmap->pm_vers);
+	if (po_append(options, new_option) == PO_FAILED)
+		return 0;
+
+	po_remove_all(options, "mountproto");
+	switch (mnt_pmap->pm_prot) {
+	case IPPROTO_TCP:
+		snprintf(new_option, sizeof(new_option) - 1,
+			 "mountproto=tcp");
+		if (po_append(options, new_option) == PO_FAILED)
+			return 0;
+		break;
+	case IPPROTO_UDP:
+		snprintf(new_option, sizeof(new_option) - 1,
+			 "mountproto=udp");
+		if (po_append(options, new_option) == PO_FAILED)
+			return 0;
+		break;
+	}
+
+	po_remove_all(options, "mountport");
+	snprintf(new_option, sizeof(new_option) - 1,
+		 "mountport=%lu", mnt_pmap->pm_port);
+	if (po_append(options, new_option) == PO_FAILED)
+		return 0;
+
+	return 1;
+}
+
 /*
  * Reconstruct the mount option string based on a portmapper probe
  * of the server.  Returns one if the server's portmapper returned
@@ -325,7 +400,7 @@ static int nfs_is_permanent_error(int error)
 static struct mount_options *nfs_rewrite_mount_options(char *str)
 {
 	struct mount_options *options;
-	char *option, new_option[64];
+	char *option;
 	clnt_addr_t mnt_server = { };
 	clnt_addr_t nfs_server = { };
 
@@ -366,42 +441,12 @@ static struct mount_options *nfs_rewrite_mount_options(char *str)
 		goto err;
 	}
 
-	snprintf(new_option, sizeof(new_option) - 1,
-		 "nfsvers=%lu", nfs_server.pmap.pm_vers);
-	if (po_append(options, new_option) == PO_FAILED)
+	if (!nfs_construct_new_options(options,
+					&nfs_server.pmap, &mnt_server.pmap)) {
+		errno = EINVAL;
 		goto err;
-
-	if (nfs_server.pmap.pm_prot == IPPROTO_TCP)
-		snprintf(new_option, sizeof(new_option) - 1,
-			 "proto=tcp");
-	else
-		snprintf(new_option, sizeof(new_option) - 1,
-			 "proto=udp");
-	if (po_append(options, new_option) == PO_FAILED)
-		goto err;
-
-	if (nfs_server.pmap.pm_port != NFS_PORT) {
-		snprintf(new_option, sizeof(new_option) - 1,
-			 "port=%lu", nfs_server.pmap.pm_port);
-		if (po_append(options, new_option) == PO_FAILED)
-			goto err;
-
 	}
 
-	if (mnt_server.pmap.pm_prot == IPPROTO_TCP)
-		snprintf(new_option, sizeof(new_option) - 1,
-			 "mountproto=tcp");
-	else
-		snprintf(new_option, sizeof(new_option) - 1,
-			 "mountproto=udp");
-	if (po_append(options, new_option) == PO_FAILED)
-		goto err;
-
-	snprintf(new_option, sizeof(new_option) - 1,
-		 "mountport=%lu", mnt_server.pmap.pm_port);
-	if (po_append(options, new_option) == PO_FAILED)
-		goto err;
-
 	errno = 0;
 	return options;
 

