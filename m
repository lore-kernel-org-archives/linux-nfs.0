Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34759 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755883AbcGFWau (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jul 2016 18:30:50 -0400
Received: by mail-io0-f194.google.com with SMTP id 100so908675ioh.1
        for <linux-nfs@vger.kernel.org>; Wed, 06 Jul 2016 15:30:49 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 13/28] pNFS: pnfs_layoutcommit_outstanding() is no longer used when !CONFIG_NFS_V4_1
Date: Wed,  6 Jul 2016 18:29:50 -0400
Message-Id: <1467844205-76852-14-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1467844205-76852-13-git-send-email-trond.myklebust@primarydata.com>
References: <1467844205-76852-1-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-2-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-3-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-4-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-5-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-6-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-7-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-8-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-9-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-10-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-11-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-12-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-13-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cleanup...

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.h | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index b21bd0bee784..d6be5299a55a 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -716,13 +716,6 @@ pnfs_use_threshold(struct nfs4_threshold **dst, struct nfs4_threshold *src,
 	return false;
 }
 
-static inline bool
-pnfs_layoutcommit_outstanding(struct inode *inode)
-{
-	return false;
-}
-
-
 static inline struct nfs4_threshold *pnfs_mdsthreshold_alloc(void)
 {
 	return NULL;
-- 
2.7.4

