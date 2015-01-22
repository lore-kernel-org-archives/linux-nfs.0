Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f174.google.com ([209.85.192.174]:64222 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754442AbbAVXhl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 18:37:41 -0500
Received: by mail-pd0-f174.google.com with SMTP id ft15so4614571pdb.5
        for <linux-nfs@vger.kernel.org>; Thu, 22 Jan 2015 15:37:40 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v5 28/51] nfs41: clear NFS_LAYOUT_RETURN if layoutreturn is sent or failed to send
Date: Thu, 22 Jan 2015 15:36:00 -0800
Message-Id: <1421969783-92997-29-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
References: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

So that pnfs path is not disabled for ever.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/nfs4proc.c | 1 +
 fs/nfs/pnfs.c     | 5 +++++
 2 files changed, 6 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1943284..e19b5db 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7796,6 +7796,7 @@ static void nfs4_layoutreturn_release(void *calldata)
 	spin_lock(&lo->plh_inode->i_lock);
 	if (lrp->res.lrs_present)
 		pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
+	clear_bit(NFS_LAYOUT_RETURN, &lo->plh_flags);
 	lo->plh_block_lgets--;
 	spin_unlock(&lo->plh_inode->i_lock);
 	pnfs_put_layout_hdr(lrp->args.layout);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e9acfcf..63992c8 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -921,6 +921,11 @@ pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
 
 	status = nfs4_proc_layoutreturn(lrp);
 out:
+	if (status) {
+		spin_lock(&ino->i_lock);
+		clear_bit(NFS_LAYOUT_RETURN, &lo->plh_flags);
+		spin_unlock(&ino->i_lock);
+	}
 	dprintk("<-- %s status: %d\n", __func__, status);
 	return status;
 }
-- 
1.9.3

