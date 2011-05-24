Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47017 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752695Ab1EXPLB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 11:11:01 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 12/12] SQUASHME: objio read/write patch: Bugs fixes
Date: Tue, 24 May 2011 18:10:29 +0300
Message-Id: <1306249829-23523-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DDBC611.3050202@panasas.com>
References: <4DDBC611.3050202@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Cap BIO size it one page

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index bc5aa46..06bc032 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -561,6 +561,9 @@ static int _add_stripe_unit(struct objio_state *ios,  unsigned *cur_pg,
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

