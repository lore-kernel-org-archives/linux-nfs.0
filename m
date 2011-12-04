Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:45461 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753679Ab1LDNuh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2011 08:50:37 -0500
Received: by mail-ey0-f174.google.com with SMTP id k14so3593300eaa.19
        for <linux-nfs@vger.kernel.org>; Sun, 04 Dec 2011 05:50:36 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 13/13] DEBUG: pnfsblock: add devid debug printouts
Date: Sun,  4 Dec 2011 15:50:31 +0200
Message-Id: <1323006631-13963-1-git-send-email-benny@tonian.com>
In-Reply-To: <4EDB79A9.2080109@tonian.com>
References: <4EDB79A9.2080109@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfs/blocklayout/blocklayout.c    |    4 +++-
 fs/nfs/blocklayout/blocklayoutdev.c |   14 ++++++++++----
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 3fdfb29..b6068f8 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -900,7 +900,9 @@ static void free_blk_mountid(struct block_mount_id *mid)
 	dev->pglen = PAGE_SIZE * max_pages;
 	dev->mincount = 0;
 
-	dprintk("%s: dev_id: %s\n", __func__, dev->dev_id.data);
+	dprintk("%s: dev_id: (%x:%x:%x:%x)\n", __func__,
+		((unsigned *)dev->dev_id.data)[0], ((unsigned *)dev->dev_id.data)[1],
+		((unsigned *)dev->dev_id.data)[2], ((unsigned *)dev->dev_id.data)[3]);
 	rc = nfs4_proc_getdeviceinfo(server, dev);
 	dprintk("%s getdevice info returns %d\n", __func__, rc);
 	if (rc) {
diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index d08ba91..34f97c9 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -122,7 +122,9 @@ struct pnfs_block_dev *
 	int offset, len, i, rc;
 
 	dprintk("%s CREATING PIPEFS MESSAGE\n", __func__);
-	dprintk("%s: deviceid: %s, mincount: %d\n", __func__, dev->dev_id.data,
+	dprintk("%s: dev_id: (%x:%x:%x:%x), mincount: %d\n", __func__,
+		((unsigned *)dev->dev_id.data)[0], ((unsigned *)dev->dev_id.data)[1],
+		((unsigned *)dev->dev_id.data)[2], ((unsigned *)dev->dev_id.data)[3],
 		dev->mincount);
 
 	memset(&msg, 0, sizeof(msg));
@@ -181,10 +183,12 @@ struct pnfs_block_dev *
 
 	rv->bm_mdev = bd;
 	memcpy(&rv->bm_mdevid, &dev->dev_id, sizeof(struct nfs4_deviceid));
-	dprintk("%s Created device %s with bd_block_size %u\n",
+	dprintk("%s Created device %s with bd_block_size %u dev_id (%x:%x:%x:%x)\n",
 		__func__,
 		bd->bd_disk->disk_name,
-		bd->bd_block_size);
+		bd->bd_block_size,
+		((unsigned *)rv->bm_mdevid.data)[0], ((unsigned *)rv->bm_mdevid.data)[1],
+		((unsigned *)rv->bm_mdevid.data)[2], ((unsigned *)rv->bm_mdevid.data)[3]);
 
 out:
 	kfree(msg.data);
@@ -199,7 +203,9 @@ struct pnfs_block_dev *
 	struct block_mount_id *mid;
 	struct pnfs_block_dev *dev;
 
-	dprintk("%s enter, lo=%p, id=%p\n", __func__, lo, id);
+	dprintk("%s enter, lo=%p, id=%p dev_id=(%x:%x:%x:%x)\n", __func__, lo, id,
+		((unsigned *)id->data)[0], ((unsigned *)id->data)[1],
+		((unsigned *)id->data)[2], ((unsigned *)id->data)[3]);
 	mid = BLK_ID(lo);
 	spin_lock(&mid->bm_lock);
 	list_for_each_entry(dev, &mid->bm_devlist, bm_node) {
-- 
1.7.6

