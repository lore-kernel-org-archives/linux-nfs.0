Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:51858 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760838Ab2FHMV1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jun 2012 08:21:27 -0400
Message-ID: <4FD1EE38.5080300@panasas.com>
Date: Fri, 8 Jun 2012 15:21:12 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
CC: Benny Halevy <bhalevy@tonian.com>, Peng Tao <bergwolf@gmail.com>
Subject: [PATCH 6/6] pnfs-obj: Better IO pattern in case of unaligned offset
References: <4FD1CEA8.3090105@panasas.com>
In-Reply-To: <4FD1CEA8.3090105@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Depending on layout and ARCH, ORE has some limits on max IO sizes
which is communicated on (what else) ore_layout->max_io_length,
which is always stripe aligned.
This was considered as the pg_test boundary for splitting and starting
a new IO.

But in the case of a long IO where the start offset is not aligned
what would happen is that both end of IO[N] and start of IO[N+1]
would be unaligned, causing each IO boundary parity unit to be
calculated and written twice.

So what we do in this patch is split the very start of an unaligned
IO, up to a stripe boundary, and then next IO's can continue fully
aligned til the end.

We might be sacrificing the case where the full unaligned IO would
fit within a single max_io_length, but the sacrifice is well worth
the elimination of double calculation and parity units IO.
Actually the sacrificing is marginal and is almost unmeasurable.

TODO:
	If we know the total expected linear segment that will
	be received, at pg_init, we could use that information
	in many places:
	1. blocks-layout get_layout write segment size
	2. Better mds-threshold
	3. In above situation for a better clean split

	I will do this in future submission.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c | 55 +++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 52 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 422bdef..5f8c4f3 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -576,17 +576,66 @@ static bool objio_pg_test(struct nfs_pageio_descriptor *pgio,
 		return false;
 
 	return pgio->pg_count + req->wb_bytes <=
-			OBJIO_LSEG(pgio->pg_lseg)->layout.max_io_length;
+			(unsigned long)pgio->pg_layout_private;
+}
+
+void objio_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
+{
+	pnfs_generic_pg_init_read(pgio, req);
+	if (unlikely(pgio->pg_lseg == NULL))
+		return; /* Not pNFS */
+
+	pgio->pg_layout_private = (void *)
+				OBJIO_LSEG(pgio->pg_lseg)->layout.max_io_length;
+}
+
+static bool aligned_on_raid_stripe(u64 offset, struct ore_layout *layout,
+				   unsigned long *stripe_end)
+{
+	u32 stripe_off;
+	unsigned stripe_size;
+
+	if (layout->raid_algorithm == PNFS_OSD_RAID_0)
+		return true;
+
+	stripe_size = layout->stripe_unit *
+				(layout->group_width - layout->parity);
+
+	div_u64_rem(offset, stripe_size, &stripe_off);
+	if (!stripe_off)
+		return true;
+
+	*stripe_end = stripe_size - stripe_off;
+	return false;
+}
+
+void objio_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
+{
+	unsigned long stripe_end = 0;
+
+	pnfs_generic_pg_init_write(pgio, req);
+	if (unlikely(pgio->pg_lseg == NULL))
+		return; /* Not pNFS */
+
+	if (req->wb_offset ||
+	    !aligned_on_raid_stripe(req->wb_index * PAGE_SIZE,
+			       &OBJIO_LSEG(pgio->pg_lseg)->layout,
+			       &stripe_end)) {
+		pgio->pg_layout_private = (void *)stripe_end;
+	} else {
+		pgio->pg_layout_private = (void *)
+				OBJIO_LSEG(pgio->pg_lseg)->layout.max_io_length;
+	}
 }
 
 static const struct nfs_pageio_ops objio_pg_read_ops = {
-	.pg_init = pnfs_generic_pg_init_read,
+	.pg_init = objio_init_read,
 	.pg_test = objio_pg_test,
 	.pg_doio = pnfs_generic_pg_readpages,
 };
 
 static const struct nfs_pageio_ops objio_pg_write_ops = {
-	.pg_init = pnfs_generic_pg_init_write,
+	.pg_init = objio_init_write,
 	.pg_test = objio_pg_test,
 	.pg_doio = pnfs_generic_pg_writepages,
 };
-- 
1.7.10.2.677.gb6bc67f


