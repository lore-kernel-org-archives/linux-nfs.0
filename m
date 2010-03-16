From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in
	nfs_inode_return_delegation_noreclaim()
Date: Tue, 16 Mar 2010 11:10:53 -0700
Message-ID: <20100316181053.GO6709@linux.vnet.ibm.com>
References: <20100316115130.25642.17789.stgit@warthog.procyon.org.uk> <20100316171738.GN6709@linux.vnet.ibm.com> <1268760954.3098.17.camel@localhost.localdomain>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Howells <dhowells@redhat.com>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:36784 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756636Ab0CPSLN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Mar 2010 14:11:13 -0400
In-Reply-To: <1268760954.3098.17.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 16, 2010 at 01:35:54PM -0400, Trond Myklebust wrote:
> On Tue, 2010-03-16 at 10:17 -0700, Paul E. McKenney wrote: 
> > On Tue, Mar 16, 2010 at 11:51:30AM +0000, David Howells wrote:
> > > diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> > > index 2563beb..a77c735 100644
> > > --- a/fs/nfs/delegation.c
> > > +++ b/fs/nfs/delegation.c
> > > @@ -37,8 +37,10 @@ static void nfs_free_delegation(struct nfs_delegation *delegation)
> > >  {
> > >  	struct rpc_cred *cred;
> > > 
> > > +	rcu_read_lock();
> > >  	cred = rcu_dereference(delegation->cred);
> > >  	rcu_assign_pointer(delegation->cred, NULL);
> > 
> > The lock is probably held here, in which case something like the
> > following would work well without needing the artificial rcu_read_lock()
> > and rcu_read_unlock():
> 
> No. The lock is not held here. At this point, the delegation has been
> detached from the inode that pointed to it, and so we can free up its
> contents.

OK.  Is there some reference counter or pointer that can be checked to
verify that this data structure really is in a state that prevents
RCU readers from finding it?

> We still need the call_rcu() to free up the allocated memory in order to
> ensure that some process doing lockless traversal of the
> clp->cl_delegations list doesn't crash.

OK.

> > 	cred = rcu_dereference_check(delegation->cred,
> > 				     lockdep_is_held(&delegation->lock));
> > 
> > > +	rcu_read_unlock();
> > >  	call_rcu(&delegation->rcu, nfs_free_delegation_callback);
> > >  	if (cred)
> > >  		put_rpccred(cred);
> > > @@ -212,10 +214,12 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
> > >  	spin_lock_init(&delegation->lock);
> > > 
> > >  	spin_lock(&clp->cl_lock);
> > > +	rcu_read_lock();
> > >  	if (rcu_dereference(nfsi->delegation) != NULL) {
> > 
> > Same here, though I am not sure whether clp->cl_lock or something in
> > nfs_inode should be used.
> 
> Yes. As I indicated to David in another email, the clp->cl_lock protects
> us here, so it looks as if your suggestion above would be perfect.

Sounds good!

							Thanx, Paul

> > >  		if (memcmp(&delegation->stateid, &nfsi->delegation->stateid,
> > >  					sizeof(delegation->stateid)) == 0 &&
> > >  				delegation->type == nfsi->delegation->type) {
> > > +			rcu_read_unlock();
> > >  			goto out;
> > >  		}
> > >  		/*
> > > @@ -228,6 +232,7 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
> > >  		if (delegation->type <= nfsi->delegation->type) {
> > >  			freeme = delegation;
> > >  			delegation = NULL;
> > > +			rcu_read_lock();
> > >  			goto out;
> > >  		}
> > >  		freeme = nfs_detach_delegation_locked(nfsi, NULL);
> 
