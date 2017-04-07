Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:42074 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933619AbdDGSQC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:16:02 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 19/34] NFS: Create a common nfs4_match_client() function
Date: Fri, 7 Apr 2017 14:15:13 -0400
Message-ID: <20170407181528.2832-20-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

This puts all the common code in a single place for the
walk_client_list() functions.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4client.c | 119 ++++++++++++++++++++++++----------------------------
 1 file changed, 55 insertions(+), 64 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 4f4f179cb849..8853c32eedf5 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -469,6 +469,50 @@ static bool nfs4_same_verifier(nfs4_verifier *v1, nfs4_verifier *v2)
 	return memcmp(v1->data, v2->data, sizeof(v1->data)) == 0;
 }
 
+static int nfs4_match_client(struct nfs_client  *pos,  struct nfs_client *new,
+			     struct nfs_client **prev, struct nfs_net *nn)
+{
+	int status;
+
+	if (pos->rpc_ops != new->rpc_ops)
+		return 1;
+
+	if (pos->cl_minorversion != new->cl_minorversion)
+		return 1;
+
+	/* If "pos" isn't marked ready, we can't trust the
+	 * remaining fields in "pos", especially the client
+	 * ID and serverowner fields.  Wait for CREATE_SESSION
+	 * to finish. */
+	if (pos->cl_cons_state > NFS_CS_READY) {
+		atomic_inc(&pos->cl_count);
+		spin_unlock(&nn->nfs_client_lock);
+
+		nfs_put_client(*prev);
+		*prev = pos;
+
+		status = nfs_wait_client_init_complete(pos);
+		spin_lock(&nn->nfs_client_lock);
+
+		if (status < 0)
+			return status;
+	}
+
+	if (pos->cl_cons_state != NFS_CS_READY)
+		return 1;
+
+	if (pos->cl_clientid != new->cl_clientid)
+		return 1;
+
+	/* NFSv4.1 always uses the uniform string, however someone
+	 * might switch the uniquifier string on us.
+	 */
+	if (!nfs4_match_client_owner_id(pos, new))
+		return 1;
+
+	return 0;
+}
+
 /**
  * nfs40_walk_client_list - Find server that recognizes a client ID
  *
@@ -497,34 +541,10 @@ int nfs40_walk_client_list(struct nfs_client *new,
 	spin_lock(&nn->nfs_client_lock);
 	list_for_each_entry(pos, &nn->nfs_client_list, cl_share_link) {
 
-		if (pos->rpc_ops != new->rpc_ops)
-			continue;
-
-		if (pos->cl_minorversion != new->cl_minorversion)
-			continue;
-
-		/* If "pos" isn't marked ready, we can't trust the
-		 * remaining fields in "pos" */
-		if (pos->cl_cons_state > NFS_CS_READY) {
-			atomic_inc(&pos->cl_count);
-			spin_unlock(&nn->nfs_client_lock);
-
-			nfs_put_client(prev);
-			prev = pos;
-
-			status = nfs_wait_client_init_complete(pos);
-			if (status < 0)
-				goto out;
-			status = -NFS4ERR_STALE_CLIENTID;
-			spin_lock(&nn->nfs_client_lock);
-		}
-		if (pos->cl_cons_state != NFS_CS_READY)
-			continue;
-
-		if (pos->cl_clientid != new->cl_clientid)
-			continue;
-
-		if (!nfs4_match_client_owner_id(pos, new))
+		status = nfs4_match_client(pos, new, &prev, nn);
+		if (status < 0)
+			goto out_unlock;
+		if (status != 0)
 			continue;
 		/*
 		 * We just sent a new SETCLIENTID, which should have
@@ -567,11 +587,13 @@ int nfs40_walk_client_list(struct nfs_client *new,
 			 */
 			nfs4_schedule_path_down_recovery(pos);
 		default:
+			spin_lock(&nn->nfs_client_lock);
 			goto out;
 		}
 
 		spin_lock(&nn->nfs_client_lock);
 	}
+out_unlock:
 	spin_unlock(&nn->nfs_client_lock);
 
 	/* No match found. The server lost our clientid */
@@ -704,33 +726,10 @@ int nfs41_walk_client_list(struct nfs_client *new,
 		if (pos == new)
 			goto found;
 
-		if (pos->rpc_ops != new->rpc_ops)
-			continue;
-
-		if (pos->cl_minorversion != new->cl_minorversion)
-			continue;
-
-		/* If "pos" isn't marked ready, we can't trust the
-		 * remaining fields in "pos", especially the client
-		 * ID and serverowner fields.  Wait for CREATE_SESSION
-		 * to finish. */
-		if (pos->cl_cons_state > NFS_CS_READY) {
-			atomic_inc(&pos->cl_count);
-			spin_unlock(&nn->nfs_client_lock);
-
-			nfs_put_client(prev);
-			prev = pos;
-
-			status = nfs_wait_client_init_complete(pos);
-			spin_lock(&nn->nfs_client_lock);
-			if (status < 0)
-				break;
-			status = -NFS4ERR_STALE_CLIENTID;
-		}
-		if (pos->cl_cons_state != NFS_CS_READY)
-			continue;
-
-		if (pos->cl_clientid != new->cl_clientid)
+		status = nfs4_match_client(pos, new, &prev, nn);
+		if (status < 0)
+			goto out;
+		if (status != 0)
 			continue;
 
 		/*
@@ -742,23 +741,15 @@ int nfs41_walk_client_list(struct nfs_client *new,
 						     new->cl_serverowner))
 			continue;
 
-		/* Unlike NFSv4.0, we know that NFSv4.1 always uses the
-		 * uniform string, however someone might switch the
-		 * uniquifier string on us.
-		 */
-		if (!nfs4_match_client_owner_id(pos, new))
-			continue;
 found:
 		atomic_inc(&pos->cl_count);
 		*result = pos;
 		status = 0;
-		dprintk("NFS: <-- %s using nfs_client = %p ({%d})\n",
-			__func__, pos, atomic_read(&pos->cl_count));
 		break;
 	}
 
+out:
 	spin_unlock(&nn->nfs_client_lock);
-	dprintk("NFS: <-- %s status = %d\n", __func__, status);
 	nfs_put_client(prev);
 	return status;
 }
-- 
2.12.2

