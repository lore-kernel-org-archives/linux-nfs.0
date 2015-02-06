Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f180.google.com ([209.85.213.180]:65116 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751438AbbBFC7o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2015 21:59:44 -0500
Received: by mail-ig0-f180.google.com with SMTP id b16so4666000igk.1
        for <linux-nfs@vger.kernel.org>; Thu, 05 Feb 2015 18:59:43 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH v2 4/5] NFSv4.1: pnfs_send_layoutreturn should use GFP_NOFS
Date: Thu,  5 Feb 2015 21:59:36 -0500
Message-Id: <1423191577-72230-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423191577-72230-3-git-send-email-trond.myklebust@primarydata.com>
References: <1423191577-72230-1-git-send-email-trond.myklebust@primarydata.com>
 <1423191577-72230-2-git-send-email-trond.myklebust@primarydata.com>
 <1423191577-72230-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In we want to be able to call pnfs_send_layoutreturn() from within the
writeback path, we really want it to use GFP_NOFS in order to prevent
recursion.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 703501d3ed19..a1d8620e8cb7 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -948,7 +948,7 @@ pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
 	struct nfs4_layoutreturn *lrp;
 	int status = 0;
 
-	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
+	lrp = kzalloc(sizeof(*lrp), GFP_NOFS);
 	if (unlikely(lrp == NULL)) {
 		status = -ENOMEM;
 		spin_lock(&ino->i_lock);
-- 
2.1.0

