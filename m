Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f44.google.com ([209.85.216.44]:49485 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754441AbaLBSY3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Dec 2014 13:24:29 -0500
Received: by mail-qa0-f44.google.com with SMTP id i13so9270775qae.31
        for <linux-nfs@vger.kernel.org>; Tue, 02 Dec 2014 10:24:28 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: [RFC PATCH 00/14] nfsd/sunrpc: add support for a workqueue-based nfsd
Date: Tue,  2 Dec 2014 13:24:09 -0500
Message-Id: <1417544663-13299-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

tl;dr: this code works and is much simpler than the dedicated thread
       pool, but there are some latencies in the workqueue code that
       seem to keep it from being as fast as it could be.

This patchset is a little skunkworks project that I've been poking at
for the last few weeks. Currently nfsd uses a dedicated thread pool to
handle RPCs, but that requires maintaining a rather large swath of
"fiddly" code to handle the threads and transports.

This patchset represents an alternative approach, which makes nfsd use
workqueues to do its bidding rather than a dedicated thread pool. When a
transport needs to do work, we simply queue it to the workqueue in
softirq context and let it service the transport.

The current draft is runtime-switchable via a new sunrpc pool_mode
module parameter setting. When that's set to "workqueue", nfsd will use
a workqueue-based service. One of the goals of this patchset was to
*not* need to change any userland code, so starting it up using rpc.nfsd
still works as expected. The only real difference is that the nfsdfs
"threads" file is reinterpreted as the "max_active" value for the
workqueue.

This code has a lot of potential to simplify nfsd significantly and I
think it may also scale better on larger machines. When testing with an
exported tmpfs on my craptacular test machine, the workqueue based code
seems to be a little faster than a dedicated thread pool.

Currently though, performance takes a nose dive (~%40) when I'm writing
to (relatively slow) SATA disks. With the help of some tracepoints, I
think this is mostly due to some significant latency in the workqueue
code.

When I queue a thread using the legacy dedicated thread pool, I see
~.2ms of latency between the softirq function queueing it to a given
thread and the thread picking that work up. When I queue it to a
workqueue however, that latency jumps to ~30ms (average).

My current theory is that this latency interferes with the ability to
batch up requests to the disks and that is what accounts for the massive
slowdown.

So, I have several goals here in posting this:

1) to get some early feedback on this code. Does this seem reasonable,
assuming that we can address the workqueue latency problems?

2) get some insight about the latency from those with a better
understanding of the CMWQ code. Any thoughts as to why we might be
seeing such high latency here? Any ideas of what we can do about it?

3) I'm also cc'ing Al due to some changes in patch #10 to allow nfsd
to manage its fs_structs a little differently. Does that approach seem
reasonable?

Jeff Layton (14):
  sunrpc: add a new svc_serv_ops struct and move sv_shutdown into it
  sunrpc: move sv_function into sv_ops
  sunrpc: move sv_module parm into sv_ops
  sunrpc: turn enqueueing a svc_xprt into a svc_serv operation
  sunrpc: abstract out svc_set_num_threads to sv_ops
  sunrpc: move pool_mode definitions into svc.h
  sunrpc: factor svc_rqst allocation and freeing from sv_nrthreads
    refcounting
  sunrpc: set up workqueue function in svc_xprt
  sunrpc: add basic support for workqueue-based services
  nfsd: keep a reference to the fs_struct in svc_rqst
  nfsd: add support for workqueue based service processing
  sunrpc: keep a cache of svc_rqsts for each NUMA node
  sunrpc: add more tracepoints around svc_xprt handling
  sunrpc: add tracepoints around svc_sock handling

 fs/fs_struct.c                  |  60 +++++++--
 fs/lockd/svc.c                  |   7 +-
 fs/nfs/callback.c               |   6 +-
 fs/nfsd/nfssvc.c                | 107 ++++++++++++---
 include/linux/fs_struct.h       |   4 +
 include/linux/sunrpc/svc.h      |  97 +++++++++++---
 include/linux/sunrpc/svc_xprt.h |   3 +
 include/linux/sunrpc/svcsock.h  |   1 +
 include/trace/events/sunrpc.h   |  60 ++++++++-
 net/sunrpc/Kconfig              |  10 ++
 net/sunrpc/Makefile             |   1 +
 net/sunrpc/svc.c                | 141 +++++++++++---------
 net/sunrpc/svc_wq.c             | 281 ++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/svc_xprt.c           |  66 +++++++++-
 net/sunrpc/svcsock.c            |   6 +
 15 files changed, 737 insertions(+), 113 deletions(-)
 create mode 100644 net/sunrpc/svc_wq.c

-- 
2.1.0

