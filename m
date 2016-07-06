Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35585 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932298AbcGFWav (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jul 2016 18:30:51 -0400
Received: by mail-it0-f67.google.com with SMTP id g4so900336ith.2
        for <linux-nfs@vger.kernel.org>; Wed, 06 Jul 2016 15:30:51 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 15/28] NFS: Ensure we reset the write verifier 'committed' value on resend.
Date: Wed,  6 Jul 2016 18:29:52 -0400
Message-Id: <1467844205-76852-16-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1467844205-76852-15-git-send-email-trond.myklebust@primarydata.com>
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
 <1467844205-76852-14-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-15-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/direct.c   |  2 ++
 fs/nfs/internal.h | 17 +++++++++++++++++
 2 files changed, 19 insertions(+)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index d6d43b5eafb3..fb659bb50678 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -661,6 +661,8 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 	nfs_direct_write_scan_commit_list(dreq->inode, &reqs, &cinfo);
 
 	dreq->count = 0;
+	dreq->verf.committed = NFS_INVALID_STABLE_HOW;
+	nfs_clear_pnfs_ds_commit_verifiers(&dreq->ds_cinfo);
 	for (i = 0; i < dreq->mirror_count; i++)
 		dreq->mirrors[i].count = 0;
 	get_dreq(dreq);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 150a8eb0f323..0eb5c924886d 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -499,6 +499,23 @@ int nfs_key_timeout_notify(struct file *filp, struct inode *inode);
 bool nfs_ctx_key_to_expire(struct nfs_open_context *ctx);
 void nfs_pageio_stop_mirroring(struct nfs_pageio_descriptor *pgio);
 
+#ifdef CONFIG_NFS_V4_1
+static inline
+void nfs_clear_pnfs_ds_commit_verifiers(struct pnfs_ds_commit_info *cinfo)
+{
+	int i;
+
+	for (i = 0; i < cinfo->nbuckets; i++)
+		cinfo->buckets[i].direct_verf.committed = NFS_INVALID_STABLE_HOW;
+}
+#else
+static inline
+void nfs_clear_pnfs_ds_commit_verifiers(struct pnfs_ds_commit_info *cinfo)
+{
+}
+#endif
+
+
 #ifdef CONFIG_MIGRATION
 extern int nfs_migrate_page(struct address_space *,
 		struct page *, struct page *, enum migrate_mode);
-- 
2.7.4

