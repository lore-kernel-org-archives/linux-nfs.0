Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:59447 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751723AbaLXHOD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Dec 2014 02:14:03 -0500
Received: by mail-ie0-f180.google.com with SMTP id rp18so7282537iec.11
        for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2014 23:14:02 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 28/49] nfs41: clear NFS_LAYOUT_RETURN if layoutreturn is sent or failed to send
Date: Tue, 23 Dec 2014 23:13:07 -0800
Message-Id: <1419405208-25975-29-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
References: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
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
index b5bbe35..bf5ef58 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7786,6 +7786,7 @@ static void nfs4_layoutreturn_release(void *calldata)
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

