From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in nfs_inode_return_delegation_noreclaim() [ver #2]
Date: Tue, 30 Mar 2010 17:37:49 +0100
Message-ID: <2397.1269967069@redhat.com>
References: <20100329232636.GT2569@linux.vnet.ibm.com> <20100329223609.GR2569@linux.vnet.ibm.com> <20100329210520.GN2569@linux.vnet.ibm.com> <20100329192159.GM2569@linux.vnet.ibm.com> <20100319022527.GC2894@linux.vnet.ibm.com> <20100318133302.29754.1584.stgit@warthog.procyon.org.uk> <19192.1269889348@redhat.com> <23274.1269893706@redhat.com> <25276.1269901350@redhat.com> <26760.1269903543@redhat.com>
Cc: dhowells@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
	Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61958 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752312Ab0C3Qig (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Mar 2010 12:38:36 -0400
In-Reply-To: <20100329232636.GT2569@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> rcu: Add update-side variant of rcu_dereference()
> 
> Upcoming consistency-checking features are requiring that even update-side
> accesses to RCU-protected pointers use some variant of rcu_dereference().
> Even though rcu_dereference() is quite lightweight, it does constrain the
> compiler, thus producing code that is worse than required.  This patch
> therefore adds rcu_dereference_update(), which allows lockdep-style
> checks for holding the correct update-side lock, but which does not
> constrain the compiler.

Ummm...  I'm not so keen on the name for two reasons.  Firstly, why shouldn't
the read side do:

	struct foo {
		struct bar *b;
	};

	void manage_bar(struct foo *f)
	{
		struct bar *b;

		rcu_read_lock();
		b = rcu_dereference(f->b);
		if (b)
			do_something_to_bar(b);
		rcu_read_unlock();
	}

	void manage_foo(struct foo *f)
	{
		...
		if (f->b)
			manage_bar(f);
		...
	}

Why should this be limited to the update side?


Secondly, the name rcu_dereference_update() seems to imply that this function
itself does an update, perhaps after having done an rcu_dereference().

Perhaps rcu_pointer_valid()?

	if (rcu_pointer_valid(f->b))
		manage_bar(f);

or if you really do want to limit this sort of thing to the update side:

	if (rcu_destination_for_update(f->b)) {
		spin_lock(&f->lock);
		update_bar(f);
		spin_unlock(&f->lock);
	}

Another possibility is have an 'RCU write lock' that just does the lockdep
thing and doesn't interpolate a barrier:

	rcu_write_lock();
	if (rcu_dereference_for_update(f->b)) {
		spin_lock(&f->lock);
		update_bar(f->b);
		spin_unlock(&f->lock);
	}
	rcu_write_unlock();

Or might it make sense to roll together with the lock primitive:

	if (rcu_dereference_and_lock(f->b, &f->lock)) {
		update_bar(f);
		spin_unlock(&f->lock);
	}

(I'm not keen on that one because you might not want to take the lock
 immediately, and you have a wide choice of locks).

Sorry to be picky.

David
