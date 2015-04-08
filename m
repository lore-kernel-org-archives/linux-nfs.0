Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36073 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752835AbbDHMY2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Apr 2015 08:24:28 -0400
Received: by pabsx10 with SMTP id sx10so113283564pab.3
        for <linux-nfs@vger.kernel.org>; Wed, 08 Apr 2015 05:24:28 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>, <stable@vger.kernel.org>
Subject: [PATCH] nfs: fix DIO good bytes calculation
Date: Wed,  8 Apr 2015 20:24:10 +0800
Message-Id: <1428495850-7136-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When adding completed bytes, we should just use hdr->good_bytes.
Otherwise if we send multiple requests for one direct IO (due to
rsize/wsize limitation), we'll count completed bytes incorrectly.

This fixes 5fadeb47("nfs: count DIO good bytes correctly with mirroring").

Reported-by: Jean Spector <jean@primarydata.com>
Cc: <stable@vger.kernel.org> # v3.19+
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/direct.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index e907c8c..645109e 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -132,10 +132,8 @@ nfs_direct_good_bytes(struct nfs_direct_req *dreq, struct nfs_pgio_header *hdr)
 	WARN_ON_ONCE(hdr->pgio_mirror_idx >= dreq->mirror_count);
 
 	count = dreq->mirrors[hdr->pgio_mirror_idx].count;
-	if (count + dreq->io_start < hdr->io_start + hdr->good_bytes) {
-		count = hdr->io_start + hdr->good_bytes - dreq->io_start;
-		dreq->mirrors[hdr->pgio_mirror_idx].count = count;
-	}
+	if (count + dreq->io_start < hdr->io_start + hdr->good_bytes)
+		dreq->mirrors[hdr->pgio_mirror_idx].count += hdr->good_bytes;
 
 	/* update the dreq->count by finding the minimum agreed count from all
 	 * mirrors */
-- 
1.9.1

