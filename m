Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46089 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752757Ab0DIUuI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Apr 2010 16:50:08 -0400
Date: Fri, 9 Apr 2010 15:50:05 -0500
From: David Teigland <teigland@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: lockd and lock cancellation
Message-ID: <20100409205005.GB11823@redhat.com>
References: <20100409194018.GA11823@redhat.com>
 <4BBF8D25.7050506@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4BBF8D25.7050506@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Apr 09, 2010 at 04:25:09PM -0400, Chuck Lever wrote:
> >But, for all the kernel work on these nfs/gfs/dlm hooks, there's a larger
> >issue that no one is working on AFAIK:  the mechanisms for recovering
> >client locks on remaining gfs nodes when one gfs node fails.  That would
> >take a lot of work, and until it's done all the kernel apis will be a moot
> >point since clustered nfs locks on gfs will be unusable.
> 
> To support IPv6, I've studied and modified the NFSv2/v3 lock
> recovery mechanisms quite a bit recently.  What kernel APIs do you
> think would be needed to manage cluster lock recovery?  Just
> something to release stale locks on a single node?

I only have a general idea of what needs to be done; I think Wendy Cheng
may have written a more detailed TODO list a few years ago.  The main
problem is that when a gfs node fails, the other gfs nodes purge all
the posix locks that it held.  In the case of nfs that's a problem, of
course, because the plocks being purged didn't finally belong to that
node/server but to the clients connected to it.  The clients are still
alive and either failing over to an alternate gfs/nfs server or waiting
for the failed server to return.

So, when a gfs/nfs node/server fails, the remaining gfs servers need to
reclaim locks from the nfs clients that were connected to it, and insert
these locks into the gfs/dlm posix lock table.  That recovery of client
locks needs to happen more or less during the grace period, after the
purging of locks from the failed node and before any locks are granted.

Basically, nfs lock recovery needs to be integrated with gfs/dlm lock
recovery.

Dave
