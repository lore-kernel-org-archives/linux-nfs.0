From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in nfs_inode_return_delegation_noreclaim()
Date: Tue, 16 Mar 2010 17:40:04 +0000
Message-ID: <19197.1268761204@redhat.com>
References: <1268760954.3098.17.camel@localhost.localdomain> <20100316115130.25642.17789.stgit@warthog.procyon.org.uk> <20100316171738.GN6709@linux.vnet.ibm.com>
Cc: dhowells@redhat.com, paulmck@linux.vnet.ibm.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8007 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933221Ab0CPRka (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Mar 2010 13:40:30 -0400
In-Reply-To: <1268760954.3098.17.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> > The lock is probably held here, in which case something like the
> > following would work well without needing the artificial rcu_read_lock()
> > and rcu_read_unlock():
> 
> No. The lock is not held here. At this point, the delegation has been
> detached from the inode that pointed to it, and so we can free up its
> contents.
> 
> We still need the call_rcu() to free up the allocated memory in order to
> ensure that some process doing lockless traversal of the
> clp->cl_delegations list doesn't crash.

In that case, surely you can't detach the credentials pointer until the
callback is invoked?

David
