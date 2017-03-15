Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:13505 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753790AbdCOUmy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 15 Mar 2017 16:42:54 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] PNFS fix fallback to MDS if got error on commit to DS
Date: Wed, 15 Mar 2017 16:42:40 -0400
Message-ID: <20170315204240.44221-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Upon receiving an error on commit to the DS, the code doesn't fallback
to MDS and instead retried to the same DS again.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/filelayout/filelayout.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index e1d9bea..948cb70 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -382,6 +382,7 @@ static int filelayout_commit_done_cb(struct rpc_task *task,
 	switch (err) {
 	case -NFS4ERR_RESET_TO_MDS:
 		pnfs_generic_prepare_to_resend_writes(data);
+		pnfs_set_lo_fail(data->lseg);
 		return -EAGAIN;
 	case -EAGAIN:
 		rpc_restart_call_prepare(task);
-- 
1.8.3.1

