Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:38024 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214Ab2E1QJo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 May 2012 12:09:44 -0400
Received: by mail-we0-f174.google.com with SMTP id u7so2021750wey.19
        for <linux-nfs@vger.kernel.org>; Mon, 28 May 2012 09:09:44 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] pnfsd: add debug printouts to pnfsd_roc
Date: Mon, 28 May 2012 19:09:38 +0300
Message-Id: <1338221378-22567-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <4FC3A235.8090908@tonian.com>
References: <4FC3A235.8090908@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index cfaac56..0a8d5b5 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -1227,7 +1227,9 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp)
 {
 	struct nfs4_layout *lo, *nextlp;
+	bool found = false;
 
+	dprintk("%s: fp=%p clp=%p", __func__, fp, clp);
 	spin_lock(&layout_lock);
 	list_for_each_entry_safe (lo, nextlp, &fp->fi_layouts, lo_perfile) {
 		struct nfsd4_pnfs_layoutreturn lr;
@@ -1245,11 +1247,15 @@ void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp)
 		destroy_layout(lo); /* do not access lp after this */
 
 		empty = list_empty(&fp->fi_layouts);
+		found = true;
+		dprintk("%s: fp=%p clp=%p: return on close", __func__, fp, clp);
 		fs_layout_return(fp->fi_inode->i_sb, fp->fi_inode, &lr,
 				 LR_FLAG_INTERN,
 				 empty ? PNFS_LAST_LAYOUT_NO_RECALLS : NULL);
 	}
 	spin_unlock(&layout_lock);
+	if (!found)
+		dprintk("%s: no layout found", __func__);
 }
 
 void pnfs_expire_client(struct nfs4_client *clp)
-- 
1.7.6.5

