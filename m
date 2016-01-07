Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:37428 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbcAGTst (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jan 2016 14:48:49 -0500
Subject: [PATCH v5 00/10] NFS/RDMA server patches for v4.5
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org, dledford@redhat.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 07 Jan 2016 14:48:46 -0500
Message-ID: <20160107194251.2662.88158.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Doug-

Here are patches to support server-side bi-directional RPC/RDMA
operation (to enable NFSv4.1 on RPC/RDMA transports). Thanks to
all who reviewed earlier versions.

Doug, please take these for 4.5. These are Acked-by Bruce and ready
to go.

Also available in the "nfsd-rdma-for-4.5" topic branch of this git
repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git

Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfsd-rdma-for-4.5


Changes since v4:
- Rebased on Doug's k.o/for-4.5 branch
- Dropped patch to prevent writing XDR pads
- Squashed in Dan Carpenter's fixes


Changes since v3:
- Rebased on Christoph's ib_device_attr branch
- Backchannel patches have been squashed together
- Memory allocation overhaul to prevent blocking allocation
   when sending backchannel calls


Changes since v2:
- Rebased on v4.4-rc4
- Backchannel code in new source file to address dprintk issues
- svc_rdma_get_context() now uses a pre-allocated cache
- Dropped svc_rdma_send clean up


Changes since v1:

- Rebased on v4.4-rc3
- Removed the use of CONFIG_SUNRPC_BACKCHANNEL
- Fixed computation of forward and backward max_requests
- Updated some comments and patch descriptions
- pr_err and pr_info converted to dprintk
- Simplified svc_rdma_get_context()
- Dropped patch removing access_flags field
- NFSv4.1 callbacks tested with for-4.5 client

---

Chuck Lever (10):
      svcrdma: Clean up rdma_create_xprt()
      svcrdma: Clean up process_context()
      svcrdma: Improve allocation of struct svc_rdma_op_ctxt
      svcrdma: Improve allocation of struct svc_rdma_req_map
      svcrdma: Remove unused req_map and ctxt kmem_caches
      svcrdma: Add gfp flags to svc_rdma_post_recv()
      svcrdma: Remove last two __GFP_NOFAIL call sites
      svcrdma: Make map_xdr non-static
      svcrdma: Define maximum number of backchannel requests
      svcrdma: Add class for RDMA backwards direction transport


 include/linux/sunrpc/svc_rdma.h            |   37 ++-
 net/sunrpc/xprt.c                          |    1 
 net/sunrpc/xprtrdma/Makefile               |    2 
 net/sunrpc/xprtrdma/svc_rdma.c             |   41 ---
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  371 ++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |   52 ++++
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |   27 +-
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |  284 ++++++++++++++++-----
 net/sunrpc/xprtrdma/transport.c            |   30 +-
 net/sunrpc/xprtrdma/xprt_rdma.h            |   20 +-
 10 files changed, 723 insertions(+), 142 deletions(-)
 create mode 100644 net/sunrpc/xprtrdma/svc_rdma_backchannel.c

--
Chuck Lever
