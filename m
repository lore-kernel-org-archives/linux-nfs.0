Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:34674 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752074Ab1EPQWo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2011 12:22:44 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, bharrosh@panasas.com
Subject: [PATCH v3 15/29] pnfs: set/unset layoutdriver
Date: Mon, 16 May 2011 09:22:41 -0700
Message-Id: <1305562961-7846-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DD14D8E.1070701@panasas.com>
References: <4DD14D8E.1070701@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

For managing per nfs_server layout driver data

[was: pass mntfh down the init_pnfs path]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |   13 ++++++++++++-
 fs/nfs/pnfs.h |    4 ++++
 2 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index dcf04ea..3ac7b82 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -75,8 +75,11 @@ find_pnfs_driver(u32 id)
 void
 unset_pnfs_layoutdriver(struct nfs_server *nfss)
 {
-	if (nfss->pnfs_curr_ld)
+	if (nfss->pnfs_curr_ld) {
+		if (nfss->pnfs_curr_ld->unset_layoutdriver)
+			nfss->pnfs_curr_ld->unset_layoutdriver(nfss);
 		module_put(nfss->pnfs_curr_ld->owner);
+	}
 	nfss->pnfs_curr_ld = NULL;
 }
 
@@ -115,6 +118,14 @@ set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
 	}
 	server->pnfs_curr_ld = ld_type;
 
+	if (ld_type->set_layoutdriver &&
+	    ld_type->set_layoutdriver(server)) {
+		dprintk("%s: Error initializing mount point for layout driver %u.\n",
+		       __func__, id);
+		module_put(ld_type->owner);
+		goto out_no_driver;
+	}
+
 	dprintk("%s: pNFS module for %u set\n", __func__, id);
 	return;
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 006314e..9d620de 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -71,6 +71,10 @@ struct pnfs_layoutdriver_type {
 	const u32 id;
 	const char *name;
 	struct module *owner;
+
+	int (*set_layoutdriver) (struct nfs_server *);
+	int (*unset_layoutdriver) (struct nfs_server *);
+
 	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_hdr *layoutid, struct nfs4_layoutget_res *lgr);
 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
 
-- 
1.7.3.4

