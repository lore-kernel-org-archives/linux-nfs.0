Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:37917 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757985Ab1EZTM3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 May 2011 15:12:29 -0400
Message-ID: <4DDEA620.2000908@panasas.com>
Date: Thu, 26 May 2011 22:12:32 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: [PATCH resend3] SQUASHME: objio read/write patch: Bugs fixes
References: <4DDD7392.6040505@panasas.com> <1306358945-17555-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <1306358945-17555-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Cap BIO size it one page

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 6925567..cc92d3b 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -397,7 +397,6 @@ int objio_alloc_io_state(struct pnfs_layout_segment *lseg,
 	const unsigned first_size = sizeof(*ios) +
 				objio_seg->num_comps * sizeof(ios->per_dev[0]);
 
-	dprintk("%s: num_comps=%d\n", __func__, objio_seg->num_comps);
 	ios = kzalloc(first_size, gfp_flags);
 	if (unlikely(!ios))
 		return -ENOMEM;
@@ -561,6 +560,9 @@ static int _add_stripe_unit(struct objio_state *ios,  unsigned *cur_pg,
 		unsigned bio_size = (ios->ol_state.nr_pages + pages_in_stripe) /
 				    stripes;
 
+		if (BIO_MAX_PAGES_KMALLOC < bio_size)
+			bio_size = BIO_MAX_PAGES_KMALLOC;
+
 		per_dev->bio = bio_kmalloc(gfp_flags, bio_size);
 		if (unlikely(!per_dev->bio)) {
 			dprintk("Faild to allocate BIO size=%u\n", bio_size);
-- 
1.7.2.3


