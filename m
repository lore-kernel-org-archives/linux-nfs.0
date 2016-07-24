Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35257 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515AbcGXVbt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jul 2016 17:31:49 -0400
Received: by mail-io0-f196.google.com with SMTP id q83so10786792iod.2
        for <linux-nfs@vger.kernel.org>; Sun, 24 Jul 2016 14:31:48 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 14/14] pNFS: Remove redundant smp_mb() from pnfs_init_lseg()
Date: Sun, 24 Jul 2016 17:30:59 -0400
Message-Id: <1469395859-83194-15-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1469395859-83194-14-git-send-email-trond.myklebust@primarydata.com>
References: <1469395859-83194-1-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-2-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-3-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-4-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-5-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-6-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-7-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-8-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-9-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-10-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-11-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-12-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-13-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-14-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's not visible yet, and won't be until after we grab the inode->i_lock.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 09b77a68422f..1d47a845d77a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -341,7 +341,6 @@ pnfs_init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg,
 	INIT_LIST_HEAD(&lseg->pls_list);
 	INIT_LIST_HEAD(&lseg->pls_lc_list);
 	atomic_set(&lseg->pls_refcount, 1);
-	smp_mb();
 	set_bit(NFS_LSEG_VALID, &lseg->pls_flags);
 	lseg->pls_layout = lo;
 	lseg->pls_range = *range;
-- 
2.7.4

