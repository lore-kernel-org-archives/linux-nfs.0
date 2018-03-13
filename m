Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:37795 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932669AbeCMPnn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Mar 2018 11:43:43 -0400
Received: by mail-it0-f49.google.com with SMTP id k79-v6so706251ita.2
        for <linux-nfs@vger.kernel.org>; Tue, 13 Mar 2018 08:43:42 -0700 (PDT)
Subject: [PATCH 00/15] NFSD trace point clean up
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 13 Mar 2018 11:43:38 -0400
Message-ID: <20180313154053.21531.86316.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

Please consider this cluster of patches for v4.17. The patches clean
up a number of issues with NFSD and server-side sunrpc static trace
points.

I have additional svcrdma patches for v4.17, which I'm holding until
you have reviewed this cluster.

---

Chuck Lever (15):
      sunrpc: Remove unneeded pointer dereference
      svc: Simplify ->xpo_secure_port
      sunrpc: Update show_svc_xprt_flags() to include recently added flags
      sunrpc: Move trace_svc_xprt_dequeue()
      sunrpc: Simplify do_enqueue tracing
      sunrpc: Simplify trace_svc_recv
      sunrpc: Save remote presentation address in svc_xprt for trace events
      sunrpc: Re-purpose trace_svc_process
      sunrpc: Report per-RPC execution stats
      nfsd: Fix NFSD trace points
      nfsd: Record request byte count, not count of vectors
      nfsd: Add "nfsd_" to trace point names
      nfsd: Add I/O trace points in the NFSv4 write path
      nfsd: Add I/O trace points in the NFSv4 read proc
      nfsd: Trace NFSv4 COMPOUND execution


 fs/nfsd/nfs4layouts.c                    |   16 +--
 fs/nfsd/nfs4proc.c                       |   25 +++-
 fs/nfsd/nfs4xdr.c                        |   55 +++++++---
 fs/nfsd/trace.h                          |   98 +++++++++++++++--
 fs/nfsd/vfs.c                            |   85 +++++++--------
 fs/nfsd/vfs.h                            |    8 +
 include/linux/sunrpc/svc.h               |    1 
 include/linux/sunrpc/svc_rdma.h          |    1 
 include/linux/sunrpc/svc_xprt.h          |    6 +
 include/trace/events/sunrpc.h            |  173 ++++++++++++++++--------------
 net/sunrpc/svc.c                         |    9 +-
 net/sunrpc/svc_xprt.c                    |   31 ++---
 net/sunrpc/svcsock.c                     |   10 +-
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    1 
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   11 +-
 15 files changed, 322 insertions(+), 208 deletions(-)

--
Chuck Lever
