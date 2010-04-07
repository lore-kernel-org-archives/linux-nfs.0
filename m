From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in
 nfs_inode_return_delegation_noreclaim() [ver #2]
Date: Wed, 7 Apr 2010 08:57:29 -0700
Message-ID: <20100407155729.GA2481@linux.vnet.ibm.com>
References: <2440.1269967151@redhat.com>
 <21972.1269993064@redhat.com>
 <10818.1270044273@redhat.com>
 <15371.1270057054@redhat.com>
 <19556.1270076008@redhat.com>
 <14003.1270122314@redhat.com>
 <4161.1270133211@redhat.com>
 <23331.1270570443@redhat.com>
 <26510.1270582446@redhat.com>
 <24225.1270646561@redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:59415 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932729Ab0DGP5c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Apr 2010 11:57:32 -0400
In-Reply-To: <24225.1270646561@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 07, 2010 at 02:22:41PM +0100, David Howells wrote:
> Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> 
> > +#define rcu_access_pointer(p, c) \
> 
> Why is there a need for 'c'?

An example use is where rcu_access_pointer() is legal because we are
either initializing or cleaning up, so that no other CPU has access
to the pointer.  In these cases, you might do something like:

	q = rcu_access_pointer(p->a, p->refcnt == 0);

> > +#define rcu_dereference_protect(p, c) \
> 
> I'd prefer rcu_dereference_protected(), I think.  This macro doesn't protect
> anything.  Also, again, why the need for 'c'?

Agreed on rcu_dereference_protected().  I succumbed to a fit of "make
the identifier shorter", please accept my apologies.

> For instance, in:
> 
> 	static struct nfs_delegation *nfs_detach_delegation_locked(struct nfs_inode *nfsi, const nfs4_stateid *stateid)
> 	{
> 		struct nfs_delegation *delegation =
> 			rcu_dereference_protected(nfsi->delegation, ????);
> 
> what would be the condition?  That the spinlock is held?  That's a condition
> for calling the function.

Yep, that the spinlock is held.  I agree that it is a bit obvious in
this case, but I have come across a number of RCU uses where the lock
in question was acquired many function calls removed from the access,
and where there other locks were held for other purposes.

> And in:
> 
> 	void nfs_inode_return_delegation_noreclaim(struct inode *inode)
> 	{
> 		struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
> 		struct nfs_inode *nfsi = NFS_I(inode);
> 		struct nfs_delegation *delegation;
> 
> 		if (rcu_access_pointer(nfsi->delegation, ????) != NULL) {
> 
> what would be the condition here?  There's no lock to check - that's the whole
> point of the macro.  I also can't give it nfsi->delegation to check as the
> value may change between the two accesses.

I suggest something like the following:

		/* protected by double-check lock pattern. */
		if (rcu_access_pointer(nfsi->delegation, 1) != NULL) {

							Thanx, Paul
