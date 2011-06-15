From: Benny Halevy <benny@tonian.com>
Subject: [PATCH] NFSv4.1: need to put_layout_hdr on _pnfs_return_layout error path
Date: Wed, 15 Jun 2011 11:39:57 -0400
Message-ID: <1308152397-16920-1-git-send-email-benny@tonian.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <benny@tonian.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:64137 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755191Ab1FOPkD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2011 11:40:03 -0400
Received: by ewy4 with SMTP id 4so211690ewy.19
        for <linux-nfs@vger.kernel.org>; Wed, 15 Jun 2011 08:40:02 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We always get a reference on the layout header and we rely on
nfs4_layoutreturn_release to put it.  If we hit an allocation error
before starting the rpc proc we bail out early without dereferncing
the layout header properly.

Signed-off-by: Benny Halevy <benny@tonian.com>
---
 fs/nfs/nfs4proc.c |    1 +
 fs/nfs/pnfs.c     |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 79f3c33..a4705bc 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5774,6 +5774,7 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 	struct pnfs_layout_hdr *lo = NFS_I(lrp->args.inode)->layout;
 
 	dprintk("--> %s\n", __func__);
+	dprintk("%s: ref %d\n", atonic_read(&lo->plh_refcount));
 
 	if (!nfs4_sequence_done(task, &lrp->res.seq_res))
 		return;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0feeccc..bc3eb74 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -675,6 +675,7 @@ _pnfs_return_layout(struct inode *ino)
 	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
 	if (unlikely(lrp == NULL)) {
 		status = -ENOMEM;
+		put_layout_hdr(lo);
 		goto out;
 	}
 
-- 
1.7.4.4

