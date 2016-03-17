Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35242 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932508AbcCQVwT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Mar 2016 17:52:19 -0400
Date: Thu, 17 Mar 2016 17:52:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] nfsd: add SCSI layout support
Message-ID: <20160317215218.GB27078@fieldses.org>
References: <1457120777-30687-1-git-send-email-hch@lst.de>
 <1457120777-30687-5-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1457120777-30687-5-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 04, 2016 at 08:46:17PM +0100, Christoph Hellwig wrote:
> +int
> +nfsd4_scsi_decode_layoutupdate(__be32 *p, u32 len, struct iomap **iomapp,
> +		u32 block_size)
> +{
> +	struct iomap *iomaps;
> +	u32 nr_iomaps, expected, i;
> +
> +	if (len < sizeof(u32)) {
> +		dprintk("%s: extent array too small: %u\n", __func__, len);
> +		return -EINVAL;
> +	}
> +
> +	nr_iomaps = be32_to_cpup(p++);
> +	expected = sizeof(__be32) + nr_iomaps * PNFS_SCSI_RANGE_SIZE;
> +	if (len != expected) {

You could add any multiple of 2^32/PNFS_SCSI_RANGE_SIZE to nr_iomaps and
still pass this check.  Then you'd probably fail the following kcalloc,
but best to be paranoid if this is from-the-wire data.

Maybe something like this?  (Untested)

diff --git a/fs/nfsd/blocklayoutxdr.c b/fs/nfsd/blocklayoutxdr.c
index ca1883668810..6c3b316f932e 100644
--- a/fs/nfsd/blocklayoutxdr.c
+++ b/fs/nfsd/blocklayoutxdr.c
@@ -105,18 +105,22 @@ nfsd4_block_decode_layoutupdate(__be32 *p, u32 len, struct iomap **iomapp,
 		u32 block_size)
 {
 	struct iomap *iomaps;
-	u32 nr_iomaps, expected, i;
+	u32 nr_iomaps, i;
 
 	if (len < sizeof(u32)) {
 		dprintk("%s: extent array too small: %u\n", __func__, len);
 		return -EINVAL;
 	}
+	len -= sizeof(u32);
+	if (len % PNFS_BLOCK_EXTENT_SIZE) {
+		dprintk("%s: extent array invalid: %u\n", __func__, len);
+		return -EINVAL;
+	}
 
 	nr_iomaps = be32_to_cpup(p++);
-	expected = sizeof(__be32) + nr_iomaps * PNFS_BLOCK_EXTENT_SIZE;
-	if (len != expected) {
+	if (nr_iomaps != len / PNFS_BLOCK_EXTENT_SIZE) {
 		dprintk("%s: extent array size mismatch: %u/%u\n",
-			__func__, len, expected);
+			__func__, len, nr_iomaps);
 		return -EINVAL;
 	}
 
--b.
