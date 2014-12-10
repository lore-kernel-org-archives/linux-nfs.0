Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f41.google.com ([209.85.192.41]:32806 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756847AbaLJXN4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Dec 2014 18:13:56 -0500
Received: by mail-qg0-f41.google.com with SMTP id j5so2984779qga.14
        for <linux-nfs@vger.kernel.org>; Wed, 10 Dec 2014 15:13:55 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Wed, 10 Dec 2014 18:13:53 -0500
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Tejun Heo <tj@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>,
        Neil Brown <neilb@suse.de>
Subject: Re: [PATCH v2 00/16] nfsd/sunrpc: add support for a workqueue-based
 nfsd
Message-ID: <20141210181353.5a017d26@tlielax.poochiereds.net>
In-Reply-To: <AF4C9367-72BD-46F2-BAB2-5C583B01C3F6@oracle.com>
References: <1418238480-18857-1-git-send-email-jlayton@primarydata.com>
	<AF4C9367-72BD-46F2-BAB2-5C583B01C3F6@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 10 Dec 2014 14:31:55 -0800
Chuck Lever <chuck.lever@oracle.com> wrote:

> Hi Jeff-
> 
> On Dec 10, 2014, at 11:07 AM, Jeff Layton <jlayton@primarydata.com> wrote:
> 
> > This is the second revision of the workqueue-based nfsd. Changes from
> > the RFC version I posted earlier:
> > 
> > v2:
> > - found and fixed problem causing the delays between work. It was a bug
> >  in the design of the new code. I was queueing the svc_xprt's work to
> >  do everything and that necessarily serialized that work. This version
> >  adds a work_struct to the svc_rqst as well, and that's where the
> >  bulk of the work.
> > 
> > - no longer tries to use the thread count as a max_active setting for
> >  the workqueue. The workqueue max_active settings are left to the
> >  default. This means that /proc/fs/nfsd/threads is basically a binary
> >  switch that's either zero (not running) or non-zero (running). The
> >  actual value has no meaning.
> > 
> > - the handling of the fs_struct has been reworked. It's now allocated
> >  as part of the struct svc_rqst. Each svc_rqst has its own fs_struct
> >  now.
> > 
> > - CONFIG_SUNRPC_SVC_WORKQUEUE has been removed. Since the code must
> >  be enabled at runtime anyway, we don't need a switch to disable this
> >  code at build time.
> > 
> > - the new tracepoints have been reworked.
> > 
> > This new code is still a little slower (2-3%) than the older, thread
> > based code in my testing, though my hope is that it may perform better
> > than the older code on a NUMA machine. I don't have one at the moment
> > to verify that, however.
> > 
> > For background, here's an excerpt from the original posting:
> > 
> > This patchset is a little skunkworks project that I've been poking at
> > for the last few weeks. Currently nfsd uses a dedicated thread pool to
> > handle RPCs, but that requires maintaining a rather large swath of
> > "fiddly" code to handle the threads and transports.
> > 
> > This patchset represents an alternative approach, which makes nfsd use
> > workqueues to do its bidding rather than a dedicated thread pool. When a
> > transport needs to do work, we simply queue it to the workqueue in
> > softirq context and let it service the transport.
> > 
> > Performance:
> > ------------
> > As far as numbers go, I ran a modified version of the fio
> > tiobench-example.fio test that just reduces the file size to 128M:
> > 
> > threads:
> > ----------------------------------------------------------------------
> > Run status group 0 (all jobs):
> >  WRITE: io=13740KB, aggrb=228KB/s, minb=57KB/s, maxb=57KB/s,
> > mint=60034msec, maxt=60049msec
> > 
> > Run status group 1 (all jobs):
> >  WRITE: io=14652KB, aggrb=244KB/s, minb=60KB/s, maxb=61KB/s,
> > mint=60002msec, maxt=60028msec
> > 
> > Run status group 2 (all jobs):
> >   READ: io=524288KB, aggrb=49639KB/s, minb=12409KB/s, maxb=12433KB/s,
> > mint=10542msec, maxt=10562msec
> > 
> > Run status group 3 (all jobs):
> >   READ: io=524288KB, aggrb=50670KB/s, minb=12667KB/s, maxb=12687KB/s,
> > mint=10331msec, maxt=10347msec
> > 
> > workqueue:
> > ----------------------------------------------------------------------
> > Run status group 0 (all jobs):
> >  WRITE: io=13632KB, aggrb=226KB/s, minb=56KB/s, maxb=56KB/s,
> > mint=60010msec, maxt=60061msec
> > 
> > Run status group 1 (all jobs):
> >  WRITE: io=14328KB, aggrb=238KB/s, minb=59KB/s, maxb=59KB/s,
> > mint=60023msec, maxt=60033msec
> > 
> > Run status group 2 (all jobs):
> >   READ: io=524288KB, aggrb=47779KB/s, minb=11944KB/s, maxb=11955KB/s,
> > mint=10963msec, maxt=10973msec
> > 
> > Run status group 3 (all jobs):
> >   READ: io=524288KB, aggrb=48379KB/s, minb=12094KB/s, maxb=12114KB/s,
> > mint=10819msec, maxt=10837msec
> > 
> > ...a small performance decrease using workqueues (about 5% in the worst
> > case). It varies a little between runs but the results over several runs
> > are fairly consistent in showing a small perf decrease.
> > 
> > In an attempt to ascertain where that comes from, I added some
> > tracepoints and wrote a perl script to scrape the results and figure out
> > where the latency comes from. The numbers here are from the ones that
> > produced the above results:
> > 
> > [jlayton@palma nfsd-wq]$ ./analyze.pl < threads.txt 
> > -------------------------------------------------------------
> > rpcs=272437
> > queue=3.79952429455322
> > queued=10.0558330900775
> > receive=10.6196625266701
> > process=2325.8173229043
> > total=2350.2923428156
> > 
> > [jlayton@palma nfsd-wq]$ ./analyze.pl < workqueue.txt 
> > -------------------------------------------------------------
> > rpcs=272329
> > queue=4.41979737859012
> > queued=8.124893049967
> > receive=11.3421082590608
> > process=2310.15945786277
> > total=2334.04625655039
> > 
> > Here's a legend, the numbers represent a delta between two
> > tracepoints for a particular xprt or rqst. I can provide the script if
> > it's helpful but it's definitely hacked together:
> > 
> > rpcs: total number of rpcs processed (just a count)
> > queue: time it took to queue the xprt.xi
> >       trace_svc_xprt_enqueued - trace_svc_xprt_enqueue (in usecs)
> > 
> > queued: time between being queued and going "active"
> >        trace_svc_xprt_active - trace_svc_xprt_enqueued (in usecs)
> > 
> > receive: time between going "active" and completing the receive
> >         trace_svc_xprt_received - trace_svc_xprt_active (in usecs)
> > 
> > process: time between completing the receive and finishing processing
> >         trace_svc_process - trace_svc_xprt_recevied (in usecs)
> > 
> > total: total time from enqueueing to finishing the processing
> >       trace_svc_process - trace_svc_xprt_enqueued (in usecs)
> > 
> > The interesting bit is that according to these numbers, the workqueue
> > RPCs ran more quickly on average (though most of that is in svc_process,
> > for which I have zero explanation). So, why are we getting slower
> > results?
> > 
> > One theory is that it's getting bitten by the fact that the workqueue
> > queueing/dequeueing code uses spinlocks that disable bottom halves.
> > Perhaps that adds up and causes more latency to softirq processing? I'm
> > not sure how best to nail that down...
> > 
> > It's probably worth it to start considering this for v3.20, but I'd like
> > to get some time on a larger scale test rig to see how it does first.
> 
> I think there needs to be a guarantee that this does not break
> badly with NFS/RDMA, with xfs / btrfs / ext4, or with 40 and
> 56GbE. (Yes, we are volunteering to help with some of that).
> 

That would be helpful. I wouldn't expect any breakage with any of that
given where I added the operations, but you never know.

> How does it scale in number of individual transport sockets?
> 

I'd expect that it'll do well given that we use RCU when searching for
a svc_rqst, but I don't have a test rig that has a ton of clients so I
can't guarantee that.

> Does the new scheduling model use more or less CPU per byte
> and per RPC?
> 

Good question. My expectation would be that it wouldn't make much
difference, but again I don't know for sure.

I'd also like very much to account for the drop in throughput I'm seeing
with this code, but I'm unclear on the best method to chase that down
as of yet.

> Also, running these performance tests with a CPU soaker running
> on the NFS server might be interesting. Something like a large
> software build. That could better expose issues with workqueue
> scheduling.
> 
> That feels like more work than any of us can do before 3.20.
> 

Quite likely.

v3.20 isn't a firm goal. Heck I may drop this altogether if it turns
out to be slower and we can't figure out any way to make it better.

A primary goal here is to avoid breaking the existing code (of course).
One thing I'm really trying to do is avoid substantially altering the
code in the case where you don't opt to use workqueues.

I'm adding some function pointers that will need to be chased, of course
but I don't think that'll add much overhead in the context of all of
the other stuff you have to do to handle an RPC.

> 
> > We'll also need Al's ACK on the fs_struct stuff.
> > 
> > Thoughts or comments are welcome.
> > 
> > Jeff Layton (16):
> >  sunrpc: add a new svc_serv_ops struct and move sv_shutdown into it
> >  sunrpc: move sv_function into sv_ops
> >  sunrpc: move sv_module parm into sv_ops
> >  sunrpc: turn enqueueing a svc_xprt into a svc_serv operation
> >  sunrpc: abstract out svc_set_num_threads to sv_ops
> >  sunrpc: move pool_mode definitions into svc.h
> >  sunrpc: factor svc_rqst allocation and freeing from sv_nrthreads
> >    refcounting
> >  sunrpc: set up workqueue function in svc_xprt
> >  sunrpc: set up svc_rqst work if it's defined
> >  sunrpc: add basic support for workqueue-based services
> >  nfsd: keep a reference to the fs_struct in svc_rqst
> >  nfsd: add support for workqueue based service processing
> >  sunrpc: keep a cache of svc_rqsts for each NUMA node
> >  sunrpc: add more tracepoints around svc_xprt handling
> >  sunrpc: print the svc_rqst pointer value in svc_process tracepoint
> >  sunrpc: add tracepoints around svc_sock handling
> > 
> > fs/fs_struct.c                  |  60 ++++++--
> > fs/lockd/svc.c                  |   7 +-
> > fs/nfs/callback.c               |   6 +-
> > fs/nfsd/nfssvc.c                | 100 +++++++++++--
> > include/linux/fs_struct.h       |   4 +
> > include/linux/sunrpc/svc.h      |  93 ++++++++++---
> > include/linux/sunrpc/svc_xprt.h |   3 +
> > include/linux/sunrpc/svcsock.h  |   1 +
> > include/trace/events/sunrpc.h   |  88 ++++++++++--
> > net/sunrpc/Makefile             |   2 +-
> > net/sunrpc/svc.c                | 141 +++++++++++--------
> > net/sunrpc/svc_wq.c             | 302
> > ++++++++++++++++++++++++++++++++++++++++
> > net/sunrpc/svc_xprt.c           |  68 ++++++++-
> > net/sunrpc/svcsock.c            |   6 + 14 files changed, 758
> > insertions(+), 123 deletions(-) create mode 100644
> > net/sunrpc/svc_wq.c
> > 
> > -- 
> > 2.1.0
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe
> > linux-nfs" in the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 


-- 
Jeff Layton <jlayton@primarydata.com>
