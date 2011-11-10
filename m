Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:47636 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752377Ab1KJWun (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2011 17:50:43 -0500
Message-ID: <4EBC5538.7010002@panasas.com>
Date: Thu, 10 Nov 2011 14:50:32 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Benny Halevy <benny@tonian.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Fred Isaman <iisaman@netapp.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH] SQUASHME: pnfsd: Don't call fs_layout_return on a none-file
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


If we had a layout on the file the nfs4_file would be referenced and we should
have found it. Since we don't then it means all layouts where ROC and at this
point we returned all of them on file close.

So why does the Linux wonderful forgetfull client returnes it's ROC layouts on
inode evict() (I hit this on umount at client). Actually this is on me, because
it is a bug in Generic client code, but can only manifest with pnf-obj after an
IO error.

Sign-off-by: Boaz Harrosh
---
 fs/nfsd/nfs4pnfsd.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index f30fa65..eb4a044 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -1109,7 +1109,15 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 			printk(KERN_ERR "%s: RETURN_FILE: no nfs4_file for "
 				"ino %p:%lu\n",
 				__func__, ino, ino ? ino->i_ino : 0L);
-			goto out;
+			/* If we had a layout on the file the nfs4_file would
+			 * be referenced and we should have found it. Since we
+			 * don't then it means all layouts where ROC and at this
+			 * point we returned all of them on file close.
+			 * TODO:
+			 * Benny this is what Bruce calls a client spam, we might
+			 * want to degrade the print level to dprintk.
+			 */
+			goto out_no_fs_call;
 		}
 
 		/* Check the stateid */
@@ -1163,6 +1173,7 @@ out:
 	/* call exported filesystem layout_return (ignore return-code) */
 	fs_layout_return(sb, ino, lrp, 0, recall_cookie);
 
+out_no_fs_call:
 	dprintk("pNFS %s: exit status %d \n", __func__, status);
 	return status;
 }
-- 
1.7.6.2

