Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:56366 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088AbaLCTUi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Dec 2014 14:20:38 -0500
Received: by mail-qc0-f174.google.com with SMTP id c9so11530686qcz.5
        for <linux-nfs@vger.kernel.org>; Wed, 03 Dec 2014 11:20:37 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Wed, 3 Dec 2014 14:20:34 -0500
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>, Tejun Heo <tj@kernel.org>,
        NeilBrown <neilb@suse.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [RFC PATCH 00/14] nfsd/sunrpc: add support for a
 workqueue-based nfsd
Message-ID: <20141203142034.5c14529d@tlielax.poochiereds.net>
In-Reply-To: <CAHQdGtQzth78BzBo9Gsz8LKe4ippJv6VYtjGCDmES7viByG_gA@mail.gmail.com>
References: <1417544663-13299-1-git-send-email-jlayton@primarydata.com>
	<20141203121118.21a32fe1@notabene.brown>
	<20141202202946.1e0f399b@tlielax.poochiereds.net>
	<20141203155649.GB5013@htj.dyndns.org>
	<20141203110405.5ecc85df@tlielax.poochiereds.net>
	<20141203140202.7865bedb@tlielax.poochiereds.net>
	<CAHQdGtQzth78BzBo9Gsz8LKe4ippJv6VYtjGCDmES7viByG_gA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 3 Dec 2014 14:08:01 -0500
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Wed, Dec 3, 2014 at 2:02 PM, Jeff Layton <jeff.layton@primarydata.com> wrote:
> > On Wed, 3 Dec 2014 11:04:05 -0500
> > Jeff Layton <jlayton@primarydata.com> wrote:
> >
> >> On Wed, 3 Dec 2014 10:56:49 -0500
> >> Tejun Heo <tj@kernel.org> wrote:
> >>
> >> > Hello, Neil, Jeff.
> >> >
> >> > On Tue, Dec 02, 2014 at 08:29:46PM -0500, Jeff Layton wrote:
> >> > > That's a good point. I had originally thought that max_active on an
> >> > > unbound workqueue would be the number of concurrent jobs that could run
> >> > > across all the CPUs, but now that I look I'm not sure that's really
> >> > > the case.
> >> >
> >> > @max_active is a per-pool number.  By default, unbound wqs use
> >> > per-node pools, so @max_active would be per-node.  Currently,
> >> > @max_active is mostly meant as a protection against run-away
> >> > workqueues creating crazy number of workers, which has been enough for
> >> > the existing wq users.  *Maybe* it makes sense to make it actually
> >> > mean maximum concurrency which would prolly involve aggregated per-cpu
> >> > distribution mechanism so that we don't end up inc'ing and dec'ing the
> >> > same counter from all CPUs on each work item execution.
> >> >
> >> > However, I do agree with Neil that making it user configurable is
> >> > almost always painful.  It's usually a question without a good answer
> >> > and the same value may behave differently depending on a lot of
> >> > implementation details and a better approach, probably, is to use
> >> > @max_active as the last resort protection mechanism while providing
> >> > automatic throttling of in-flight work items which is meaningful for
> >> > the specific use cases.
> >> >
> >> > > I've heard random grumblings from various people in the past that
> >> > > workqueues have significant latency, but this is the first time I've
> >> > > really hit it in practice. If we can get this fixed, then that may be a
> >> > > significant perf win for all workqueue users. For instance, rpciod in
> >> > > the NFS client is all workqueue-based. Getting that latency down could
> >> > > really help things.
> >> > >
> >> > > I'm currently trying to roll up a kernel module for benchmarking the
> >> > > workqueue dispatching code in the hopes that we can use that to help
> >> > > nail it down.
> >> >
> >> > Definitely, there were some reportings but nothing really got tracked
> >> > down properly.  It'd be awesome to actually find out where the latency
> >> > is coming from.
> >> >
> >> > Thanks!
> >> >
> >>
> >> I think I might have figured this out (and before I go any farther
> >> allow me to say <facepalm>), thanks to the workqueue tracepoints in the
> >> code. What I noticed is that when things are fairly idle, the work is
> >> picked up quickly, but once things get busy it takes a lot longer.
> >>
> >> I think that the issue is in the design of the workqueue-based nfsd
> >> code. In particular, I attached a work_struct to the svc_xprt which is
> >> limiting the code to only process one RPC at a time for a xprt, from
> >> beginning to end.
> >>
> >> So, even if we requeue that work after the receive phase is done, the
> >> workqueue won't pick it up again until the thing is processed and the
> >> reply is sent.
> >>
> >> What I think I need to do is to do the receive phase using the
> >> work_struct attached to the xprt, and then do the rest of the
> >> processing from the context of a different work_struct (possibly one
> >> attached to the svc_rqst), which should free up the xprt's work_struct
> >> sooner.
> >>
> >> I'm going to work on changing that today and see if it improves things.
> >>
> >> Thanks for the help so far!
> >
> > Yes! That does help. The new workqueue based code is a little (a few
> > percent?) slower than the thread-based code across the board. I suspect
> > that's due to the fact that I'm having to queue each RPC to the
> > workqueue twice (once for the receive and once to do the processing).
> >
> > I suspect that I can remedy that, but I'll have to think about the best
> > way to do it.
> >
> 
> Which workqueue are you using? Since the receive code is non-blocking,
> I'd expect you might be able to use rpciod, for the initial socket
> reads, but you wouldn't want to use that for the actual knfsd
> processing.
> 

I'm using the same (nfsd) workqueue for everything. The workqueue
isn't really the bottleneck though, it's the work_struct.

Basically, the problem is that the work_struct in the svc_xprt was
remaining busy for far too long. So, even though the XPT_BUSY bit had
cleared, the work wouldn't get picked up again until the previous
workqueue job had returned.

With the change I made today, I just added a new work_struct to
svc_rqst and queue that to the same workqueue to do svc_process as soon
as the receive is done. That means though that each RPC ends up waiting
in the queue twice (once to do the receive and once to process the
RPC), and I think that's probably the reason for the performance delta.

What I think I'm going to do on the next pass is have the job that
enqueues the xprt instead try to find an svc_rqst. If it finds it,
then it can go ahead and queue the work struct in it to do the receive
and processing in a single go.

If it can't find one, it'll queue the xprt's work to allocate one and
then queue that to do all of the work as before. That will likely
penalize the case where there isn't an available svc_rqst, but in the
common case that there is one it should go quickly.

Thanks!
-- 
Jeff Layton <jlayton@primarydata.com>
