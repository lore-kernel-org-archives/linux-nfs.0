Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f42.google.com ([209.85.220.42]:48211 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754039AbaKEOhz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2014 09:37:55 -0500
Received: by mail-pa0-f42.google.com with SMTP id bj1so897754pad.15
        for <linux-nfs@vger.kernel.org>; Wed, 05 Nov 2014 06:37:55 -0800 (PST)
From: Peng Tao <tao.peng@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH v2] nfs: fix pnfs direct write memory leak
Date: Wed,  5 Nov 2014 22:36:50 +0800
Message-Id: <1415198213-20094-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For pNFS direct writes, layout driver may dynamically allocate ds_cinfo.buckets.
So we need to take care to free them when freeing dreq.

Ideally this needs to be done inside layout driver where ds_cinfo.buckets
are allocated. But buckets are attached to dreq and reused across LD IO iterations.
So I feel it's OK to free them in the generic layer.

Cc: stable@vger.kernel.org [v3.4+]
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/direct.c         | 1 +
 include/linux/nfs_xdr.h | 9 +++++++++
 2 files changed, 10 insertions(+)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 20cffc8..10bf072 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -266,6 +266,7 @@ static void nfs_direct_req_free(struct kref *kref)
 {
 	struct nfs_direct_req *dreq = container_of(kref, struct nfs_direct_req, kref);
 
+	nfs_free_pnfs_ds_cinfo(&dreq->ds_cinfo);
 	if (dreq->l_ctx != NULL)
 		nfs_put_lock_context(dreq->l_ctx);
 	if (dreq->ctx != NULL)
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 983876f..10dee95 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1224,11 +1224,20 @@ struct nfs41_free_stateid_res {
 	unsigned int			status;
 };
 
+static inline void
+nfs_free_pnfs_ds_cinfo(struct pnfs_ds_commit_info *cinfo)
+{
+	kfree(cinfo->buckets);
+}
+
 #else
 
 struct pnfs_ds_commit_info {
 };
 
+static inline void
+nfs_free_pnfs_ds_cinfo(struct pnfs_ds_commit_info *cinfo) {}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 #ifdef CONFIG_NFS_V4_2
-- 
1.9.1

