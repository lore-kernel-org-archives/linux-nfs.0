Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:35561 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753841AbbDHOmE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Apr 2015 10:42:04 -0400
Received: by pddn5 with SMTP id n5so117561215pdd.2
        for <linux-nfs@vger.kernel.org>; Wed, 08 Apr 2015 07:42:04 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>,
        Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH] nfs: remove WARN_ON_ONCE from nfs_direct_good_bytes
Date: Wed,  8 Apr 2015 22:41:23 +0800
Message-Id: <1428504083-8227-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For flexfiles driver, we might choose to read from mirror index other
than 0 while mirror_count is always 1 for read.

Reported-by: Jean Spector <jean@primarydata.com>
Cc: Weston Andros Adamson <dros@primarydata.com>
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/direct.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 645109e..0c84f67 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -129,8 +129,6 @@ nfs_direct_good_bytes(struct nfs_direct_req *dreq, struct nfs_pgio_header *hdr)
 	int i;
 	ssize_t count;
 
-	WARN_ON_ONCE(hdr->pgio_mirror_idx >= dreq->mirror_count);
-
 	count = dreq->mirrors[hdr->pgio_mirror_idx].count;
 	if (count + dreq->io_start < hdr->io_start + hdr->good_bytes)
 		dreq->mirrors[hdr->pgio_mirror_idx].count += hdr->good_bytes;
-- 
1.9.1

