Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:33726 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964AbcFIMVP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2016 08:21:15 -0400
Received: by mail-yw0-f193.google.com with SMTP id y6so4501401ywe.0
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jun 2016 05:21:15 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, anna.schumaker@netapp.com, trondmy@primarydata.com
Cc: tigran.mkrtchyan@desy.de, thomas.haynes@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/3] pnfs: add a new mechanism to select a layout driver according to an ordered list
Date: Thu,  9 Jun 2016 08:21:05 -0400
Message-Id: <1465474865-15285-4-git-send-email-jlayton@poochiereds.net>
In-Reply-To: <1465474865-15285-1-git-send-email-jlayton@poochiereds.net>
References: <1465474865-15285-1-git-send-email-jlayton@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, the layout driver selection code always chooses the first one
from the list. That's not really ideal however, as the server can send
the list of layout types in any order that it likes. It's up to the
client to select the best one for its needs.

This patch adds an ordered list of preferred driver types and has the
selection code sort the list of avaiable layout drivers according to it.
Any unrecognized layout type is sorted to the end of the list.

For now, the order of preference is hardcoded, but it should be possible
to make this configurable in the future.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/pnfs.c | 57 ++++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 50 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 2fc1b9354345..c31d30f1e5f2 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -99,6 +99,21 @@ unset_pnfs_layoutdriver(struct nfs_server *nfss)
 }
 
 /*
+ * When the server sends a list of layout types, we choose one in the order
+ * given in the list below.
+ *
+ * FIXME: should this list be configurable via module_param or mount option?
+ */
+static const u32 ld_prefs[] = {
+	LAYOUT_SCSI,
+	LAYOUT_BLOCK_VOLUME,
+	LAYOUT_OSD2_OBJECTS,
+	LAYOUT_FLEX_FILES,
+	LAYOUT_NFSV4_1_FILES,
+	0
+};
+
+/*
  * Try to set the server's pnfs module to the pnfs layout type specified by id.
  * Currently only one pNFS layout driver per filesystem is supported.
  *
@@ -110,6 +125,8 @@ set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
 {
 	struct pnfs_layoutdriver_type *ld_type = NULL;
 	u32 id;
+	int i, j;
+	bool swapped;
 
 	if (!(server->nfs_client->cl_exchange_flags &
 		 (EXCHGID4_FLAG_USE_NON_PNFS | EXCHGID4_FLAG_USE_PNFS_MDS))) {
@@ -118,18 +135,44 @@ set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
 		goto out_no_driver;
 	}
 
-	id = ids[0];
-	if (!id)
-		goto out_no_driver;
+	/* bubble sort into ld_prefs order */
+	do {
+		swapped = false;
+		for (i = 0; i < (NFS_MAX_LAYOUT_TYPES - 1); i++) {
 
-	ld_type = find_pnfs_driver(id);
-	if (!ld_type) {
-		request_module("%s-%u", LAYOUT_NFSV4_1_MODULE_PREFIX, id);
+			/* If either is zero then we're done with this pass */
+			if (ids[i] == 0 || ids[i + 1] == 0)
+				break;
+
+			for (j = 0; ld_prefs[j] != 0; j++) {
+				/* If we match left entry first, no swap */
+				if (ids[i] == ld_prefs[j])
+					break;
+
+				/* if we match the right, we need to swap */
+				if (ids[i + 1] == ld_prefs[j]) {
+					swap(ids[i], ids[i + 1]);
+					swapped = true;
+					break;
+				}
+			}
+		}
+	} while (swapped);
+
+	for (i = 0; i < NFS_MAX_LAYOUT_TYPES && ids[i] != 0; i++) {
+		id = ids[i];
 		ld_type = find_pnfs_driver(id);
+		if (!ld_type) {
+			request_module("%s-%u", LAYOUT_NFSV4_1_MODULE_PREFIX,
+					id);
+			ld_type = find_pnfs_driver(id);
+		}
+		if (ld_type)
+			break;
 	}
 
 	if (!ld_type) {
-		dprintk("%s: No pNFS module found for %u.\n", __func__, id);
+		dprintk("%s: No pNFS module found!\n", __func__);
 		goto out_no_driver;
 	}
 
-- 
2.5.5

