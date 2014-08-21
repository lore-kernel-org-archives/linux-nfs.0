Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:51178 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129AbaHUQH2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Aug 2014 12:07:28 -0400
Received: from ip-64-134-168-64.public.wayport.net ([64.134.168.64] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XKUtb-00009O-12
	for linux-nfs@vger.kernel.org; Thu, 21 Aug 2014 16:07:27 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 05/19] pnfs: retry after a bad stateid error from layoutget
Date: Thu, 21 Aug 2014 11:09:21 -0500
Message-Id: <1408637375-11343-6-git-send-email-hch@lst.de>
In-Reply-To: <1408637375-11343-1-git-send-email-hch@lst.de>
References: <pnfs block layout driver fixes V2>
 <1408637375-11343-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently we fall through to nfs4_async_handle_error when we get
a bad stateid error back from layoutget.  nfs4_async_handle_error
with a NULL state argument will never retry the operations but return
the error to higher layer, causing an avoiable fallback to MDS I/O.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/nfs4proc.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 75ae8d2..4ca5880 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7571,11 +7571,16 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 		} else {
 			LIST_HEAD(head);
 
+			/*
+			 * Mark the bad layout state as invalid, then retry
+			 * with the current stateid.
+			 */
 			pnfs_mark_matching_lsegs_invalid(lo, &head, NULL);
 			spin_unlock(&inode->i_lock);
-			/* Mark the bad layout state as invalid, then
-			 * retry using the open stateid. */
 			pnfs_free_lseg_list(&head);
+	
+			task->tk_status = 0;
+			rpc_restart_call_prepare(task);
 		}
 	}
 	if (nfs4_async_handle_error(task, server, state) == -EAGAIN)
-- 
1.9.1

