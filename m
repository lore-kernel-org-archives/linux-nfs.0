From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in nfs_inode_return_delegation_noreclaim() [ver #2]
Date: Tue, 06 Apr 2010 17:14:03 +0100
Message-ID: <23331.1270570443@redhat.com>
References: <20100405175754.GE2525@linux.vnet.ibm.com> <25276.1269901350@redhat.com> <26760.1269903543@redhat.com> <20100329232636.GT2569@linux.vnet.ibm.com> <2440.1269967151@redhat.com> <21972.1269993064@redhat.com> <10818.1270044273@redhat.com> <15371.1270057054@redhat.com> <19556.1270076008@redhat.com> <14003.1270122314@redhat.com> <4161.1270133211@redhat.com>
Cc: dhowells@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
	Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5633 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755637Ab0DFQOJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Apr 2010 12:14:09 -0400
In-Reply-To: <20100405175754.GE2525@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> > > So you have objected to needless memory barriers.  How do you feel
> > > about possibly needless ACCESS_ONCE() calls?
> > 
> > That would work here since it shouldn't emit any excess instructions.
> 
> And here is the corresponding patch.  Seem reasonable?

Actually, now I've thought about it some more.  No, it's not reasonable.
You've written:

    This patch adds a variant of rcu_dereference() that handles situations
    where the RCU-protected data structure cannot change, perhaps due to
    our holding the update-side lock, or where the RCU-protected pointer is
    only to be tested, not dereferenced.

But if we hold the update-side lock, then why should we be forced to use
ACCESS_ONCE()?

In fact, if we don't hold the lock, but we want to test the pointer twice in
succession, why should we be required to use ACCESS_LOCK()?

David
