From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in nfs_inode_return_delegation_noreclaim() [ver #2]
Date: Wed, 31 Mar 2010 00:51:04 +0100
Message-ID: <21972.1269993064@redhat.com>
References: <20100330164912.GG2513@linux.vnet.ibm.com> <20100329210520.GN2569@linux.vnet.ibm.com> <20100329192159.GM2569@linux.vnet.ibm.com> <20100319022527.GC2894@linux.vnet.ibm.com> <20100318133302.29754.1584.stgit@warthog.procyon.org.uk> <19192.1269889348@redhat.com> <23274.1269893706@redhat.com> <25276.1269901350@redhat.com> <26760.1269903543@redhat.com> <20100329232636.GT2569@linux.vnet.ibm.com> <2440.1269967151@redhat.com>
Cc: dhowells@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
	Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16720 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756808Ab0C3XwE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Mar 2010 19:52:04 -0400
In-Reply-To: <20100330164912.GG2513@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> Which it is, as long as the lock is held.

However, in one of the situations I'm thinking of, no lock is held.  All that
is being tested is whether the pointer to some RCU-protected data is either
NULL or non-NULL.  For example:

	@@ -345,7 +346,7 @@ int nfs_inode_return_delegation(struct inode *inode)
		struct nfs_delegation *delegation;
		int err = 0;

	-	if (rcu_dereference(nfsi->delegation) != NULL) {
	+	if (nfsi->delegation != NULL) {
			spin_lock(&clp->cl_lock);
			delegation = nfs_detach_delegation_locked(nfsi, NULL);
			spin_unlock(&clp->cl_lock);

No lock - RCU or spinlock - is held over the check of nfsi->delegation - which
causes lockdep to complain about an unguarded rcu_dereference().

However, the use of rcu_dereference() here is unnecessary with respect to the
interpolation (where appropriate) of a memory barrier because there is no
second memory access against which to order.

That said, the memory access is repeated inside nfs_detach_delegation_locked(),
which again was wrapped in an rcu_dereference():

	 static struct nfs_delegation *nfs_detach_delegation_locked(struct nfs_inode *nfsi, const nfs4_stateid *stateid)
	 {
	-	struct nfs_delegation *delegation = rcu_dereference(nfsi->delegation);
	+	struct nfs_delegation *delegation = nfsi->delegation;

		if (delegation == NULL)
			goto nomatch;

which was not necessary for its memory barrier interpolation properties in this
case because of the spin_lock() the caller now holds.


Your suggestion of using rcu_dereference_check() in both these places would
result in two unnecessary memory barriers on something like an Alpha CPU.


How about:

	static struct nfs_delegation *nfs_detach_delegation_locked(struct nfs_inode *nfsi, const nfs4_stateid *stateid)
	{
		struct nfs_delegation *delegation =
			rcu_locked_dereference(nfsi->delegation);
		...
	}

where rcu_locked_dereference() only does the lockdep magic and the dereference,
and does not include a memory barrier.  The documentation of such a function
would note this may only be used when the pointer is guarded by an exclusive
lock to prevent it from changing.

And then:

	int nfs_inode_return_delegation(struct inode *inode)
	{
		struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
		struct nfs_inode *nfsi = NFS_I(inode);
		struct nfs_delegation *delegation;
		int err = 0;

		if (rcu_pointer_not_null(nfsi->delegation)) {
			spin_lock(&clp->cl_lock);
			delegation = nfs_detach_delegation_locked(nfsi, NULL);
			spin_unlock(&clp->cl_lock);
			if (delegation != NULL) {
				nfs_msync_inode(inode);
				err = __nfs_inode_return_delegation(inode, delegation, 1);
			}
		}
		return err;
	}

where rcu_pointer_not_null() simply tests the value of the pointer, casting
away the sparse RCU annotation and not doing the lockdep check and not
including a barrier.  It would not return the value of the pointer, thus
preventing you from needing the barrier as a result.

David
