From: David Howells <dhowells@redhat.com>
Subject: RCU condition checks
Date: Wed, 07 Apr 2010 17:35:30 +0100
Message-ID: <26884.1270658130@redhat.com>
References: <20100407155729.GA2481@linux.vnet.ibm.com> <2440.1269967151@redhat.com> <21972.1269993064@redhat.com> <10818.1270044273@redhat.com> <15371.1270057054@redhat.com> <19556.1270076008@redhat.com> <14003.1270122314@redhat.com> <4161.1270133211@redhat.com> <23331.1270570443@redhat.com> <26510.1270582446@redhat.com> <24225.1270646561@redhat.com>
Cc: dhowells@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
	Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100407155729.GA2481@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> > Why is there a need for 'c'?
> 
> An example use is where rcu_access_pointer() is legal because we are
> either initializing or cleaning up, so that no other CPU has access
> to the pointer.  In these cases, you might do something like:
> 
> 	q = rcu_access_pointer(p->a, p->refcnt == 0);

I think the main problem I have with this is that the fact that p->refcnt
should be 0 here is unrelated to the fact that we're wanting to look at the
value of p->a.  I'd say that this should be two separate statements, for
example:

	ASSERT(p->refcnt == 0);
	q = rcu_access_pointer(p->a);

I could see using a lockdep-managed ASSERT here would work, though.

The other problem I have with this is that I'm assuming rcu_access_pointer()
is simply for looking at the value of the pointer without dereferencing it -
in which case, is there any need for the lock-describing condition?


I agree, though, that:

	q = rcu_dereference_check(p->a,
				  rcu_read_lock_held() || (
				   lockdep_is_held(p->lock) &&
				   lockdep_is_held(q->lock)));

is a reasonable way of keeping the dereference and the lock checks together,
though that could equally well be written, say:

	LOCKDEP_ASSERT(rcu_read_lock_held() || (
		        lockdep_is_held(p->lock) &&
			lockdep_is_held(q->lock)));
	q = rcu_dereference_protected(p->a);

but combining those makes it easier to ensure people to write lock checking.

Davod
