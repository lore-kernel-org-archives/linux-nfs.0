Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:50251 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753435Ab1G3Gel (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Jul 2011 02:34:41 -0400
Message-ID: <4E33A5F6.8010803@panasas.com>
Date: Fri, 29 Jul 2011 23:34:30 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>, Jim Rees <rees@umich.edu>,
        Peng Tao <bergwolf@gmail.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 5/6] pnfs-obj: Bug when we are running out of bio
References: <4E33A288.80403@panasas.com>
In-Reply-To: <4E33A288.80403@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


When we have a situation that the number of pages we want
to encode is bigger then the size of the bio. (Which can
currently happen only when all IO is going to a single device
.e.g group_width==1) then the IO is submitted short and we
report back only the amount of bytes we actually wrote/read
and all is fine. BUT ...

There was a bug that the current length counter was advanced
before the fail to add the extra page, and we come to a situation
that the CDB length was one-page longer then the actual bio size,
which is of course rejected by the osd-target.

While here also fix the bio size calculation, in the case
that we received more then one group of devices.

[Needed in v3.0]
CC: Stable Tree <stable@kernel.org>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 8ff2ea3..9aa9d67 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -589,22 +589,19 @@ static void _calc_stripe_info(struct objio_state *ios, u64 file_offset,
 }
 
 static int _add_stripe_unit(struct objio_state *ios,  unsigned *cur_pg,
-		unsigned pgbase, struct _objio_per_comp *per_dev, int cur_len,
+		unsigned pgbase, struct _objio_per_comp *per_dev, int len,
 		gfp_t gfp_flags)
 {
 	unsigned pg = *cur_pg;
+	int cur_len = len;
 	struct request_queue *q =
 			osd_request_queue(_io_od(ios, per_dev->dev));
 
-	per_dev->length += cur_len;
-
 	if (per_dev->bio == NULL) {
-		unsigned stripes = ios->layout->num_comps /
-						     ios->layout->mirrors_p1;
-		unsigned pages_in_stripe = stripes *
+		unsigned pages_in_stripe = ios->layout->group_width *
 				      (ios->layout->stripe_unit / PAGE_SIZE);
 		unsigned bio_size = (ios->ol_state.nr_pages + pages_in_stripe) /
-				    stripes;
+				    ios->layout->group_width;
 
 		if (BIO_MAX_PAGES_KMALLOC < bio_size)
 			bio_size = BIO_MAX_PAGES_KMALLOC;
@@ -632,6 +629,7 @@ static int _add_stripe_unit(struct objio_state *ios,  unsigned *cur_pg,
 	}
 	BUG_ON(cur_len);
 
+	per_dev->length += len;
 	*cur_pg = pg;
 	return 0;
 }
-- 
1.7.6


