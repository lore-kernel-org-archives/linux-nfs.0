Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:4780 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752288AbbKBV5T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Nov 2015 16:57:19 -0500
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Wise <swise@opengridcomputing.com>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: [GIT PULL v2] Please Pull NFSoRDMA changes for 4.4
Message-ID: <5637DC30.5000003@Netapp.com>
Date: Mon, 2 Nov 2015 16:57:04 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

The following changes since commit 7379047d5585187d1288486d4627873170d0005a:

  Linux 4.3-rc6 (2015-10-18 16:08:42 -0700)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/nfs-rdma.git tags/nfs-rdma-4.4-2

for you to fetch changes up to 76566773a1f1c2295ed901b6f1241cfe10d99029:

  NFS: Enable client side NFSv4.1 backchannel to use other transports (2015-11-02 16:29:13 -0500)

Thanks,
Anna

----------------------------------------------------------------
Chuck Lever (16):
      xprtrdma: Enable swap-on-NFS/RDMA
      xprtrdma: Re-arm after missed events
      xprtrdma: Prevent loss of completion signals
      xprtrdma: Refactor reply handler error handling
      xprtrdma: Replace send and receive arrays
      xprtrdma: Use workqueue to process RPC/RDMA replies
      xprtrdma: Remove reply tasklet
      xprtrdma: Saving IRQs no longer needed for rb_lock
      SUNRPC: Abstract backchannel operations
      xprtrdma: Pre-allocate backward rpc_rqst and send/receive buffers
      xprtrdma: Pre-allocate Work Requests for backchannel
      xprtrdma: Add support for sending backward direction RPC replies
      xprtrdma: Handle incoming backward direction RPC calls
      svcrdma: Add backward direction service for RPC/RDMA transport
      SUNRPC: Remove the TCP-only restriction in bc_svc_process()
      NFS: Enable client side NFSv4.1 backchannel to use other transports

Steve Wise (1):
      xprtrdma: don't log warnings for flushed completions

 fs/nfs/callback.c                        |  40 ++++--------------
 include/linux/sunrpc/bc_xprt.h           |   5 +++
 include/linux/sunrpc/svc_rdma.h          |   6 ++-
 include/linux/sunrpc/xprt.h              |   9 ++++
 net/sunrpc/backchannel_rqst.c            |  24 ++++++++++-
 net/sunrpc/svc.c                         |   5 ---
 net/sunrpc/xprtrdma/Makefile             |   1 +
 net/sunrpc/xprtrdma/backchannel.c        | 394 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/frwr_ops.c           |   7 +++-
 net/sunrpc/xprtrdma/rpc_rdma.c           | 148 +++++++++++++++++++++++++++++++++++++++++++++--------------------
 net/sunrpc/xprtrdma/svc_rdma.c           |   6 +++
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  58 ++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/transport.c          |  18 +++++++-
 net/sunrpc/xprtrdma/verbs.c              | 479 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---------------------------------------------------------------------------------------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h          |  54 +++++++++++++++++++-----
 net/sunrpc/xprtsock.c                    |  17 ++++++++
 16 files changed, 933 insertions(+), 338 deletions(-)
 create mode 100644 net/sunrpc/xprtrdma/backchannel.c
