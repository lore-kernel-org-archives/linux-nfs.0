From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in nfs_inode_return_delegation_noreclaim() [ver #2]
Date: Thu, 01 Apr 2010 12:45:14 +0100
Message-ID: <14003.1270122314@redhat.com>
References: <20100401012919.GK2461@linux.vnet.ibm.com> <19192.1269889348@redhat.com> <23274.1269893706@redhat.com> <25276.1269901350@redhat.com> <26760.1269903543@redhat.com> <20100329232636.GT2569@linux.vnet.ibm.com> <2440.1269967151@redhat.com> <21972.1269993064@redhat.com> <10818.1270044273@redhat.com> <15371.1270057054@redhat.com> <19556.1270076008@redhat.com>
Cc: dhowells@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
	Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18584 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756975Ab0DARB5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Apr 2010 13:01:57 -0400
In-Reply-To: <20100401012919.GK2461@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> > I think it is incorrectly used.  Given that the rcu_dereference() in:
> > 
> > 	if (rcu_dereference(nfsi->delegation) != NULL) {
> > 		spin_lock(&clp->cl_lock);
> > 		delegation = nfs_detach_delegation_locked(nfsi, NULL);
> > 		spin_unlock(&clp->cl_lock);
> > 		if (delegation != NULL)
> > 			nfs_do_return_delegation(inode, delegation, 0);
> > 	}
> 
> And nfs_detach_delegation_locked() rechecks nfsi->delegation() under
> the lock, so this is a legitimate use.
> 
> The pointer is not held constant, but any changes will be accounted
> for and handled correctly.  So I would argue that the pointer value is
> in fact protected by the recheck-under-lock algorithm used here.

A legitimate use of what?

David
