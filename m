From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: RCU-isms in fs/nfs/delegation.c
Date: Mon, 19 Apr 2010 13:32:41 -0400
Message-ID: <1271698361.13653.79.camel@localhost.localdomain>
References: <14317.1271691185@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: paulmck@linux.vnet.ibm.com, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9835 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752613Ab0DSRd1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Apr 2010 13:33:27 -0400
In-Reply-To: <14317.1271691185@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2010-04-19 at 16:33 +0100, David Howells wrote: 
> I'm trying to redo my NFS RCU warning fixup patch on top of Paul's patches,
> and I've found a small potential bug: nfs_inode_reclaim_delegation() doesn't
> use the appropriate accessors/locks to protect NFS_I(inode)->delegation, and
> nor does it use such to protect *delegation that I can see.  It just
> overwrites the record.

Hmm... Yes, I think that function should probably take the
rcu_read_lock(), and then take the delegation->lock before modifying the
delegation. Furthermore, it should probably fall back to
nfs_inode_set_delegation() in case we race with a delegreturn. See
below...

> Furthermore, for consistency's sake, it should also protect accesses to
> delegation->cred within that function.
> 
> Trond: can you confirm that both NFS_I(inode)->delegation and delegation->cred
> should be considered RCU-protected pointers?

With the above changes to nfs_inode_reclaim_delegation() I don't think
delegation->cred needs to be RCU-protected.

Cheers
  Trond

---------------------------------------------------------------------------------------------------------- 
NFSv4: Fix the locking in nfs_inode_reclaim_delegation()

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Ensure that we correctly rcu-dereference the delegation itself, and that
we protect against removal while we're changing the contents.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/delegation.c |   37 ++++++++++++++++++++++++-------------
 1 files changed, 24 insertions(+), 13 deletions(-)


diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 1567124..f9c6b63 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -129,21 +129,32 @@ again:
  */
 void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res)
 {
-	struct nfs_delegation *delegation = NFS_I(inode)->delegation;
-	struct rpc_cred *oldcred;
+	struct nfs_delegation *delegation;
+	struct rpc_cred *oldcred = NULL;
 
+	rcu_read_lock();
+	delegation = rcu_dereference(NFS_I(inode)->delegation);
 	if (delegation == NULL)
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
+		goto out;
+	spin_lock(&delegation->lock);
+	if (delegation->inode != NULL) {
+		memcpy(delegation->stateid.data, res->delegation.data,
+				sizeof(delegation->stateid.data));
+		delegation->type = res->delegation_type;
+		delegation->maxsize = res->maxsize;
+		oldcred = delegation->cred;
+		delegation->cred = get_rpccred(cred);
+		clear_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags);
+		NFS_I(inode)->delegation_state = delegation->type;
+		spin_unlock(&delegation->lock);
+		put_rpccred(oldcred);
+	} else {
+		/* We appear to have raced with a delegation return. */
+		spin_unlock(&delegation->lock);
+		nfs_inode_set_delegation(inode, cred, res);
+	}
+out:
+	rcu_read_unlock();
 }
 
 static int nfs_do_return_delegation(struct inode *inode, struct nfs_delegation *delegation, int issync)

