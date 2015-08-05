Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:34037 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751940AbbHECaB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2015 22:30:01 -0400
Received: by ioea135 with SMTP id a135so36118902ioe.1
        for <linux-nfs@vger.kernel.org>; Tue, 04 Aug 2015 19:30:00 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/6] NFSv4.1/pnfs: Don't prevent layoutgets when doing return-on-close
Date: Tue,  4 Aug 2015 22:29:53 -0400
Message-Id: <1438741796-22681-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1438741796-22681-2-git-send-email-trond.myklebust@primarydata.com>
References: <1438741796-22681-1-git-send-email-trond.myklebust@primarydata.com>
 <1438741796-22681-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If there is an outstanding return-on-close, then we just want new
layoutget requests to wait rather than fail.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 5280def00bc4..9147dcaeb546 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1105,7 +1105,9 @@ bool pnfs_roc(struct inode *ino)
 		}
 	if (!found)
 		goto out_noroc;
-	lo->plh_block_lgets++;
+	if (test_and_set_bit(NFS_LAYOUT_RETURN, &lo->plh_flags))
+		goto out_noroc;
+	lo->plh_return_iomode = IOMODE_ANY;
 	pnfs_get_layout_hdr(lo); /* matched in pnfs_roc_release */
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&tmp_list);
@@ -1133,7 +1135,7 @@ void pnfs_roc_release(struct inode *ino)
 
 	spin_lock(&ino->i_lock);
 	lo = NFS_I(ino)->layout;
-	lo->plh_block_lgets--;
+	pnfs_clear_layoutreturn_waitbit(lo);
 	if (atomic_dec_and_test(&lo->plh_refcount)) {
 		pnfs_detach_layout_hdr(lo);
 		spin_unlock(&ino->i_lock);
-- 
2.4.3

