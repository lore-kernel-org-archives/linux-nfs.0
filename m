From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in
 nfs_inode_return_delegation_noreclaim() [ver #2]
Date: Wed, 31 Mar 2010 18:29:19 -0700
Message-ID: <20100401012919.GK2461@linux.vnet.ibm.com>
References: <19192.1269889348@redhat.com>
 <23274.1269893706@redhat.com>
 <25276.1269901350@redhat.com>
 <26760.1269903543@redhat.com>
 <20100329232636.GT2569@linux.vnet.ibm.com>
 <2440.1269967151@redhat.com>
 <21972.1269993064@redhat.com>
 <10818.1270044273@redhat.com>
 <15371.1270057054@redhat.com>
 <19556.1270076008@redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:46910 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758582Ab0DAB3X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 31 Mar 2010 21:29:23 -0400
In-Reply-To: <19556.1270076008@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 31, 2010 at 11:53:28PM +0100, David Howells wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > If you dont own a lock, and test a pointer, what guarantee do you have
> > this pointer doesnt change right after you tested it ?
> 
> There are five possibilities:
> 
>  (1) A pointer points to something when you check, and still points to the
>      same thing after you've gained the lock.
> 
>  (2) A pointer points to something when you check, and points to something
>      else after you've gained the lock.
> 
>  (3) A pointer points to something when you check, and is NULL after you've
>      gained the lock.
> 
>  (4) A pointer points to NULL when you check, and points to something after
>      you've gained the lock.
> 
>  (5) A pointer points to NULL when you check, and points to NULL after you've
>      gained the lock.
> 
> However, what if you _know_ that the pointer can only ever be made non-NULL
> during initialisation, and may even be left unset?  That means possibility (4)
> can never happen, and that possibility (5) can be detected by testing before
> taking the lock.  Now, what if (5) is a common occurrence?  It might make
> sense to make the test.
> 
> And what matter if the pointer _does_ change after you test it.  If it was
> NULL before, it can only be NULL now - by the semantics defined for that
> particular pointer.
> 
> > If *something* protects the pointer from being changed, then how can be
> > expressed this fact ?
> > 
> > If nothing protects the pointer, why test it then, as result of test is
> > unreliable ?
> 
> I think you may be misunderstanding the purpose of rcu_dereference().  It is
> to make sure the reading and dereferencing of the pointer are correctly
> ordered with respect to the setting up of the pointed to record and the
> changing of the pointer.
> 
> There must be two memory accesses for the barrier implied to be of use.  In
> nfs_inode_return_delegation() there aren't two memory accesses to order,
> therefore the barrier is pointless.
> 
> > If NFS was using rcu_dereference(), it probably was for a reason, but if
> > nobody can recall it, it was a wrong reason ?
> 
> I think it is incorrectly used.  Given that the rcu_dereference() in:
> 
> 	if (rcu_dereference(nfsi->delegation) != NULL) {
> 		spin_lock(&clp->cl_lock);
> 		delegation = nfs_detach_delegation_locked(nfsi, NULL);
> 		spin_unlock(&clp->cl_lock);
> 		if (delegation != NULL)
> 			nfs_do_return_delegation(inode, delegation, 0);
> 	}

And nfs_detach_delegation_locked() rechecks nfsi->delegation() under
the lock, so this is a legitimate use.

The pointer is not held constant, but any changes will be accounted
for and handled correctly.  So I would argue that the pointer value is
in fact protected by the recheck-under-lock algorithm used here.

							Thanx, Paul

> resolves to:
> 
> 	_________p1 = nfsi->delegation;
> 	smp_read_barrier_depends();
> 	if (_________p1) {
> 		spin_lock(&clp->cl_lock); // implicit LOCK-class barrier
> 		==>nfs_detach_delegation_locked(nfsi, NULL);
> 		  [dereference nfsi->delegation]
> 		...
> 	}
> 
> do you actually need the smp_read_barrier_depends()?  You _have_ a barrier in
> the form of the spin_lock().  In fact, the spin_lock() is avowedly sufficient
> to protect accesses to and dereferences of nfsi->delegation, which means that:
> 
> 	static struct nfs_delegation *nfs_detach_delegation_locked(struct nfs_inode *nfsi, const nfs4_stateid *stateid)
> 	{
> 		struct nfs_delegation *delegation = rcu_dereference(nfsi->delegation);
> 		...
> 	}
> 
> has no need of the internal barrier provided by rcu_dereference() either.
> 
> David
