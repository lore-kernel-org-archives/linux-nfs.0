Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:34110 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751036Ab1H3DXQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Aug 2011 23:23:16 -0400
Message-ID: <4E5C5785.4090607@panasas.com>
Date: Mon, 29 Aug 2011 20:22:45 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>,
        Benny Halevy <benny@tonian.com>
Subject: [RFC] pnfs: Add per-LD-info to nfs_pageio_descriptor
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


What do you guys think? would it be acceptable to add a per-layout
private-data to nfs_pageio_descriptor?

In obj-LD we have bunch of constrains on the size of the IO that
involves some 64bit divisions, and math. These calculations are only
needed to be preformed once when the offset of the first page is
known. Then a simple wb_bytes can cache the results for subsequent
calls. (And cannot be calculated before we know the IO's offset)

Also I might want to allocate the io_state earlier at the insert
of the first page instead of at the actual call to write/read_pagelist,
again, for the same reason above.

Today we get by because at the very end, if some constraints hit
and not the full IO was preformed then we only set r/wdata->res.count
to less then what was requested and these pages that are outside of
the IOed range get to be read/written as part of a future request. But
this is sub-optimal because that is done only at read/write_done time.
By then the contiguous pages were already submitted to requests and
the few left-over pages get submitted as their own request. This causes
a seeky, unaligned and additional small IOs which, if calculated for at
coalesce time, would be spared. With the up coming raid5/6 code this
can cost dearly. (A single simple large contiguous IO becomes bunch of
read-modify-write IOs)

I can see that also at filelayout_pg_test there are two 64bit divisions
preformed on every page insert which could be optimized to a simple
compare.

[BTW: Perhaps change the .write/read_pagelist() API to directly receive
 the nfs_pageio_descriptor and avoid all the duplication of types and
 members copy
]

I'm making pg_ld_private as a "long" because a long is good for a pointer
as well as an integer.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

---
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index e2791a2..c86bae5 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -77,6 +77,7 @@ struct nfs_pageio_descriptor {
 	int			pg_error;
 	const struct rpc_call_ops *pg_rpc_callops;
 	struct pnfs_layout_segment *pg_lseg;
+	long pg_ld_private;
 };
 
 #define NFS_WBACK_BUSY(req)	(test_bit(PG_BUSY,&(req)->wb_flags))
