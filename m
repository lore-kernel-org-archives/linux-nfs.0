Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35275 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751768AbbCVOQu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Mar 2015 10:16:50 -0400
Received: by pagj4 with SMTP id j4so71746989pag.2
        for <linux-nfs@vger.kernel.org>; Sun, 22 Mar 2015 07:16:50 -0700 (PDT)
Message-ID: <550ECEC8.5040406@gmail.com>
Date: Sun, 22 Mar 2015 22:16:40 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
Subject: [PATCH] NFSD: Printk blocklayout length and offset as format 0x%llx
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When testing pnfs with nfsd_debug on, nfsd print a negative number
of layout length and foff in nfsd4_block_proc_layoutget as, 
"GET: -xxxx:-xxx 2"

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/blocklayout.c    | 2 +-
 fs/nfsd/blocklayoutxdr.c | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
index cdbc78c..03d647b 100644
--- a/fs/nfsd/blocklayout.c
+++ b/fs/nfsd/blocklayout.c
@@ -137,7 +137,7 @@ nfsd4_block_proc_layoutget(struct inode *inode, const struct svc_fh *fhp,
 	seg->offset = iomap.offset;
 	seg->length = iomap.length;
 
-	dprintk("GET: %lld:%lld %d\n", bex->foff, bex->len, bex->es);
+	dprintk("GET: 0x%llx:0x%llx %d\n", bex->foff, bex->len, bex->es);
 	return 0;
 
 out_error:
diff --git a/fs/nfsd/blocklayoutxdr.c b/fs/nfsd/blocklayoutxdr.c
index 9da89fd..9aa2796 100644
--- a/fs/nfsd/blocklayoutxdr.c
+++ b/fs/nfsd/blocklayoutxdr.c
@@ -122,19 +122,19 @@ nfsd4_block_decode_layoutupdate(__be32 *p, u32 len, struct iomap **iomapp,
 
 		p = xdr_decode_hyper(p, &bex.foff);
 		if (bex.foff & (block_size - 1)) {
-			dprintk("%s: unaligned offset %lld\n",
+			dprintk("%s: unaligned offset 0x%llx\n",
 				__func__, bex.foff);
 			goto fail;
 		}
 		p = xdr_decode_hyper(p, &bex.len);
 		if (bex.len & (block_size - 1)) {
-			dprintk("%s: unaligned length %lld\n",
+			dprintk("%s: unaligned length 0x%llx\n",
 				__func__, bex.foff);
 			goto fail;
 		}
 		p = xdr_decode_hyper(p, &bex.soff);
 		if (bex.soff & (block_size - 1)) {
-			dprintk("%s: unaligned disk offset %lld\n",
+			dprintk("%s: unaligned disk offset 0x%llx\n",
 				__func__, bex.soff);
 			goto fail;
 		}
-- 
2.3.3

