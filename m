Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:37590 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634AbaICE0A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Sep 2014 00:26:00 -0400
Received: from [64.134.221.109] (helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XP28t-0003VP-D5
	for linux-nfs@vger.kernel.org; Wed, 03 Sep 2014 04:25:59 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] pnfs: add a nfs4_get_deviceid helper
Date: Tue,  2 Sep 2014 21:27:59 -0700
Message-Id: <1409718480-1529-4-git-send-email-hch@lst.de>
In-Reply-To: <1409718480-1529-1-git-send-email-hch@lst.de>
References: <1409718480-1529-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This will be used by the block layout driver when splitting extents.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/pnfs.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index bf4e87d..4746ede 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -279,6 +279,13 @@ void nfs4_deviceid_purge_client(const struct nfs_client *);
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

