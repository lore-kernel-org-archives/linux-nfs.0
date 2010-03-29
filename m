From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in
 nfs_inode_return_delegation_noreclaim() [ver #2]
Date: Mon, 29 Mar 2010 12:21:59 -0700
Message-ID: <20100329192159.GM2569@linux.vnet.ibm.com>
References: <20100319022527.GC2894@linux.vnet.ibm.com>
 <20100318133302.29754.1584.stgit@warthog.procyon.org.uk>
 <19192.1269889348@redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:60966 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753328Ab0C2TWC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Mar 2010 15:22:02 -0400
In-Reply-To: <19192.1269889348@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 29, 2010 at 08:02:28PM +0100, David Howells wrote:
> Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> 
> > >  	spin_lock(&clp->cl_lock);
> > > -	if (rcu_dereference(nfsi->delegation) != NULL) {
> > > +	if (nfsi->delegation != NULL) {
> > 
> > And this one.  I thought that Trond said that clp->cl_lock protects
> > this one, in which case this should work:
> > 
> > 	if (rcu_dereference_check(nfsi->delegation,
> > 				  lockdep_is_held(&clp->cl_lock)) != NULL) {
> 
> If clp->cl_lock protects this pointer, why the need for rcu_dereference_check()
> at all?  The check is redundant since the line above gets the very lock we're
> checking for.

Because Arnd Bergmann is working on a set of patches that makes sparse
complain if you access an RCU-protected pointer directly, without using
some flavor of rcu_dereference().

So your approach would work for the moment, but would need another
change, probably in the 2.6.35 timeframe.

> > > -	if (rcu_dereference(nfsi->delegation) != NULL) {
> > > +	if (nfsi->delegation != NULL) {
> > 
> > And this one, although the check for cp->cl_lock obviously won't work here.
> > 
> > >  		spin_lock(&clp->cl_lock);
> > >  		delegation = nfs_detach_delegation_locked(nfsi, NULL);
> > >  		spin_unlock(&clp->cl_lock);
> 
> On this one, why does nfsi->delegation need a memory barrier interpolating
> afterwards?  It has an implicit one in the form of the spin_lock() immediately
> after, if the value of the pointer wasn't NULL.  What two memory accesses is
> the memory barrier ordering?
> 
> Ditto on the next one.

I must defer to Trond on this one.

							Thanx, Paul
