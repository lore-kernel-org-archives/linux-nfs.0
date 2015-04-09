Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35602 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753397AbbDIPFM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Apr 2015 11:05:12 -0400
Received: by pabtp1 with SMTP id tp1so46823520pab.2
        for <linux-nfs@vger.kernel.org>; Thu, 09 Apr 2015 08:05:12 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>, <stable@vger.kernel.org>
Subject: [PATCH v2 1/2] nfs: fix DIO good bytes calculation
Date: Thu,  9 Apr 2015 23:02:16 +0800
Message-Id: <1428591737-19071-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For direct read that has IO size larger than rsize, we'll split
it into several READ requests and nfs_direct_good_bytes() would
count completed bytes incorrectly by eating last zero count reply.

Fix it by handling mirror and non-mirror cases differently such that
we only count mirrored writes differently.

This fixes 5fadeb47("nfs: count DIO good bytes correctly with mirroring").

Reported-by: Jean Spector <jean@primarydata.com>
Cc: <stable@vger.kernel.org> # v3.19+
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/direct.c | 29 +++++++++++++++++------------
 1 file changed, 17 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index e907c8c..5e451a7 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -131,20 +131,25 @@ nfs_direct_good_bytes(struct nfs_direct_req *dreq, struct nfs_pgio_header *hdr)
 
 	WARN_ON_ONCE(hdr->pgio_mirror_idx >= dreq->mirror_count);
 
-	count = dreq->mirrors[hdr->pgio_mirror_idx].count;
-	if (count + dreq->io_start < hdr->io_start + hdr->good_bytes) {
-		count = hdr->io_start + hdr->good_bytes - dreq->io_start;
-		dreq->mirrors[hdr->pgio_mirror_idx].count = count;
-	}
-
-	/* update the dreq->count by finding the minimum agreed count from all
-	 * mirrors */
-	count = dreq->mirrors[0].count;
+	if (dreq->mirror_count == 1) {
+		dreq->mirrors[hdr->pgio_mirror_idx].count += hdr->good_bytes;
+		dreq->count += hdr->good_bytes;
+	} else {
+		/* mirrored writes */
+		count = dreq->mirrors[hdr->pgio_mirror_idx].count;
+		if (count + dreq->io_start < hdr->io_start + hdr->good_bytes) {
+			count = hdr->io_start + hdr->good_bytes - dreq->io_start;
+			dreq->mirrors[hdr->pgio_mirror_idx].count = count;
+		}
+		/* update the dreq->count by finding the minimum agreed count from all
+		 * mirrors */
+		count = dreq->mirrors[0].count;
 
-	for (i = 1; i < dreq->mirror_count; i++)
-		count = min(count, dreq->mirrors[i].count);
+		for (i = 1; i < dreq->mirror_count; i++)
+			count = min(count, dreq->mirrors[i].count);
 
-	dreq->count = count;
+		dreq->count = count;
+	}
 }
 
 /*
-- 
1.9.1

