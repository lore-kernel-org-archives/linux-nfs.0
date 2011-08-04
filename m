Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:35224 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751162Ab1HDEyl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Aug 2011 00:54:41 -0400
Message-ID: <4E3A2609.9050001@panasas.com>
Date: Wed, 3 Aug 2011 21:54:33 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] pnfs-obj: Bug when we are running out of bio
References: <1312082377.10882.1.camel@lade.trondhjem.org> <4E39DF02.80306@panasas.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A8AA600@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A8AA600@SACMVEXC2-PRD.hq.netapp.com>
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

CC: Stable Tree <stable@kernel.org>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 9383ca7..aa8663a 100644
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


