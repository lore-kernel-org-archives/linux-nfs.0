Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:49936 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753370AbaLDLrO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2014 06:47:14 -0500
Received: by mail-qc0-f174.google.com with SMTP id c9so12448175qcz.19
        for <linux-nfs@vger.kernel.org>; Thu, 04 Dec 2014 03:47:13 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 4 Dec 2014 06:47:11 -0500
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>, Tejun Heo <tj@kernel.org>,
        NeilBrown <neilb@suse.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [RFC PATCH 00/14] nfsd/sunrpc: add support for a
 workqueue-based nfsd
Message-ID: <20141204064711.72d48317@tlielax.poochiereds.net>
In-Reply-To: <CAHQdGtSbkvkGnDykEn0RnDJ5infX39N8cQObhDod+Vy4KX3Gnw@mail.gmail.com>
References: <1417544663-13299-1-git-send-email-jlayton@primarydata.com>
	<20141203121118.21a32fe1@notabene.brown>
	<20141202202946.1e0f399b@tlielax.poochiereds.net>
	<20141203155649.GB5013@htj.dyndns.org>
	<20141203110405.5ecc85df@tlielax.poochiereds.net>
	<20141203140202.7865bedb@tlielax.poochiereds.net>
	<CAHQdGtQzth78BzBo9Gsz8LKe4ippJv6VYtjGCDmES7viByG_gA@mail.gmail.com>
	<20141203142034.5c14529d@tlielax.poochiereds.net>
	<CAHQdGtSoep_F82tDUoxKar+QvmL1tdHsYgYSrYtktndYJP8g5A@mail.gmail.com>
	<20141203152147.2ca6c6fd@tlielax.poochiereds.net>
	<CAHQdGtSbkvkGnDykEn0RnDJ5infX39N8cQObhDod+Vy4KX3Gnw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 3 Dec 2014 15:44:31 -0500
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Wed, Dec 3, 2014 at 3:21 PM, Jeff Layton <jeff.layton@primarydata.com> wrote:
> > On Wed, 3 Dec 2014 14:59:43 -0500
> > Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> >
> >> On Wed, Dec 3, 2014 at 2:20 PM, Jeff Layton <jeff.layton@primarydata.com> wrote:
> >> > On Wed, 3 Dec 2014 14:08:01 -0500
> >> > Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> >> >> Which workqueue are you using? Since the receive code is non-blocking,
> >> >> I'd expect you might be able to use rpciod, for the initial socket
> >> >> reads, but you wouldn't want to use that for the actual knfsd
> >> >> processing.
> >> >>
> >> >
> >> > I'm using the same (nfsd) workqueue for everything. The workqueue
> >> > isn't really the bottleneck though, it's the work_struct.
> >> >
> >> > Basically, the problem is that the work_struct in the svc_xprt was
> >> > remaining busy for far too long. So, even though the XPT_BUSY bit had
> >> > cleared, the work wouldn't get picked up again until the previous
> >> > workqueue job had returned.
> >> >
> >> > With the change I made today, I just added a new work_struct to
> >> > svc_rqst and queue that to the same workqueue to do svc_process as soon
> >> > as the receive is done. That means though that each RPC ends up waiting
> >> > in the queue twice (once to do the receive and once to process the
> >> > RPC), and I think that's probably the reason for the performance delta.
> >>
> >> Why would the queuing latency still be significant now?
> >>
> >
> > That, I'm not clear on yet and that may not be why this is slower. But,
> > I was seeing slightly faster performance with reads before I made
> > today's changes. If changing how these jobs get queued doesn't help the
> > performance, then I'll have to look elsewhere...
> 
> Do you have a good method for measuring that latency? If the queuing
> latency turns out to depend on the execution latency for each job,
> then perhaps running the message receives on a separate low latency
> queue could help (hence the suggestion to use rpciod).
> 

I was using ftrace with the sunrpc:* and workqueue:* tracepoints, and
had a simple perl script to postprocess the trace info to figure out
average/min/max latency.

I don't think the queueing latency is that significant per-se, but I
think the best thing is to avoid making multiple trips through the
workqueue per RPC if we can help it. I tested and pushed a newer
patchset to my repo last night that does that (at least if there's
already a svc_rqst available when the xprt needs servicing). It seems
to be pretty close speed-wise to the thread-based code.

The next step is to test this out on something larger-scale. I'm hoping
to get access to just such a test rig soon. Once we have some results
from that, I think I'll have a much better idea of how viable this
approach is and where other potential bottlenecks might be.

Thanks!
-- 
Jeff Layton <jlayton@primarydata.com>
