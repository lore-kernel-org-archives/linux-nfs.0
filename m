From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in nfs_inode_return_delegation_noreclaim() [ver #2]
Date: Mon, 29 Mar 2010 21:15:06 +0100
Message-ID: <23274.1269893706@redhat.com>
References: <20100329192159.GM2569@linux.vnet.ibm.com> <20100319022527.GC2894@linux.vnet.ibm.com> <20100318133302.29754.1584.stgit@warthog.procyon.org.uk> <19192.1269889348@redhat.com>
Cc: dhowells@redhat.com, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100329192159.GM2569@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> > > 	if (rcu_dereference_check(nfsi->delegation,
> > > 				  lockdep_is_held(&clp->cl_lock)) != NULL) {
> > 
> > If clp->cl_lock protects this pointer, why the need for
> > rcu_dereference_check() at all?  The check is redundant since the line
> > above gets the very lock we're checking for.
> 
> Because Arnd Bergmann is working on a set of patches that makes sparse
> complain if you access an RCU-protected pointer directly, without using
> some flavor of rcu_dereference().
> 
> So your approach would work for the moment, but would need another
> change, probably in the 2.6.35 timeframe.

My objection to using rcu_dereference_check() here is that it's a dynamic
check: the compiler emits code to do it, since the lock/unlock status of what
the pointer points to cannot be determined easily at compiler time - and then
the barrier is interpolated anyway unnecessarily.

David
