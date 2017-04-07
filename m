Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:42074 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933216AbdDGSPx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:15:53 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 14/34] NFS: Clean up nfs_direct_commit_complete()
Date: Fri, 7 Apr 2017 14:15:08 -0400
Message-ID: <20170407181528.2832-15-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/direct.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 0b65e25b71ac..18d0868ee274 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -685,16 +685,9 @@ static void nfs_direct_commit_complete(struct nfs_commit_data *data)
 	int status = data->task.tk_status;
 
 	nfs_init_cinfo_from_dreq(&cinfo, dreq);
-	if (status < 0) {
-		dprintk("NFS: %5u commit failed with error %d.\n",
-			data->task.tk_pid, status);
+	if (status < 0 || nfs_direct_cmp_commit_data_verf(dreq, data))
 		dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
-	} else if (nfs_direct_cmp_commit_data_verf(dreq, data)) {
-		dprintk("NFS: %5u commit verify failed\n", data->task.tk_pid);
-		dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
-	}
 
-	dprintk("NFS: %5u commit returned %d\n", data->task.tk_pid, status);
 	while (!list_empty(&data->pages)) {
 		req = nfs_list_entry(data->pages.next);
 		nfs_list_remove_request(req);
-- 
2.12.2

