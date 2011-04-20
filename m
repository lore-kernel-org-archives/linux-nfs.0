Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:57143 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755493Ab1DTR1h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 13:27:37 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC 10/27] pnfs: {,un}set_layoutdriver methods
Date: Wed, 20 Apr 2011 20:27:33 +0300
Message-Id: <1303320453-21332-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DAF0DE1.6020609@panasas.com>
References: <4DAF0DE1.6020609@panasas.com>
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
index 18ae397..afc64b3 100644
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
index 18b84ce..bb266ba 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -79,6 +79,10 @@ struct pnfs_layoutdriver_type {
 	const char *name;
 	struct module *owner;
 	unsigned flags;
+
+	int (*set_layoutdriver) (struct nfs_server *);
+	int (*unset_layoutdriver) (struct nfs_server *);
+
 	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_hdr *layoutid, struct nfs4_layoutget_res *lgr);
 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
 
-- 
1.7.3.4

