From: andros@netapp.com
Subject: [PATCH 05/11] nfs41: free the slot on unhandled read errors
Date: Fri,  4 Dec 2009 15:25:40 -0500
Message-ID: <1259958347-9031-6-git-send-email-andros@netapp.com>
References: <1259958347-9031-1-git-send-email-andros@netapp.com>
 <1259958347-9031-2-git-send-email-andros@netapp.com>
 <1259958347-9031-3-git-send-email-andros@netapp.com>
 <1259958347-9031-4-git-send-email-andros@netapp.com>
 <1259958347-9031-5-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56650 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757221AbZLDUZz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Dec 2009 15:25:55 -0500
In-Reply-To: <1259958347-9031-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

nfs4_read_done returns zero on unhandled errors. nfs_readpage_result will
return on a negative tk_status without freeing the slot.
Call nfs4_sequence_free_slot on unhandled errors in nfs4_read_done.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d847e98..ee4a987 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2996,6 +2996,9 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 	nfs_invalidate_atime(data->inode);
 	if (task->tk_status > 0)
 		renew_lease(server, data->timestamp);
+	else if (task->tk_status < 0)
+		nfs4_sequence_free_slot(server->nfs_client, &data->res.seq_res);
+
 	return 0;
 }
 
-- 
1.6.0.6

