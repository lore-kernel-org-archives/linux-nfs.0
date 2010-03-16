From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in
 nfs_inode_return_delegation_noreclaim()
Date: Tue, 16 Mar 2010 14:41:44 -0400
Message-ID: <1268764904.3098.21.camel@localhost.localdomain>
References: <1268760954.3098.17.camel@localhost.localdomain>
	 <20100316115130.25642.17789.stgit@warthog.procyon.org.uk>
	 <20100316171738.GN6709@linux.vnet.ibm.com>  <19197.1268761204@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: paulmck@linux.vnet.ibm.com, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3432 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752818Ab0CPSm1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Mar 2010 14:42:27 -0400
In-Reply-To: <19197.1268761204@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2010-03-16 at 17:40 +0000, David Howells wrote: 
> Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> 
> > > The lock is probably held here, in which case something like the
> > > following would work well without needing the artificial rcu_read_lock()
> > > and rcu_read_unlock():
> > 
> > No. The lock is not held here. At this point, the delegation has been
> > detached from the inode that pointed to it, and so we can free up its
> > contents.
> > 
> > We still need the call_rcu() to free up the allocated memory in order to
> > ensure that some process doing lockless traversal of the
> > clp->cl_delegations list doesn't crash.
> 
> In that case, surely you can't detach the credentials pointer until the
> callback is invoked?

We can, because the process that is traversing the list has to lock the
delegation and test whether it is still attached or not before it can
dereference and use the contents.

In fact, that credential pointer is only really meant to be used when we
need to return the delegation. Once we get to the nfs_free_delegation()
bit, it is no longer needed.

Cheers
  Trond
