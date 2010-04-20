From: David Howells <dhowells@redhat.com>
Subject: [PATCH 1/2] NFSv4: Fix the locking in nfs_inode_reclaim_delegation()
Date: Tue, 20 Apr 2010 11:26:08 +0100
Message-ID: <20100420102608.31956.93404.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: paulmck@linux.vnet.ibm.com, dhowells@redhat.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47250 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754419Ab0DTK02 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Apr 2010 06:26:28 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Ensure that we correctly rcu-dereference the delegation itself, and that we
protect against removal while we're changing the contents.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: David Howells <dhowells@redhat.com>
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

