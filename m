Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:49557 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340AbaJPTiP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Oct 2014 15:38:15 -0400
Received: by mail-ig0-f177.google.com with SMTP id a13so249293igq.16
        for <linux-nfs@vger.kernel.org>; Thu, 16 Oct 2014 12:38:14 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id oq6sm14827051igb.2.2014.10.16.12.38.13
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Oct 2014 12:38:13 -0700 (PDT)
Subject: [PATCH v1 00/16] NFS/RDMA patches for 3.19
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Thu, 16 Oct 2014 15:38:12 -0400
Message-ID: <20141016192919.13414.3151.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

Two groups of patches in this series. The first group is fixes
and clean-ups for xprtrdma. The second group adds client support
for NFSv4.1 on RDMA. Looking for review and testing.

Also available in the "nfs-rdma-for-3.19" topic branch at

  git://linux-nfs.org/projects/cel/cel-2.6.git

---

Chuck Lever (16):
      xprtrdma: Return an errno from rpcrdma_register_external()
      xprtrdma: Cap req_cqinit
      SUNRPC: Pass callsize and recvsize to buf_alloc as separate arguments
      xprtrdma: Re-write rpcrdma_flush_cqs()
      xprtrdma: unmap all FMRs during transport disconnect
      xprtrdma: spin CQ completion vectors
      SUNRPC: serialize iostats updates
      xprtrdma: Display async errors
      xprtrdma: Enable pad optimization
      NFS: Include transport protocol name in UCS client string
      NFS: Clean up nfs4_init_callback()
      SUNRPC: Add rpc_xprt_is_bidirectional()
      NFS: Add sidecar RPC client support
      NFS: Set BIND_CONN_TO_SESSION arguments in the proc layer
      NFS: Bind side-car connection to session
      NFS: Disable SESSION4_BACK_CHAN when a backchannel sidecar is to be used


 fs/nfs/client.c                 |    1 
 fs/nfs/nfs4client.c             |   86 +++++++++++++++++----
 fs/nfs/nfs4proc.c               |   71 ++++++++++++++---
 fs/nfs/nfs4xdr.c                |   16 ++--
 include/linux/nfs_fs_sb.h       |    2 
 include/linux/nfs_xdr.h         |    6 +
 include/linux/sunrpc/clnt.h     |    1 
 include/linux/sunrpc/metrics.h  |    3 +
 include/linux/sunrpc/sched.h    |    2 
 include/linux/sunrpc/xprt.h     |    4 +
 net/sunrpc/clnt.c               |   28 ++++++-
 net/sunrpc/sched.c              |    6 +
 net/sunrpc/stats.c              |   21 ++++-
 net/sunrpc/xprtrdma/transport.c |    6 +
 net/sunrpc/xprtrdma/verbs.c     |  159 +++++++++++++++++++++++++++++++++++----
 net/sunrpc/xprtsock.c           |    6 +
 16 files changed, 347 insertions(+), 71 deletions(-)

--
Chuck Lever
