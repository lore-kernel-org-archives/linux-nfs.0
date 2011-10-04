Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:52114 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755594Ab1JDKbu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Oct 2011 06:31:50 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>, Brent Welch <welch@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 07/19] ore: Remove check for ios->kern_buff in _prepare_for_striping to later
Date: Tue, 4 Oct 2011 12:31:40 +0200
Message-ID: <1317724300-27513-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4E8ADEDA.4050709@panasas.com>
References: <4E8ADEDA.4050709@panasas.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Move the check and preparation of the ios->kern_buff case to
later inside _write_mirror().

Since read was never used with ios->kern_buff its support is removed
instead of fixed.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/ore.c |   36 +++++++++++++-----------------------
 1 files changed, 13 insertions(+), 23 deletions(-)

diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index 43a53ba..2f39f23 100644
--- a/fs/exofs/ore.c
+++ b/fs/exofs/ore.c
@@ -428,17 +428,6 @@ static int _prepare_for_striping(struct ore_io_state *ios)
 	int ret = 0;
 
 	if (!ios->pages) {
-		if (ios->kern_buff) {
-			struct ore_per_dev_state *per_dev = &ios->per_dev[0];
-
-			per_dev->offset = si->obj_offset;
-			per_dev->dev = si->dev;
-
-			/* no cross device without page array */
-			BUG_ON((ios->layout->group_width > 1) &&
-			       (si->unit_off + ios->length >
-				ios->layout->stripe_unit));
-		}
 		ios->numdevs = ios->layout->mirrors_p1;
 		return 0;
 	}
@@ -561,7 +550,6 @@ static int _write_mirror(struct ore_io_state *ios, int cur_comp)
 			goto out;
 		}
 		per_dev->or = or;
-		per_dev->offset = master_dev->offset;
 
 		if (ios->pages) {
 			struct bio *bio;
@@ -580,6 +568,7 @@ static int _write_mirror(struct ore_io_state *ios, int cur_comp)
 				__bio_clone(bio, master_dev->bio);
 				bio->bi_bdev = NULL;
 				bio->bi_next = NULL;
+				per_dev->offset = master_dev->offset;
 				per_dev->length = master_dev->length;
 				per_dev->bio =  bio;
 				per_dev->dev = dev;
@@ -597,7 +586,15 @@ static int _write_mirror(struct ore_io_state *ios, int cur_comp)
 				     _LLU(per_dev->offset),
 				     _LLU(per_dev->length), dev);
 		} else if (ios->kern_buff) {
-			ret = osd_req_write_kern(or, _ios_obj(ios, dev),
+			per_dev->offset = ios->si.obj_offset;
+			per_dev->dev = ios->si.dev + dev;
+
+			/* no cross device without page array */
+			BUG_ON((ios->layout->group_width > 1) &&
+			       (ios->si.unit_off + ios->length >
+				ios->layout->stripe_unit));
+
+			ret = osd_req_write_kern(or, _ios_obj(ios, per_dev->dev),
 						 per_dev->offset,
 						 ios->kern_buff, ios->length);
 			if (unlikely(ret))
@@ -606,7 +603,7 @@ static int _write_mirror(struct ore_io_state *ios, int cur_comp)
 				      "length=0x%llx dev=%d\n",
 				     _LLU(_ios_obj(ios, dev)->id),
 				     _LLU(per_dev->offset),
-				     _LLU(ios->length), dev);
+				     _LLU(ios->length), per_dev->dev);
 		} else {
 			osd_req_set_attributes(or, _ios_obj(ios, dev));
 			ORE_DBGMSG2("obj(0x%llx) set_attributes=%d dev=%d\n",
@@ -672,16 +669,9 @@ static int _read_mirror(struct ore_io_state *ios, unsigned cur_comp)
 			     " dev=%d\n", _LLU(obj->id),
 			     _LLU(per_dev->offset), _LLU(per_dev->length),
 			     first_dev);
-	} else if (ios->kern_buff) {
-		int ret = osd_req_read_kern(or, obj, per_dev->offset,
-					    ios->kern_buff, ios->length);
-		ORE_DBGMSG2("read_kern(0x%llx) offset=0x%llx "
-			      "length=0x%llx dev=%d ret=>%d\n",
-			      _LLU(obj->id), _LLU(per_dev->offset),
-			      _LLU(ios->length), first_dev, ret);
-		if (unlikely(ret))
-			return ret;
 	} else {
+		BUG_ON(ios->kern_buff);
+
 		osd_req_get_attributes(or, obj);
 		ORE_DBGMSG2("obj(0x%llx) get_attributes=%d dev=%d\n",
 			      _LLU(obj->id),
-- 
1.7.2.3

