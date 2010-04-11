From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: RCU condition checks
Date: Sun, 11 Apr 2010 18:57:23 -0400
Message-ID: <1271026643.6620.37.camel@localhost.localdomain>
References: <21972.1269993064@redhat.com> <10818.1270044273@redhat.com>
	 <15371.1270057054@redhat.com> <19556.1270076008@redhat.com>
	 <14003.1270122314@redhat.com> <4161.1270133211@redhat.com>
	 <23331.1270570443@redhat.com> <26510.1270582446@redhat.com>
	 <24225.1270646561@redhat.com> <26884.1270658130@redhat.com>
	 <20100407171048.GE2481@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Howells <dhowells@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8764 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753155Ab0DKW5o convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Apr 2010 18:57:44 -0400
In-Reply-To: <20100407171048.GE2481@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2010-04-07 at 10:10 -0700, Paul E. McKenney wrote: 
> On Wed, Apr 07, 2010 at 05:35:30PM +0100, David Howells wrote:
> > Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> > 
> > > > Why is there a need for 'c'?
> > > 
> > > An example use is where rcu_access_pointer() is legal because we are
> > > either initializing or cleaning up, so that no other CPU has access
> > > to the pointer.  In these cases, you might do something like:
> > > 
> > > 	q = rcu_access_pointer(p->a, p->refcnt == 0);
> > 
> > I think the main problem I have with this is that the fact that p->refcnt
> > should be 0 here is unrelated to the fact that we're wanting to look at the
> > value of p->a.  I'd say that this should be two separate statements, for
> > example:
> > 
> > 	ASSERT(p->refcnt == 0);
> > 	q = rcu_access_pointer(p->a);
> > 
> > I could see using a lockdep-managed ASSERT here would work, though.
> > 
> > The other problem I have with this is that I'm assuming rcu_access_pointer()
> > is simply for looking at the value of the pointer without dereferencing it -
> > in which case, is there any need for the lock-describing condition?
> 
> I agree that in many cases there won't be a reasonable condition.
> In which case, using "1" and an explanatory comment makes sense.
> In other cases, the fact that the value is zero can mean that no one
> else can possibly have a reference.
> 
> All that aside, I fully expect that uses of rcu_access_pointer() will
> require more than the usual code-review effort, as these sorts of
> unprotected accesses are notoriously error-prone.
> 
> > I agree, though, that:
> > 
> > 	q = rcu_dereference_check(p->a,
> > 				  rcu_read_lock_held() || (
> > 				   lockdep_is_held(p->lock) &&
> > 				   lockdep_is_held(q->lock)));
> > 
> > is a reasonable way of keeping the dereference and the lock checks together,
> > though that could equally well be written, say:
> > 
> > 	LOCKDEP_ASSERT(rcu_read_lock_held() || (
> > 		        lockdep_is_held(p->lock) &&
> > 			lockdep_is_held(q->lock)));
> > 	q = rcu_dereference_protected(p->a);
> > 
> > but combining those makes it easier to ensure people to write lock checking.
> 
> Glad you like it!
> 
> 							Thanx, Paul

What say we just list the conditions in the comments. I'm happy with
something like the following:

Trond
--------------------------------------------------------------------------------------------- 
NFSv4: Kill the bogus RCU dereferencing warnings in fs/nfs/delegation.c

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Kill all the bogus warnings about RCU dereferencing, and document which
locks are protecting the pointer derefs.

Reported-by: David Howells <dhowells@redhat.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/delegation.c |   24 ++++++++++++++++++------
 1 files changed, 18 insertions(+), 6 deletions(-)


diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 1567124..5a1a379 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -34,12 +34,17 @@ static void nfs_free_delegation_callback(struct rcu_head *head)
 	nfs_do_free_delegation(delegation);
 }
 
+/*
+ * At this point, we know that the nfsi->rwsem protects us against read
+ * access by the state recovery thread, so it is safe to assume nobody
+ * else is accessing delegation->cred.
+ */
 static void nfs_free_delegation(struct nfs_delegation *delegation)
 {
 	struct rpc_cred *cred;
 
-	cred = rcu_dereference(delegation->cred);
-	rcu_assign_pointer(delegation->cred, NULL);
+	cred = delegation->cred;
+	delegation->cred = NULL;
 	call_rcu(&delegation->rcu, nfs_free_delegation_callback);
 	if (cred)
 		put_rpccred(cred);
@@ -166,12 +171,18 @@ static struct inode *nfs_delegation_grab_inode(struct nfs_delegation *delegation
 	return inode;
 }
 
+/*
+ * This function must be called with the nfs_client->cl_lock held to
+ * ensure that the value of nfsi->delegation is protected against
+ * modification by other threads.
+ */
 static struct nfs_delegation *nfs_detach_delegation_locked(struct nfs_inode *nfsi, const nfs4_stateid *stateid)
 {
-	struct nfs_delegation *delegation = rcu_dereference(nfsi->delegation);
+	struct nfs_delegation *delegation = nfsi->delegation;
 
 	if (delegation == NULL)
 		goto nomatch;
+	/* Lock out RCU-protected lookups. */
 	spin_lock(&delegation->lock);
 	if (stateid != NULL && memcmp(delegation->stateid.data, stateid->data,
 				sizeof(delegation->stateid.data)) != 0)
@@ -212,8 +223,9 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 	delegation->flags = 1<<NFS_DELEGATION_REFERENCED;
 	spin_lock_init(&delegation->lock);
 
+	/* Protect nfsi->delegation against modification */
 	spin_lock(&clp->cl_lock);
-	if (rcu_dereference(nfsi->delegation) != NULL) {
+	if (nfsi->delegation != NULL) {
 		if (memcmp(&delegation->stateid, &nfsi->delegation->stateid,
 					sizeof(delegation->stateid)) == 0 &&
 				delegation->type == nfsi->delegation->type) {
@@ -330,7 +342,7 @@ void nfs_inode_return_delegation_noreclaim(struct inode *inode)
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_delegation *delegation;
 
-	if (rcu_dereference(nfsi->delegation) != NULL) {
+	if (nfsi->delegation != NULL) {
 		spin_lock(&clp->cl_lock);
 		delegation = nfs_detach_delegation_locked(nfsi, NULL);
 		spin_unlock(&clp->cl_lock);
@@ -346,7 +358,7 @@ int nfs_inode_return_delegation(struct inode *inode)
 	struct nfs_delegation *delegation;
 	int err = 0;
 
-	if (rcu_dereference(nfsi->delegation) != NULL) {
+	if (nfsi->delegation != NULL) {
 		spin_lock(&clp->cl_lock);
 		delegation = nfs_detach_delegation_locked(nfsi, NULL);
 		spin_unlock(&clp->cl_lock);

