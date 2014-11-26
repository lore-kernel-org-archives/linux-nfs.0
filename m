Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43938 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751278AbaKZAJm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Nov 2014 19:09:42 -0500
Date: Tue, 25 Nov 2014 19:09:41 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Chris Worley <chris.worley@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/4] sunrpc: reduce pool->sp_lock contention when
 queueing a xprt for servicing
Message-ID: <20141126000941.GF15033@fieldses.org>
References: <1416597571-4265-1-git-send-email-jlayton@primarydata.com>
 <20141125162557.0893c44c@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141125162557.0893c44c@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 25, 2014 at 04:25:57PM -0500, Jeff Layton wrote:
> On Fri, 21 Nov 2014 14:19:27 -0500
> Jeff Layton <jlayton@primarydata.com> wrote:
> 
> > Hi Bruce!
> > 
> > Here are the patches that I had mentioned earlier that reduce the
> > contention for the pool->sp_lock when the server is heavily loaded.
> > 
> > The basic problem is that whenever a svc_xprt needs to be queued up for
> > servicing, we have to take the pool->sp_lock to try and find an idle
> > thread to service it.  On a busy server, that lock becomes highly
> > contended and that limits the throughput.
> > 
> > This patchset fixes this by changing how we search for an idle thread.
> > First, we convert svc_rqst and the sp_all_threads list to be
> > RCU-managed. Then we change the search for an idle thread to use the
> > sp_all_threads list, which now can be done under the rcu_read_lock.
> > When there is an available thread, queueing an xprt to it can now be
> > done without any spinlocking.
> > 
> > With this, we see a pretty substantial increase in performance on a
> > larger-scale server that is heavily loaded. Chris has some preliminary
> > numbers, but they need to be cleaned up a bit before we can present
> > them. I'm hoping to have those by early next week.
> > 
> > Jeff Layton (4):
> >   sunrpc: add a rcu_head to svc_rqst and use kfree_rcu to free it
> >   sunrpc: fix potential races in pool_stats collection
> >   sunrpc: convert to lockless lookup of queued server threads
> >   sunrpc: add some tracepoints around enqueue and dequeue of svc_xprt
> > 
> >  include/linux/sunrpc/svc.h    |  12 +-
> >  include/trace/events/sunrpc.h |  98 +++++++++++++++-
> >  net/sunrpc/svc.c              |  17 +--
> >  net/sunrpc/svc_xprt.c         | 252 ++++++++++++++++++++++++------------------
> >  4 files changed, 258 insertions(+), 121 deletions(-)
> > 
> 
> Here's what I've got so far.
> 
> This is just a chart that shows the % increase in the number of iops in
> a distributed test on a NFSv3 server with this patchset vs. without.
> 
> The numbers along the bottom show the number of total job threads
> running. Chris says:
> 
> "There were 64 nfsd threads running on the server.
> 
>  There were 7 hypervisors running 2 VMs each running 2 and 4 threads per
>  VM.  Thus, 56 and 112 threads total."

Thanks!

Results that someone else could reproduce would be much better.
(Where's the source code for the test?  What's the base the patchset was
applied to?  What was the hardware?  I understand that's a lot of
information.)  But it's nice to see some numbers at least.

(I wonder what the reason is for the odd shape in the 112-thread case
(descending slightly as the writes decrease and then shooting up when
they go to zero.)  OK, I guess that's what you get if you just assume
read-write contention is expensive and one write is slightly more
expensive than one read.  But then why doesn't it behave the same way in
the 56-thread case?)

--b.

> 
> Cheers!
> -- 
> Jeff Layton <jlayton@primarydata.com>


