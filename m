From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in
 nfs_inode_return_delegation_noreclaim() [ver #2]
Date: Wed, 31 Mar 2010 11:30:22 -0700
Message-ID: <20100331183022.GH2461@linux.vnet.ibm.com>
References: <20100318133302.29754.1584.stgit@warthog.procyon.org.uk>
 <19192.1269889348@redhat.com>
 <23274.1269893706@redhat.com>
 <25276.1269901350@redhat.com>
 <26760.1269903543@redhat.com>
 <20100329232636.GT2569@linux.vnet.ibm.com>
 <2440.1269967151@redhat.com>
 <21972.1269993064@redhat.com>
 <10818.1270044273@redhat.com>
 <15371.1270057054@redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:48412 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756059Ab0CaSae (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 31 Mar 2010 14:30:34 -0400
In-Reply-To: <15371.1270057054@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 31, 2010 at 06:37:34PM +0100, David Howells wrote:
> Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> 
> > Protected by something that the caller did, be it holding the the correct
> > lock, operating on it during initialization before other CPUs have access
> > to it, operating on it during cleanup after other CPUs' access has been
> > revoked, or whatever.
> 
> But the point I made very early this morning still stands:  What if someone
> simply wants to test the pointer, not actually to dereference it?

OK, I was missing your point.  And this is what you were proposing
rcu_pointer_not_null() for.

> NFS was using rcu_dereference() for this in a couple of places - which is
> overkill.  I suggested stripping this off and you countered with the
> suggestion that it should be using rcu_dereference_check().
> 
> Why do I need anything at all?

Right now you don't.  We will need something as part of Arnd's patches to
shut sparse up, and I was hoping not to have to go through the find/fix
cycle twice.  But that turned out to be kind of pointless, since we
have burned far more time discussing than it would have taken to fix
it twice.  ;-)

But the discussion has been helpful, as I was previously just fine with
sprinkling otherwise-unneed rcu_dereference_whatever() calls thoughout
the kernel!

							Thanx, Paul
