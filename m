From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in
 nfs_inode_return_delegation_noreclaim() [ver #2]
Date: Tue, 6 Apr 2010 10:29:44 -0700
Message-ID: <20100406172944.GB2553@linux.vnet.ibm.com>
References: <26760.1269903543@redhat.com>
 <20100329232636.GT2569@linux.vnet.ibm.com>
 <2440.1269967151@redhat.com>
 <21972.1269993064@redhat.com>
 <10818.1270044273@redhat.com>
 <15371.1270057054@redhat.com>
 <19556.1270076008@redhat.com>
 <14003.1270122314@redhat.com>
 <4161.1270133211@redhat.com>
 <23331.1270570443@redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:37099 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756620Ab0DFR3r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Apr 2010 13:29:47 -0400
In-Reply-To: <23331.1270570443@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 06, 2010 at 05:14:03PM +0100, David Howells wrote:
> Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> 
> > > > So you have objected to needless memory barriers.  How do you feel
> > > > about possibly needless ACCESS_ONCE() calls?
> > > 
> > > That would work here since it shouldn't emit any excess instructions.
> > 
> > And here is the corresponding patch.  Seem reasonable?
> 
> Actually, now I've thought about it some more.  No, it's not reasonable.
> You've written:
> 
>     This patch adds a variant of rcu_dereference() that handles situations
>     where the RCU-protected data structure cannot change, perhaps due to
>     our holding the update-side lock, or where the RCU-protected pointer is
>     only to be tested, not dereferenced.
> 
> But if we hold the update-side lock, then why should we be forced to use
> ACCESS_ONCE()?
> 
> In fact, if we don't hold the lock, but we want to test the pointer twice in
> succession, why should we be required to use ACCESS_LOCK()?

OK, just to make sure I understand you...  You are asking for two additional
RCU API members:

1.	rcu_access_pointer() or some such that includes ACCESS_ONCE(),
	but not smp_read_barrier_depends(), which may be used when
	we are simply examining the value of the RCU-protected pointer
	(as in the NFS case).  It could also be used when the
	appropriate update-side lock is held, but for that we have:

2.	rcu_dereference_protected() or some such that includes neither
	ACCESS_ONCE() nor smp_read_barrier_depends(), and that may
	only be used if updates are prevented, for example, by holding
	the appropriate update-side lock.

Does this fit?

							Thanx, Paul
