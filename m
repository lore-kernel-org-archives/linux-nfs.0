Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f41.google.com ([209.85.192.41]:65395 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975AbaKZAiV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Nov 2014 19:38:21 -0500
Received: by mail-qg0-f41.google.com with SMTP id j5so1345254qga.0
        for <linux-nfs@vger.kernel.org>; Tue, 25 Nov 2014 16:38:21 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 25 Nov 2014 19:38:18 -0500
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        Chris Worley <chris.worley@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/4] sunrpc: reduce pool->sp_lock contention when
 queueing a xprt for servicing
Message-ID: <20141125193818.3800fd0d@tlielax.poochiereds.net>
In-Reply-To: <20141126000941.GF15033@fieldses.org>
References: <1416597571-4265-1-git-send-email-jlayton@primarydata.com>
	<20141125162557.0893c44c@tlielax.poochiereds.net>
	<20141126000941.GF15033@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 25 Nov 2014 19:09:41 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Nov 25, 2014 at 04:25:57PM -0500, Jeff Layton wrote:
> > On Fri, 21 Nov 2014 14:19:27 -0500
> > Jeff Layton <jlayton@primarydata.com> wrote:
> > 
> > > Hi Bruce!
> > > 
> > > Here are the patches that I had mentioned earlier that reduce the
> > > contention for the pool->sp_lock when the server is heavily loaded.
> > > 
> > > The basic problem is that whenever a svc_xprt needs to be queued up for
> > > servicing, we have to take the pool->sp_lock to try and find an idle
> > > thread to service it.  On a busy server, that lock becomes highly
> > > contended and that limits the throughput.
> > > 
> > > This patchset fixes this by changing how we search for an idle thread.
> > > First, we convert svc_rqst and the sp_all_threads list to be
> > > RCU-managed. Then we change the search for an idle thread to use the
> > > sp_all_threads list, which now can be done under the rcu_read_lock.
> > > When there is an available thread, queueing an xprt to it can now be
> > > done without any spinlocking.
> > > 
> > > With this, we see a pretty substantial increase in performance on a
> > > larger-scale server that is heavily loaded. Chris has some preliminary
> > > numbers, but they need to be cleaned up a bit before we can present
> > > them. I'm hoping to have those by early next week.
> > > 
> > > Jeff Layton (4):
> > >   sunrpc: add a rcu_head to svc_rqst and use kfree_rcu to free it
> > >   sunrpc: fix potential races in pool_stats collection
> > >   sunrpc: convert to lockless lookup of queued server threads
> > >   sunrpc: add some tracepoints around enqueue and dequeue of svc_xprt
> > > 
> > >  include/linux/sunrpc/svc.h    |  12 +-
> > >  include/trace/events/sunrpc.h |  98 +++++++++++++++-
> > >  net/sunrpc/svc.c              |  17 +--
> > >  net/sunrpc/svc_xprt.c         | 252 ++++++++++++++++++++++++------------------
> > >  4 files changed, 258 insertions(+), 121 deletions(-)
> > > 
> > 
> > Here's what I've got so far.
> > 
> > This is just a chart that shows the % increase in the number of iops in
> > a distributed test on a NFSv3 server with this patchset vs. without.
> > 
> > The numbers along the bottom show the number of total job threads
> > running. Chris says:
> > 
> > "There were 64 nfsd threads running on the server.
> > 
> >  There were 7 hypervisors running 2 VMs each running 2 and 4 threads per
> >  VM.  Thus, 56 and 112 threads total."
> 
> Thanks!
> 

Good questions all around. I'll try to answer them as best I can:

> Results that someone else could reproduce would be much better.
> (Where's the source code for the test?

The test is just fio (which is available in the fedora repos, fwiw):

    http://git.kernel.dk/?p=fio.git;a=summary

...but we'd have to ask Chris for the job files. Chris, can those be
released?

>  What's the base the patchset was
> applied to?

The base was a v3.14-ish kernel with a pile of patches on top (mostly,
the ones that Trond asked you to merge for v3.18). The only difference
between the "baseline" and "patched" kernels is this set, plus a few
patches from upstream that made it apply more cleanly. None of those
should have much effect on the results though.

> What was the hardware? 

Again, I'll have to defer that question to Chris. I don't know much
about the hw in use here, other than that it has some pretty fast
storage (high perf. SSDs).

> I understand that's a lot of
> information.)  But it's nice to see some numbers at least.
> 
> (I wonder what the reason is for the odd shape in the 112-thread case
> (descending slightly as the writes decrease and then shooting up when
> they go to zero.)  OK, I guess that's what you get if you just assume
> read-write contention is expensive and one write is slightly more
> expensive than one read.  But then why doesn't it behave the same way in
> the 56-thread case?)
> 

Yeah, I wondered about that too.

There is some virtualization in use on the clients here (and it's
vmware too), so I have to wonder if there's some variance in the
numbers due to weirdo virt behaviors or something.

The good news is that the overall trend pretty clearly shows a
performance increase.

As always, benchmark results point out the need for more benchmarks.

-- 
Jeff Layton <jlayton@primarydata.com>
