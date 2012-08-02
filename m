Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:44530 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753577Ab2HBMkY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Aug 2012 08:40:24 -0400
Message-ID: <501A752B.9030702@panasas.com>
Date: Thu, 2 Aug 2012 15:40:11 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
CC: Peng Tao <tao.peng@emc.com>
Subject: [PATCH 3/3] pnfs: Don't BUG on info received from Server
References: <501A7369.6090808@panasas.com>
In-Reply-To: <501A7369.6090808@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


In nfs4_layoutreturn_done() there is a BUG_ON on a Server
returned member, when received in what the client thinks is
an impossible situation.

[The server returned ! lrp->res.lrs_present, but client
 still had more segments]

This BUG really hit me with the Linux pnfs Server, but
regardless of who is at fault here, Server or client, client
must not crash, even on a buggy Server.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 15fc7e4..e25b686 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6249,7 +6249,7 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 		if (lrp->res.lrs_present) {
 			pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
 		} else
-			BUG_ON(!list_empty(&lo->plh_segs));
+			WARN_ON(!list_empty(&lo->plh_segs));
 	}
 	lo->plh_block_lgets--;
 	spin_unlock(&lo->plh_inode->i_lock);
-- 
1.7.10.2.677.gb6bc67f


