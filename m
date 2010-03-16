From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in nfs_inode_return_delegation_noreclaim()
Date: Tue, 16 Mar 2010 16:37:05 +0000
Message-ID: <16115.1268757425@redhat.com>
References: <1268744823.3155.15.camel@localhost.localdomain> <20100316115130.25642.17789.stgit@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26466 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759115Ab0CPQhd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Mar 2010 12:37:33 -0400
In-Reply-To: <1268744823.3155.15.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> > +	rcu_read_lock();
> >  	cred = rcu_dereference(delegation->cred);
> >  	rcu_assign_pointer(delegation->cred, NULL);
> > +	rcu_read_unlock();
> >  	call_rcu(&delegation->rcu, nfs_free_delegation_callback);
> >  	if (cred)
> >  		put_rpccred(cred);
> 
> That's bogus. We're in the process of freeing the delegation, so we
> don't need to rely on rcu to read delegation->cred.
> 
> Better to just convert that rcu_dereference() into an ordinary pointer
> dereference.

Now that I take a second look at this code, it looks wrong.  You shouldn't
really start dissassembling the delegation record until the RCU callback
triggers as it may be in use by someone up to that point.  If you know it
isn't in use at this point, why use call_rcu()?

> The spinlock already provides protection. Again we can just convert the
> rcu_dereference() into a pointer dereference.

That seems reasonable.

> We cannot hold the rcu read lock across the entire RPC call in
> nfs_do_return_delegation(). All we want to do above is to check that
> nfsi->delegation != NULL.

Good point.

However, that leads me to note that nfs_detach_delegation_locked() then must
be using rcu_dereference() unnecessarily.  Also nfs_do_return_delegation()
must be too.

I think if all you're doing is checking the state of the pointer, you don't
need the interpolated memory barrier, since you've no need to synchronise what
the pointer points to.

David
