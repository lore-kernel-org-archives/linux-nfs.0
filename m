Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:38024 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753727Ab2E1QKC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 May 2012 12:10:02 -0400
Received: by mail-we0-f174.google.com with SMTP id u7so2021750wey.19
        for <linux-nfs@vger.kernel.org>; Mon, 28 May 2012 09:10:02 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] SQUASHME: pnfsd: lrs_present is false by default
Date: Mon, 28 May 2012 19:09:57 +0300
Message-Id: <1338221397-22679-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <4FC3A235.8090908@tonian.com>
References: <4FC3A235.8090908@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Set to true only on error free path.

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c |    1 +
 fs/nfsd/nfs4proc.c  |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 0a8d5b5..11bccdf 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -892,6 +892,7 @@ struct super_block *
 	struct nfs4_layout *lp, *nextlp;
 
 	dprintk("%s: clp %p fp %p\n", __func__, clp, fp);
+	lrp->lrs_present = 1;
 	spin_lock(&layout_lock);
 	list_for_each_entry_safe (lp, nextlp, &fp->fi_layouts, lo_perfile) {
 		dprintk("%s: lp %p client %p,%p lo_type %x,%x iomode %d,%d\n",
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 6328300..e76111c 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1299,7 +1299,7 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
 
 	/* Set clientid from sessionid */
 	copy_clientid((clientid_t *)&lrp->args.lr_seg.clientid, cstate->session);
-	lrp->lrs_present = (lrp->args.lr_return_type == RETURN_FILE);
+	lrp->lrs_present = 0;
 	status = nfs4_pnfs_return_layout(sb, current_fh, lrp);
 out:
 	dprintk("pNFS %s: status %d return_type 0x%x lrs_present %d\n",
-- 
1.7.6.5

