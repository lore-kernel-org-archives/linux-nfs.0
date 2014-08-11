Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:35975 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752825AbaHKUEp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Aug 2014 16:04:45 -0400
Received: from [83.175.99.196] (helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XGvpk-0003NT-Rq
	for linux-nfs@vger.kernel.org; Mon, 11 Aug 2014 20:04:44 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] pnfs: add a nfs4_get_deviceid helper
Date: Mon, 11 Aug 2014 22:06:56 +0200
Message-Id: <1407787617-26050-4-git-send-email-hch@lst.de>
In-Reply-To: <1407787617-26050-1-git-send-email-hch@lst.de>
References: <1407787617-26050-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This will be used by the block layout driver when splitting extents.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/pnfs.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index ba468e2..c27fe18 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -277,6 +277,13 @@ void nfs4_deviceid_purge_client(const struct nfs_client *);
 int nfs4_deviceid_getdevicelist(struct nfs_server *server,
 		const struct nfs_fh *fh);
 
+static inline struct nfs4_deviceid_node *
+nfs4_get_deviceid(struct nfs4_deviceid_node *d)
+{
+	atomic_inc(&d->ref);
+	return d;
+}
+
 static inline struct pnfs_layout_segment *
 pnfs_get_lseg(struct pnfs_layout_segment *lseg)
 {
-- 
1.9.1

