Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33805 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbcEYFJr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2016 01:09:47 -0400
Received: by mail-pa0-f45.google.com with SMTP id qo8so13897860pab.1
        for <linux-nfs@vger.kernel.org>; Tue, 24 May 2016 22:09:47 -0700 (PDT)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
Subject: [PATCH 2/4] nfsd: Can leak pnfs_block_extent on error
Date: Tue, 24 May 2016 22:09:37 -0700
Message-Id: <1464152979-103988-3-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1464152979-103988-1-git-send-email-loghyr@primarydata.com>
References: <1464152979-103988-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfsd/blocklayout.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
index 248adb6..9a195f1 100644
--- a/fs/nfsd/blocklayout.c
+++ b/fs/nfsd/blocklayout.c
@@ -23,7 +23,7 @@ nfsd4_block_proc_layoutget(struct inode *inode, const struct svc_fh *fhp,
 	struct nfsd4_layout_seg *seg = &args->lg_seg;
 	struct super_block *sb = inode->i_sb;
 	u32 block_size = (1 << inode->i_blkbits);
-	struct pnfs_block_extent *bex;
+	struct pnfs_block_extent *bex = NULL;
 	struct iomap iomap;
 	u32 device_generation = 0;
 	int error;
@@ -105,9 +105,11 @@ nfsd4_block_proc_layoutget(struct inode *inode, const struct svc_fh *fhp,
 	return 0;
 
 out_error:
+	kfree(bex);
 	seg->length = 0;
 	return nfserrno(error);
 out_layoutunavailable:
+	kfree(bex);
 	seg->length = 0;
 	return nfserr_layoutunavailable;
 }
-- 
1.8.3.1

