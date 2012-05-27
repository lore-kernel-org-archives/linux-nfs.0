Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pz0-f46.google.com ([209.85.210.46]:61075 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190Ab2E0FeA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 May 2012 01:34:00 -0400
Received: by dady13 with SMTP id y13so2849998dad.19
        for <linux-nfs@vger.kernel.org>; Sat, 26 May 2012 22:33:59 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Peng Tao <tao.peng@emc.com>
Subject: [PATCH 3/3] pnfsblock: bail out unaligned DIO
Date: Sun, 27 May 2012 13:33:00 +0800
Message-Id: <1338096780-2763-4-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1338096780-2763-1-git-send-email-bergwolf@gmail.com>
References: <1338096780-2763-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Peng Tao <tao.peng@emc.com>
---
 fs/nfs/blocklayout/blocklayout.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 53cb450..cdb87a9 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -1000,7 +1000,27 @@ static bool bl_dio_begin(struct inode *inode, const struct iovec *iov,
 			 unsigned long nr_segs, loff_t pos,
 			 struct blk_plug *plug)
 {
+	unsigned blkmask = NFS_SERVER(inode)->pnfs_blksize - 1;
+	size_t count;
+	int seg;
+	unsigned long addr;
+
 	blk_start_plug(plug);
+
+	/* Only allow blksized DIO for now.
+	 * In theory we can handle page aligned DIO in current block layout
+	 * read/write code, but it would require serialization between
+	 * concurrent writers and it is far less effecient than just send IO
+	 * to MDS.
+	 */
+	if (pos & blkmask)
+		return false;
+	for (seg = 0; seg < nr_segs; seg++) {
+		addr = (unsigned long)iov[seg].iov_base;
+		count = iov[seg].iov_len;
+		if (unlikely((addr & blkmask) || (count & blkmask)))
+			return false;
+	}
 	return true;
 }
 
-- 
1.7.1.262.g5ef3d

