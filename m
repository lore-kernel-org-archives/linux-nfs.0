Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:33696 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbbGMFUg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 01:20:36 -0400
Received: by laem6 with SMTP id m6so2580927lae.0
        for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2015 22:20:35 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] pNFS: pnfs_roc_drain() fix a race with open
Date: Mon, 13 Jul 2015 07:20:04 +0200
Message-Id: <1436764805-2893-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1436764805-2893-3-git-send-email-trond.myklebust@primarydata.com>
References: <1436764805-2893-1-git-send-email-trond.myklebust@primarydata.com>
 <1436764805-2893-2-git-send-email-trond.myklebust@primarydata.com>
 <1436764805-2893-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a process reopens the file before we can send off the CLOSE/DELEGRETURN,
then pnfs_roc_drain() may end up waiting for a new set of layout segments
that are marked as return-on-close, but haven't yet been returned.

Fix this by only waiting for those layout segments that were invalidated in
pnfs_roc().

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 27e2bcaa88da..b02e32e2abeb 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1159,12 +1159,15 @@ bool pnfs_roc_drain(struct inode *ino, u32 *barrier, struct rpc_task *task)
 	bool layoutreturn = false;
 
 	spin_lock(&ino->i_lock);
-	list_for_each_entry(lseg, &nfsi->layout->plh_segs, pls_list)
-		if (test_bit(NFS_LSEG_ROC, &lseg->pls_flags)) {
-			rpc_sleep_on(&NFS_SERVER(ino)->roc_rpcwaitq, task, NULL);
-			spin_unlock(&ino->i_lock);
-			return true;
-		}
+	list_for_each_entry(lseg, &nfsi->layout->plh_segs, pls_list) {
+		if (!test_bit(NFS_LSEG_ROC, &lseg->pls_flags))
+			continue;
+		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags))
+			continue;
+		rpc_sleep_on(&NFS_SERVER(ino)->roc_rpcwaitq, task, NULL);
+		spin_unlock(&ino->i_lock);
+		return true;
+	}
 	lo = nfsi->layout;
 	current_seqid = be32_to_cpu(lo->plh_stateid.seqid);
 
-- 
2.4.3

