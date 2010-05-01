From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH 1/2] NFSv4: Fix the locking in nfs_inode_reclaim_delegation()
Date: Fri, 30 Apr 2010 17:32:47 -0700
Message-ID: <1272673968-28066-1-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20100501003153.GA27982@linux.vnet.ibm.com>
Cc: mingo@elte.hu, peterz@infradead.org, Trond.Myklebust@netapp.com,
	David Howells <dhowells@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:42633 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754024Ab0EAAcy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Apr 2010 20:32:54 -0400
In-Reply-To: <20100501003153.GA27982@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Ensure that we correctly rcu-dereference the delegation itself, and that we
protect against removal while we're changing the contents.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: David Howells <dhowells@redhat.com>
Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---
 fs/nfs/delegation.c |   42 ++++++++++++++++++++++++++++--------------
 1 files changed, 28 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 1567124..8d9ec49 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -129,21 +129,35 @@ again:
  */
 void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res)
 {
-	struct nfs_delegation *delegation = NFS_I(inode)->delegation;
-	struct rpc_cred *oldcred;
+	struct nfs_delegation *delegation;
+	struct rpc_cred *oldcred = NULL;
 
-	if (delegation == NULL)
-		return;
-	memcpy(delegation->stateid.data, res->delegation.data,
-			sizeof(delegation->stateid.data));
-	delegation->type = res->delegation_type;
-	delegation->maxsize = res->maxsize;
-	oldcred = delegation->cred;
-	delegation->cred = get_rpccred(cred);
-	clear_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags);
-	NFS_I(inode)->delegation_state = delegation->type;
-	smp_wmb();
-	put_rpccred(oldcred);
+	rcu_read_lock();
+	delegation = rcu_dereference(NFS_I(inode)->delegation);
+	if (delegation != NULL) {
+		spin_lock(&delegation->lock);
+		if (delegation->inode != NULL) {
+			memcpy(delegation->stateid.data, res->delegation.data,
+			       sizeof(delegation->stateid.data));
+			delegation->type = res->delegation_type;
+			delegation->maxsize = res->maxsize;
+			oldcred = delegation->cred;
+			delegation->cred = get_rpccred(cred);
+			clear_bit(NFS_DELEGATION_NEED_RECLAIM,
+				  &delegation->flags);
+			NFS_I(inode)->delegation_state = delegation->type;
+			spin_unlock(&delegation->lock);
+			put_rpccred(oldcred);
+			rcu_read_unlock();
+		} else {
+			/* We appear to have raced with a delegation return. */
+			spin_unlock(&delegation->lock);
+			rcu_read_unlock();
+			nfs_inode_set_delegation(inode, cred, res);
+		}
+	} else {
+		rcu_read_unlock();
+	}
 }
 
 static int nfs_do_return_delegation(struct inode *inode, struct nfs_delegation *delegation, int issync)
-- 
1.7.0

