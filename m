Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:46732 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751167AbdAQUcw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Jan 2017 15:32:52 -0500
From: <Anna.Schumaker@Netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 04/10] NFS: Return errors directly in _nfs4_opendata_reclaim_to_nfs4_state()
Date: Tue, 17 Jan 2017 15:31:59 -0500
Message-ID: <20170117203205.29033-5-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170117203205.29033-1-Anna.Schumaker@Netapp.com>
References: <20170117203205.29033-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

There is no need for a goto just to return an error code without any
cleanup.  Returning the error directly helps to clean up the code.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 950e9cd15e5d..83d31c93065e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1638,17 +1638,15 @@ _nfs4_opendata_reclaim_to_nfs4_state(struct nfs4_opendata *data)
 	int ret;
 
 	if (!data->rpc_done) {
-		if (data->rpc_status) {
-			ret = data->rpc_status;
-			goto err;
-		}
+		if (data->rpc_status)
+			return ERR_PTR(data->rpc_status);
 		/* cached opens have already been processed */
 		goto update;
 	}
 
 	ret = nfs_refresh_inode(inode, &data->f_attr);
 	if (ret)
-		goto err;
+		return ERR_PTR(ret);
 
 	if (data->o_res.delegation_type != 0)
 		nfs4_opendata_check_deleg(data, state);
@@ -1658,9 +1656,6 @@ _nfs4_opendata_reclaim_to_nfs4_state(struct nfs4_opendata *data)
 	atomic_inc(&state->count);
 
 	return state;
-err:
-	return ERR_PTR(ret);
-
 }
 
 static struct nfs4_state *
-- 
2.11.0

