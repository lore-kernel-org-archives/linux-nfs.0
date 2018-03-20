Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:55778 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751320AbeCTVDv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 17:03:51 -0400
Received: by mail-it0-f65.google.com with SMTP id e195-v6so4238967ita.5
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2018 14:03:50 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 9/9] NFSv4: Fix the nfs_inode_set_delegation() arguments
Date: Tue, 20 Mar 2018 17:03:13 -0400
Message-Id: <20180320210313.94429-10-trond.myklebust@primarydata.com>
In-Reply-To: <20180320210313.94429-9-trond.myklebust@primarydata.com>
References: <20180320210313.94429-1-trond.myklebust@primarydata.com>
 <20180320210313.94429-2-trond.myklebust@primarydata.com>
 <20180320210313.94429-3-trond.myklebust@primarydata.com>
 <20180320210313.94429-4-trond.myklebust@primarydata.com>
 <20180320210313.94429-5-trond.myklebust@primarydata.com>
 <20180320210313.94429-6-trond.myklebust@primarydata.com>
 <20180320210313.94429-7-trond.myklebust@primarydata.com>
 <20180320210313.94429-8-trond.myklebust@primarydata.com>
 <20180320210313.94429-9-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neither nfs_inode_set_delegation() nor nfs_inode_reclaim_delegation() are
generic code. They have no business delving into NFSv4 OPEN xdr structures,
so let's replace the "struct nfs_openres" parameter.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c | 35 ++++++++++++++++++++++-------------
 fs/nfs/delegation.h |  6 ++++--
 fs/nfs/nfs4proc.c   | 12 ++++++++----
 3 files changed, 34 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index a5cb44375100..1819d0d0ba4b 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -172,11 +172,15 @@ static int nfs_delegation_claim_opens(struct inode *inode,
  * nfs_inode_reclaim_delegation - process a delegation reclaim request
  * @inode: inode to process
  * @cred: credential to use for request
- * @res: new delegation state from server
+ * @type: delegation type
+ * @stateid: delegation stateid
+ * @pagemod_limit: write delegation "space_limit"
  *
  */
 void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred,
-				  struct nfs_openres *res)
+				  fmode_t type,
+				  const nfs4_stateid *stateid,
+				  unsigned long pagemod_limit)
 {
 	struct nfs_delegation *delegation;
 	struct rpc_cred *oldcred = NULL;
@@ -186,9 +190,9 @@ void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred,
 	if (delegation != NULL) {
 		spin_lock(&delegation->lock);
 		if (delegation->inode != NULL) {
-			nfs4_stateid_copy(&delegation->stateid, &res->delegation);
-			delegation->type = res->delegation_type;
-			delegation->pagemod_limit = res->pagemod_limit;
+			nfs4_stateid_copy(&delegation->stateid, stateid);
+			delegation->type = type;
+			delegation->pagemod_limit = pagemod_limit;
 			oldcred = delegation->cred;
 			delegation->cred = get_rpccred(cred);
 			clear_bit(NFS_DELEGATION_NEED_RECLAIM,
@@ -196,14 +200,14 @@ void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred,
 			spin_unlock(&delegation->lock);
 			rcu_read_unlock();
 			put_rpccred(oldcred);
-			trace_nfs4_reclaim_delegation(inode, res->delegation_type);
+			trace_nfs4_reclaim_delegation(inode, type);
 			return;
 		}
 		/* We appear to have raced with a delegation return. */
 		spin_unlock(&delegation->lock);
 	}
 	rcu_read_unlock();
-	nfs_inode_set_delegation(inode, cred, res);
+	nfs_inode_set_delegation(inode, cred, type, stateid, pagemod_limit);
 }
 
 static int nfs_do_return_delegation(struct inode *inode, struct nfs_delegation *delegation, int issync)
@@ -330,11 +334,16 @@ nfs_update_inplace_delegation(struct nfs_delegation *delegation,
  * nfs_inode_set_delegation - set up a delegation on an inode
  * @inode: inode to which delegation applies
  * @cred: cred to use for subsequent delegation processing
- * @res: new delegation state from server
+ * @type: delegation type
+ * @stateid: delegation stateid
+ * @pagemod_limit: write delegation "space_limit"
  *
  * Returns zero on success, or a negative errno value.
  */
-int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res)
+int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred,
+				  fmode_t type,
+				  const nfs4_stateid *stateid,
+				  unsigned long pagemod_limit)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs_client *clp = server->nfs_client;
@@ -346,9 +355,9 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 	delegation = kmalloc(sizeof(*delegation), GFP_NOFS);
 	if (delegation == NULL)
 		return -ENOMEM;
-	nfs4_stateid_copy(&delegation->stateid, &res->delegation);
-	delegation->type = res->delegation_type;
-	delegation->pagemod_limit = res->pagemod_limit;
+	nfs4_stateid_copy(&delegation->stateid, stateid);
+	delegation->type = type;
+	delegation->pagemod_limit = pagemod_limit;
 	delegation->change_attr = inode_peek_iversion_raw(inode);
 	delegation->cred = get_rpccred(cred);
 	delegation->inode = inode;
@@ -393,7 +402,7 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 	rcu_assign_pointer(nfsi->delegation, delegation);
 	delegation = NULL;
 
-	trace_nfs4_set_delegation(inode, res->delegation_type);
+	trace_nfs4_set_delegation(inode, type);
 
 out:
 	spin_unlock(&clp->cl_lock);
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index dcc8a783a6e1..bb1ef8c37af4 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -36,8 +36,10 @@ enum {
 	NFS_DELEGATION_TEST_EXPIRED,
 };
 
-int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res);
-void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res);
+int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred,
+		fmode_t type, const nfs4_stateid *stateid, unsigned long pagemod_limit);
+void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred,
+		fmode_t type, const nfs4_stateid *stateid, unsigned long pagemod_limit);
 int nfs4_inode_return_delegation(struct inode *inode);
 int nfs_async_inode_return_delegation(struct inode *inode, const nfs4_stateid *stateid);
 void nfs_inode_return_delegation_noreclaim(struct inode *inode);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 64dd0fa7afaa..6933109fa30f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1754,12 +1754,16 @@ nfs4_opendata_check_deleg(struct nfs4_opendata *data, struct nfs4_state *state)
 	}
 	if ((delegation_flags & 1UL<<NFS_DELEGATION_NEED_RECLAIM) == 0)
 		nfs_inode_set_delegation(state->inode,
-					 data->owner->so_cred,
-					 &data->o_res);
+				data->owner->so_cred,
+				data->o_res.delegation_type,
+				&data->o_res.delegation,
+				data->o_res.pagemod_limit);
 	else
 		nfs_inode_reclaim_delegation(state->inode,
-					     data->owner->so_cred,
-					     &data->o_res);
+				data->owner->so_cred,
+				data->o_res.delegation_type,
+				&data->o_res.delegation,
+				data->o_res.pagemod_limit);
 }
 
 /*
-- 
2.14.3

