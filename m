Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33105 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753103AbcIOOzD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Sep 2016 10:55:03 -0400
Subject: [PATCH v3 00/22] client-side NFS/RDMA patches ready for v4.9
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 15 Sep 2016 10:54:54 -0400
Message-ID: <20160915143440.11080.89241.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna-

The following patch series is ready for you to consider for v4.9. It
makes these changes:

- Correct use of DMA API
- Delay DMA mapping to permit device driver unload
- Introduce simple RDMA-CM private message exchange
- Support for Remote Invalidation and large inline thresholds
- Use s/g list when sending RPC Calls

I've tested using iozone, git's "make test", and xfstests in the
following Linux-on-Linux configurations:

- iommu enabled on both client and server
- FMR and FRWR client memory registration
- NFSv3, NFSv4.0, and NFSv4.1
- sec=sys, krb5, krb5i, and krb5p
- inline threshold sizes of 1KB, 4KB, 8KB, 16KB, 32KB, and 64KB

There is an issue with NFSv4.1 callback on sec=krb5[ip] mounts when
using inline thresholds above 8KB that I'm still tracking down. This
issue can be encountered only by unrepentent knob-tweakers, so I'm
calling this series good-to-go.


Available in the "nfs-rdma-for-4.9" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git


Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfs-rdma-for-4.9


Changes since v2:
- Rebased on v4.8-rc6 + merged fixes
- Addressed Anna's review comments
- Days of test experience


Changes since v1:
- Rebased on v4.8-rc3
- Addressed Trond's comments in 02/22 and 03/22
- Addressed kbuild robot warnings
- Gather Send patch (18/22) rewritten

---

Chuck Lever (22):
      xprtrdma: Eliminate INLINE_THRESHOLD macros
      SUNRPC: Refactor rpc_xdr_buf_init()
      SUNRPC: Generalize the RPC buffer allocation API
      SUNRPC: Generalize the RPC buffer release API
      SUNRPC: Separate buffer pointers for RPC Call and Reply messages
      SUNRPC: Add a transport-specific private field in rpc_rqst
      xprtrdma: Initialize separate RPC call and reply buffers
      xprtrdma: Use smaller buffers for RPC-over-RDMA headers
      xprtrdma: Replace DMA_BIDIRECTIONAL
      xprtrdma: Delay DMA mapping Send and Receive buffers
      xprtrdma: Eliminate "ia" argument in rpcrdma_{alloc,free}_regbuf
      xprtrdma: Simplify rpcrdma_ep_post_recv()
      xprtrdma: Move send_wr to struct rpcrdma_req
      xprtrdma: Move recv_wr to struct rpcrdma_rep
      rpcrdma: RDMA/CM private message data structure
      xprtrdma: Client-side support for rpcrdma_connect_private
      xprtrdma: Basic support for Remote Invalidation
      xprtrdma: Use gathered Send for large inline messages
      xprtrdma: Support larger inline thresholds
      xprtrmda: Report address of frmr, not mw
      xprtrdma: Rename rpcrdma_receive_wc()
      xprtrdma: Eliminate rpcrdma_receive_worker()


 include/linux/sunrpc/rpc_rdma.h            |   39 +++
 include/linux/sunrpc/sched.h               |    4 
 include/linux/sunrpc/xdr.h                 |   12 +
 include/linux/sunrpc/xprt.h                |   12 +
 include/linux/sunrpc/xprtrdma.h            |    4 
 net/sunrpc/backchannel_rqst.c              |    8 -
 net/sunrpc/clnt.c                          |   36 +--
 net/sunrpc/sched.c                         |   35 ++-
 net/sunrpc/xprt.c                          |    2 
 net/sunrpc/xprtrdma/backchannel.c          |   53 +----
 net/sunrpc/xprtrdma/fmr_ops.c              |    7 -
 net/sunrpc/xprtrdma/frwr_ops.c             |   26 ++
 net/sunrpc/xprtrdma/rpc_rdma.c             |  323 +++++++++++++++++-----------
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   19 +-
 net/sunrpc/xprtrdma/transport.c            |  202 ++++++++++--------
 net/sunrpc/xprtrdma/verbs.c                |  237 ++++++++++++---------
 net/sunrpc/xprtrdma/xprt_rdma.h            |  108 ++++++---
 net/sunrpc/xprtsock.c                      |   23 +-
 18 files changed, 676 insertions(+), 474 deletions(-)

--
Chuck Lever
