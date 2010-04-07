From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in nfs_inode_return_delegation_noreclaim() [ver #2]
Date: Wed, 07 Apr 2010 14:22:41 +0100
Message-ID: <24225.1270646561@redhat.com>
References: <20100407000203.GI2553@linux.vnet.ibm.com> <20100329232636.GT2569@linux.vnet.ibm.com> <2440.1269967151@redhat.com> <21972.1269993064@redhat.com> <10818.1270044273@redhat.com> <15371.1270057054@redhat.com> <19556.1270076008@redhat.com> <14003.1270122314@redhat.com> <4161.1270133211@redhat.com> <23331.1270570443@redhat.com> <26510.1270582446@redhat.com>
Cc: dhowells@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
	Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48462 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753355Ab0DGNWu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Apr 2010 09:22:50 -0400
In-Reply-To: <20100407000203.GI2553@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> +#define rcu_access_pointer(p, c) \

Why is there a need for 'c'?

> +#define rcu_dereference_protect(p, c) \

I'd prefer rcu_dereference_protected(), I think.  This macro doesn't protect
anything.  Also, again, why the need for 'c'?

For instance, in:

	static struct nfs_delegation *nfs_detach_delegation_locked(struct nfs_inode *nfsi, const nfs4_stateid *stateid)
	{
		struct nfs_delegation *delegation =
			rcu_dereference_protected(nfsi->delegation, ????);

what would be the condition?  That the spinlock is held?  That's a condition
for calling the function.

And in:

	void nfs_inode_return_delegation_noreclaim(struct inode *inode)
	{
		struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
		struct nfs_inode *nfsi = NFS_I(inode);
		struct nfs_delegation *delegation;

		if (rcu_access_pointer(nfsi->delegation, ????) != NULL) {

what would be the condition here?  There's no lock to check - that's the whole
point of the macro.  I also can't give it nfsi->delegation to check as the
value may change between the two accesses.

David
