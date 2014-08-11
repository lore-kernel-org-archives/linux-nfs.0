Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:35974 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754765AbaHKUEo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Aug 2014 16:04:44 -0400
Received: from [83.175.99.196] (helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XGvpj-0003NP-QU
	for linux-nfs@vger.kernel.org; Mon, 11 Aug 2014 20:04:43 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] pnfs add a common GETDEVICELIST implementation
Date: Mon, 11 Aug 2014 22:06:55 +0200
Message-Id: <1407787617-26050-3-git-send-email-hch@lst.de>
In-Reply-To: <1407787617-26050-1-git-send-email-hch@lst.de>
References: <1407787617-26050-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At a simple helper to issue a GETDEVICELIST operation and pre-load
the device id cache based on the result.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/pnfs.h     |  2 ++
 fs/nfs/pnfs_dev.c | 28 ++++++++++++++++++++++++++++
 2 files changed, 30 insertions(+)

diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index e145b79..ba468e2 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -274,6 +274,8 @@ bool nfs4_put_deviceid_node(struct nfs4_deviceid_node *);
 void nfs4_mark_deviceid_unavailable(struct nfs4_deviceid_node *node);
 bool nfs4_test_deviceid_unavailable(struct nfs4_deviceid_node *node);
 void nfs4_deviceid_purge_client(const struct nfs_client *);
+int nfs4_deviceid_getdevicelist(struct nfs_server *server,
+		const struct nfs_fh *fh);
 
 static inline struct pnfs_layout_segment *
 pnfs_get_lseg(struct pnfs_layout_segment *lseg)
diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index e3d4fa9..a30e6b2 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -356,3 +356,31 @@ nfs4_deviceid_mark_client_invalid(struct nfs_client *clp)
 	rcu_read_unlock();
 }
 
+int
+nfs4_deviceid_getdevicelist(struct nfs_server *server,
+		const struct nfs_fh *fh)
+{
+	struct pnfs_devicelist *dlist;
+	struct nfs4_deviceid_node *d;
+	int error = 0, i;
+
+	dlist = kzalloc(sizeof(struct pnfs_devicelist), GFP_NOFS);
+	if (!dlist)
+		return -ENOMEM;
+
+	while (!dlist->eof) {
+		error = nfs4_proc_getdevicelist(server, fh, dlist);
+		if (error)
+			break;
+
+		for (i = 0; i < dlist->num_devs; i++) {
+			d = nfs4_find_get_deviceid(server, &dlist->dev_id[i],
+					NULL, GFP_NOFS);
+			if (d)
+				nfs4_put_deviceid_node(d);
+		}
+	}
+
+	return error;
+}
+EXPORT_SYMBOL_GPL(nfs4_deviceid_getdevicelist);
-- 
1.9.1

