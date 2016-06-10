Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:33090 "EHLO
	mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266AbcFJQGN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2016 12:06:13 -0400
Received: by mail-qt0-f195.google.com with SMTP id 72so2829146qtb.0
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jun 2016 09:06:12 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] NFSv4.1/pnfs: Add sparse lock annotations for pnfs_find_alloc_layout
Date: Fri, 10 Jun 2016 11:49:56 -0400
Message-Id: <1465573798-80118-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1465573798-80118-2-git-send-email-trond.myklebust@primarydata.com>
References: <1465573798-80118-1-git-send-email-trond.myklebust@primarydata.com>
 <1465573798-80118-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f619139621ec..ca488b52cbfb 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1298,6 +1298,8 @@ static struct pnfs_layout_hdr *
 pnfs_find_alloc_layout(struct inode *ino,
 		       struct nfs_open_context *ctx,
 		       gfp_t gfp_flags)
+	__releases(&ino->i_lock)
+	__acquires(&ino->i_lock)
 {
 	struct nfs_inode *nfsi = NFS_I(ino);
 	struct pnfs_layout_hdr *new = NULL;
-- 
2.5.5

