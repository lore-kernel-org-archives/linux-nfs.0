Return-Path: <dan.carpenter@oracle.com>
Date: Wed, 4 Jul 2018 12:59:58 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Trond Myklebust <trond.myklebust@hammerspace.com>,
        Christoph Hellwig <hch@lst.de>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Philippe Ombredanne <pombredanne@nexb.com>,
        Benjamin Coddington <bcodding@redhat.com>, linux-nfs@vger.kernel.org
Subject: [PATCH] pnfs/blocklayout: off by one in bl_map_stripe()
Message-ID: <20180704095957.bujo2izpjlcvjanb@kili.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
List-ID: <linux-nfs.vger.kernel.org>

"dev->nr_children" is the number of children which were parsed
successfully in bl_parse_stripe().  It could be all of them and then, in
that case, it is equal to v->stripe.volumes_count.  Either way, the >
should be >= so that we don't go beyond the end of what we're supposed
to.

Fixes: 5c83746a0cf2 ("pnfs/blocklayout: in-kernel GETDEVICEINFO XDR parsing")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
index a7efd83779d2..dec5880ac6de 100644
--- a/fs/nfs/blocklayout/dev.c
+++ b/fs/nfs/blocklayout/dev.c
@@ -204,7 +204,7 @@ static bool bl_map_stripe(struct pnfs_block_dev *dev, u64 offset,
 	chunk = div_u64(offset, dev->chunk_size);
 	div_u64_rem(chunk, dev->nr_children, &chunk_idx);
 
-	if (chunk_idx > dev->nr_children) {
+	if (chunk_idx >= dev->nr_children) {
 		dprintk("%s: invalid chunk idx %d (%lld/%lld)\n",
 			__func__, chunk_idx, offset, dev->chunk_size);
 		/* error, should not happen */
