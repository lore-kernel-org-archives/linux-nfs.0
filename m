Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33281 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753554AbbDIPFS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Apr 2015 11:05:18 -0400
Received: by paboj16 with SMTP id oj16so152600386pab.0
        for <linux-nfs@vger.kernel.org>; Thu, 09 Apr 2015 08:05:18 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>, <stable@vger.kernel.org>,
        Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH v2 2/2] nfs: remove WARN_ON_ONCE from nfs_direct_good_bytes
Date: Thu,  9 Apr 2015 23:02:17 +0800
Message-Id: <1428591737-19071-2-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1428591737-19071-1-git-send-email-tao.peng@primarydata.com>
References: <1428591737-19071-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For flexfiles driver, we might choose to read from mirror index other
than 0 while mirror_count is always 1 for read.

Reported-by: Jean Spector <jean@primarydata.com>
Cc: <stable@vger.kernel.org> # v3.19+
Cc: Weston Andros Adamson <dros@primarydata.com>
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
This is updated due to conflict with patch 1/2.
 fs/nfs/direct.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 5e451a7..ab21ef1 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -129,8 +129,6 @@ nfs_direct_good_bytes(struct nfs_direct_req *dreq, struct nfs_pgio_header *hdr)
 	int i;
 	ssize_t count;
 
-	WARN_ON_ONCE(hdr->pgio_mirror_idx >= dreq->mirror_count);
-
 	if (dreq->mirror_count == 1) {
 		dreq->mirrors[hdr->pgio_mirror_idx].count += hdr->good_bytes;
 		dreq->count += hdr->good_bytes;
-- 
1.9.1

