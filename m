From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in
 nfs_inode_return_delegation_noreclaim() [ver #2]
Date: Mon, 29 Mar 2010 14:05:20 -0700
Message-ID: <20100329210520.GN2569@linux.vnet.ibm.com>
References: <20100329192159.GM2569@linux.vnet.ibm.com>
 <20100319022527.GC2894@linux.vnet.ibm.com>
 <20100318133302.29754.1584.stgit@warthog.procyon.org.uk>
 <19192.1269889348@redhat.com>
 <23274.1269893706@redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:52095 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751240Ab0C2VFX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Mar 2010 17:05:23 -0400
In-Reply-To: <23274.1269893706@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 29, 2010 at 09:15:06PM +0100, David Howells wrote:
> Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> 
> > > > 	if (rcu_dereference_check(nfsi->delegation,
> > > > 				  lockdep_is_held(&clp->cl_lock)) != NULL) {
> > > 
> > > If clp->cl_lock protects this pointer, why the need for
> > > rcu_dereference_check() at all?  The check is redundant since the line
> > > above gets the very lock we're checking for.
> > 
> > Because Arnd Bergmann is working on a set of patches that makes sparse
> > complain if you access an RCU-protected pointer directly, without using
> > some flavor of rcu_dereference().
> > 
> > So your approach would work for the moment, but would need another
> > change, probably in the 2.6.35 timeframe.
> 
> My objection to using rcu_dereference_check() here is that it's a dynamic
> check: the compiler emits code to do it, since the lock/unlock status of what
> the pointer points to cannot be determined easily at compiler time - and then
> the barrier is interpolated anyway unnecessarily.

But for !CONFIG_PROVE_RCU, rcu_dereference_check() is compiled out:

	#define rcu_dereference_check(p, c)     rcu_dereference_raw(p)

And rcu_dereference_raw() is the same as the old rcu_dereference().

So this should not be a problem, given that CONFIG_PROVE_RCU should not
be used for production systems.

							Thanx, Paul
