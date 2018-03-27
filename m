Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:41652 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751138AbeC0OtP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Mar 2018 10:49:15 -0400
Received: by mail-io0-f170.google.com with SMTP id m83so27898435ioi.8
        for <linux-nfs@vger.kernel.org>; Tue, 27 Mar 2018 07:49:14 -0700 (PDT)
Subject: [PATCH v2 00/18] NFS/RDMA server for v4.17
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 27 Mar 2018 10:49:07 -0400
Message-ID: <20180327144420.7710.82288.stgit@oracle-ib-101.nfsv4bat.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

Here's a revision of the first two "for v4.17" patchsets I sent you
a couple of weeks ago. This series includes fixes for NFSD and
server-side RPC trace points, and the write and symlink XDR decoder
clean up patches.


Changes since v1:
- svc_process latency report no longer includes transport latency
- new separate report of transport queuing latency
- fix bug when reading holes over NFSv4
- NFSv4-related hunks removed from the XDR decoder clean up patches

---

Chuck Lever (18):
      sunrpc: Remove unneeded pointer dereference
      svc: Simplify ->xpo_secure_port
      sunrpc: Update show_svc_xprt_flags() to include recently added flags
      sunrpc: Move trace_svc_xprt_dequeue()
      sunrpc: Simplify do_enqueue tracing
      sunrpc: Simplify trace_svc_recv
      sunrpc: Save remote presentation address in svc_xprt for trace events
      sunrpc: Re-purpose trace_svc_process
      sunrpc: Report per-RPC execution stats
      svc: Report xprt dequeue latency
      nfsd: Fix NFSD trace points
      nfsd: Record request byte count, not count of vectors
      nfsd: Add "nfsd_" to trace point names
      nfsd: Add I/O trace points in the NFSv4 write path
      nfsd: Add I/O trace points in the NFSv4 read proc
      nfsd: Trace NFSv4 COMPOUND execution
      NFSD: Clean up legacy NFS WRITE argument XDR decoders
      NFSD: Clean up legacy NFS SYMLINK argument XDR decoders


 fs/nfsd/nfs3proc.c                       |   18 ++-
 fs/nfsd/nfs3xdr.c                        |   67 ++--------
 fs/nfsd/nfs4layouts.c                    |   16 +-
 fs/nfsd/nfs4proc.c                       |   25 ++--
 fs/nfsd/nfs4xdr.c                        |   56 ++++++--
 fs/nfsd/nfsproc.c                        |   23 ++-
 fs/nfsd/nfsxdr.c                         |   63 +++++----
 fs/nfsd/trace.h                          |   98 +++++++++++++-
 fs/nfsd/vfs.c                            |   85 ++++++-------
 fs/nfsd/vfs.h                            |    8 +
 fs/nfsd/xdr.h                            |    3 
 fs/nfsd/xdr3.h                           |    3 
 fs/nfsd/xdr4.h                           |    2 
 include/linux/sunrpc/svc.h               |    6 +
 include/linux/sunrpc/svc_xprt.h          |    6 +
 include/trace/events/sunrpc.h            |  204 ++++++++++++++++++------------
 net/sunrpc/svc.c                         |  118 ++++++++++++++++-
 net/sunrpc/svc_xprt.c                    |   34 ++---
 net/sunrpc/svcsock.c                     |    8 +
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   10 +
 20 files changed, 545 insertions(+), 308 deletions(-)

--
Chuck Lever
