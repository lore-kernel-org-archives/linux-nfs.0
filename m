From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in
 nfs_inode_return_delegation_noreclaim() [ver #2]
Date: Tue, 30 Mar 2010 10:01:37 -0700
Message-ID: <20100330170137.GH2513@linux.vnet.ibm.com>
References: <20100329223609.GR2569@linux.vnet.ibm.com>
 <20100329210520.GN2569@linux.vnet.ibm.com>
 <20100329192159.GM2569@linux.vnet.ibm.com>
 <20100319022527.GC2894@linux.vnet.ibm.com>
 <20100318133302.29754.1584.stgit@warthog.procyon.org.uk>
 <19192.1269889348@redhat.com>
 <23274.1269893706@redhat.com>
 <25276.1269901350@redhat.com>
 <26760.1269903543@redhat.com>
 <2397.1269967069@redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:32785 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752795Ab0C3RBk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Mar 2010 13:01:40 -0400
In-Reply-To: <2397.1269967069@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 30, 2010 at 05:37:49PM +0100, David Howells wrote:
> Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> 
> > rcu: Add update-side variant of rcu_dereference()
> > 
> > Upcoming consistency-checking features are requiring that even update-side
> > accesses to RCU-protected pointers use some variant of rcu_dereference().
> > Even though rcu_dereference() is quite lightweight, it does constrain the
> > compiler, thus producing code that is worse than required.  This patch
> > therefore adds rcu_dereference_update(), which allows lockdep-style
> > checks for holding the correct update-side lock, but which does not
> > constrain the compiler.
> 
> Ummm...  I'm not so keen on the name for two reasons.  Firstly, why shouldn't
> the read side do:
> 
> 	struct foo {
> 		struct bar *b;
> 	};
> 
> 	void manage_bar(struct foo *f)
> 	{
> 		struct bar *b;
> 
> 		rcu_read_lock();
> 		b = rcu_dereference(f->b);
> 		if (b)
> 			do_something_to_bar(b);
> 		rcu_read_unlock();
> 	}
> 
> 	void manage_foo(struct foo *f)
> 	{
> 		...
> 		if (f->b)
> 			manage_bar(f);
> 		...
> 	}
> 
> Why should this be limited to the update side?

The main criterion is that you have to have done something to prevent
the data structure from changing, which normally only happens on the
update side.

> Secondly, the name rcu_dereference_update() seems to imply that this function
> itself does an update, perhaps after having done an rcu_dereference().

Indeed, that is rather ugly.

> Perhaps rcu_pointer_valid()?
> 
> 	if (rcu_pointer_valid(f->b))
> 		manage_bar(f);

Hmmm...  That sounds like something that checks the pointer for
correct format or for pointing to valid data.

> or if you really do want to limit this sort of thing to the update side:
> 
> 	if (rcu_destination_for_update(f->b)) {
> 		spin_lock(&f->lock);
> 		update_bar(f);
> 		spin_unlock(&f->lock);
> 	}

What we are doing is dereferencing an RCU-protected pointer that we
are somehow preventing from being concurrently updated, usually by
holding the update-side lock.

So maybe rcu_dereference_no_updates()?  Or rcu_dereference_locked()?

But not rcu_dereference_with_concurrent_updates_somehow_prevented().  ;-)

> Another possibility is have an 'RCU write lock' that just does the lockdep
> thing and doesn't interpolate a barrier:
> 
> 	rcu_write_lock();
> 	if (rcu_dereference_for_update(f->b)) {
> 		spin_lock(&f->lock);
> 		update_bar(f->b);
> 		spin_unlock(&f->lock);
> 	}
> 	rcu_write_unlock();

This would work for the moment, but I do not believe that sparse can
deal with tracking rcu_write_lock() across compilation units.  Besides, I
really really don't want anything that looks like it is somehow protecting
the update.  Too many newcomers to RCU somehow get the impression that
rcu_assign_pointer() provides that protection as it is.  :-/

> Or might it make sense to roll together with the lock primitive:
> 
> 	if (rcu_dereference_and_lock(f->b, &f->lock)) {
> 		update_bar(f);
> 		spin_unlock(&f->lock);
> 	}
> 
> (I'm not keen on that one because you might not want to take the lock
>  immediately, and you have a wide choice of locks).

Indeed, the API explosion might be a bit unpleasant.  ;-)

So, how about rcu_dereference_locked()?

> Sorry to be picky.

Given that I worked quite happily with RCU for quite some time without
any words for any of the underlying concepts, I cannot claim that I
don't need at least some help with name selection.  ;-)

							Thanx, Paul
