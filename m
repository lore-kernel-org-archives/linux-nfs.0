From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in
 nfs_inode_return_delegation_noreclaim() [ver #2]
Date: Thu, 1 Apr 2010 07:39:44 -0700
Message-ID: <20100401143944.GA2472@linux.vnet.ibm.com>
References: <23274.1269893706@redhat.com>
 <25276.1269901350@redhat.com>
 <26760.1269903543@redhat.com>
 <20100329232636.GT2569@linux.vnet.ibm.com>
 <2440.1269967151@redhat.com>
 <21972.1269993064@redhat.com>
 <10818.1270044273@redhat.com>
 <15371.1270057054@redhat.com>
 <19556.1270076008@redhat.com>
 <14003.1270122314@redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:40701 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751396Ab0DAOjq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Apr 2010 10:39:46 -0400
In-Reply-To: <14003.1270122314@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 01, 2010 at 12:45:14PM +0100, David Howells wrote:
> Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> 
> > > I think it is incorrectly used.  Given that the rcu_dereference() in:
> > > 
> > > 	if (rcu_dereference(nfsi->delegation) != NULL) {
> > > 		spin_lock(&clp->cl_lock);
> > > 		delegation = nfs_detach_delegation_locked(nfsi, NULL);
> > > 		spin_unlock(&clp->cl_lock);
> > > 		if (delegation != NULL)
> > > 			nfs_do_return_delegation(inode, delegation, 0);
> > > 	}
> > 
> > And nfs_detach_delegation_locked() rechecks nfsi->delegation() under
> > the lock, so this is a legitimate use.
> > 
> > The pointer is not held constant, but any changes will be accounted
> > for and handled correctly.  So I would argue that the pointer value is
> > in fact protected by the recheck-under-lock algorithm used here.
> 
> A legitimate use of what?

A legitimate use of loading an RCU-protected pointer without
smp_read_barrier_depends().  However, I could imagine some situations
where the ACCESS_ONCE() semantics were required -- though in this
particular situation, I am having a hard time seeing how the compiler
could mess us up.  That said, my time on the C++ standards committee
has given me new respect for the perversity of compiler writers.

So you have objected to needless memory barriers.  How do you feel
about possibly needless ACCESS_ONCE() calls?

							Thanx, Paul
