Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:46008 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497Ab1E2Kai (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 06:30:38 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 3/8] SQUASHME: objio read/write patch: Bugs fixes
Date: Sun, 29 May 2011 13:30:28 +0300
Message-Id: <1306665028-1033-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DE21CD5.8070907@panasas.com>
References: <4DE21CD5.8070907@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
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

