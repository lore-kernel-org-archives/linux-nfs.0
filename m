Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:29424 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753461Ab2JHRv6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Oct 2012 13:51:58 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] NFSv4.1: Deal with seqid wraparound in the pNFS return-on-close code
Date: Mon,  8 Oct 2012 13:50:27 -0400
Message-Id: <1349718630-26008-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index de82725..42613bd 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -801,7 +801,7 @@ void pnfs_roc_set_barrier(struct inode *ino, u32 barrier)
 
 	spin_lock(&ino->i_lock);
 	lo = NFS_I(ino)->layout;
-	if ((int)(barrier - lo->plh_barrier) > 0)
+	if (pnfs_seqid_is_newer(barrier, lo->plh_barrier))
 		lo->plh_barrier = barrier;
 	spin_unlock(&ino->i_lock);
 }
-- 
1.7.11.4

