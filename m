From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/1] nfs41: Do not free slot if retried while operation was in progress
Date: Fri, 25 Sep 2009 07:29:05 +0300
Message-ID: <1253852945-22020-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Benny Halevy <bhalevy@panasas.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:14695 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750879AbZIYE3G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Sep 2009 00:29:06 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The client cannot reuse a slot while the server's
still working on the previous RPC using it.

The symptom Bruce saw without this patch was occasional
ESERVERFAULT during Connectathon special tests, 30 MB write/read test.

Reported-by: J. Bruce Fields <bfields@fieldses.org>
Tested-by: J. Bruce Fields <bfields@fieldses.org>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index be6544a..70895d6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -386,6 +386,12 @@ static void nfs41_sequence_done(struct nfs_client *clp,
 		spin_unlock(&clp->cl_lock);
 		return;
 	}
+
+	/* Do not free slot if retried while operation was in progress */
+	if (res->sr_status == -NFS4ERR_DELAY) {
+		dprintk("%s: Operation in progress\n", __func__);
+		return;
+	}
 out:
 	/* The session may be reset by one of the error handlers. */
 	dprintk("%s: Error %d free the slot \n", __func__, res->sr_status);
-- 
1.6.4

