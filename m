From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in nfs_inode_return_delegation_noreclaim() [ver #2]
Date: Mon, 29 Mar 2010 20:02:28 +0100
Message-ID: <19192.1269889348@redhat.com>
References: <20100319022527.GC2894@linux.vnet.ibm.com> <20100318133302.29754.1584.stgit@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29298 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750957Ab0C2TCe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Mar 2010 15:02:34 -0400
In-Reply-To: <20100319022527.GC2894@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> >  	spin_lock(&clp->cl_lock);
> > -	if (rcu_dereference(nfsi->delegation) != NULL) {
> > +	if (nfsi->delegation != NULL) {
> 
> And this one.  I thought that Trond said that clp->cl_lock protects
> this one, in which case this should work:
> 
> 	if (rcu_dereference_check(nfsi->delegation,
> 				  lockdep_is_held(&clp->cl_lock)) != NULL) {

If clp->cl_lock protects this pointer, why the need for rcu_dereference_check()
at all?  The check is redundant since the line above gets the very lock we're
checking for.

> > -	if (rcu_dereference(nfsi->delegation) != NULL) {
> > +	if (nfsi->delegation != NULL) {
> 
> And this one, although the check for cp->cl_lock obviously won't work here.
> 
> >  		spin_lock(&clp->cl_lock);
> >  		delegation = nfs_detach_delegation_locked(nfsi, NULL);
> >  		spin_unlock(&clp->cl_lock);

On this one, why does nfsi->delegation need a memory barrier interpolating
afterwards?  It has an implicit one in the form of the spin_lock() immediately
after, if the value of the pointer wasn't NULL.  What two memory accesses is
the memory barrier ordering?

Ditto on the next one.

David
