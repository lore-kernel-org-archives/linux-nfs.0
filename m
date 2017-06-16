Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:36717 "EHLO
        mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752382AbdFPPUY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Jun 2017 11:20:24 -0400
Subject: [PATCH v2 00/19] Server-side NFS/RDMA changes proposed for v4.13
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 16 Jun 2017 11:20:21 -0400
Message-ID: <20170616151535.14210.34926.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series overhauls the "call receive" side of the RPC-over-RDMA
transport to use the new rdma_rw API. A slight performance increase
(better throughput and latency) has been seen. Benefits include:

o Fewer ib_post_send calls per RPC Call

o Code duplicated by other ULPs is replaced with core functions

o Position-Zero Read chunks are handled in one function

o More thorough transport header sanity checking


Available in the "nfsd-rdma-for-4.13" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git


Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfsd-rdma-for-4.13


Remaining rdma_rw API changes are here:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfsd-rdma-rw-api


Changes since v1:
* Fixed bugzilla.linux-nfs 307
* Cleaned up struct svc_rdma_chunk_ctxt


---

Chuck Lever (19):
      ib_core: Enable and expose force_mr module parameter
      svcrdma: Squelch disconnection messages
      svcrdma: Avoid Send Queue overflow
      svcrdma: Remove svc_rdma_marshal.c
      svcrdma: Improve Read chunk sanity checking
      svcrdma: Improve Write chunk sanity checking
      svcrdma: Improve Reply chunk sanity checking
      svcrdma: Don't account for Receive queue "starvation"
      sunrpc: Allocate one more page per svc_rqst
      svcrdma: Add recvfrom helpers to svc_rdma_rw.c
      svcrdma: Use generic RDMA R/W API in RPC Call path
      svcrdma: Properly compute .len and .buflen for received RPC Calls
      svcrdma: Remove unused Read completion handlers
      svcrdma: Remove frmr cache
      svcrdma: Clean-up svc_rdma_unmap_dma
      svcrdma: Clean up after converting svc_rdma_recvfrom to rdma_rw API
      svcrdma: use offset_in_page() macro
      svcrdma: Remove svc_rdma_chunk_ctxt::cc_dir field
      sunrpc: Disable splice for krb5i


 drivers/infiniband/core/rw.c             |    2 
 include/linux/sunrpc/svc.h               |    3 
 include/linux/sunrpc/svc_rdma.h          |   46 --
 net/sunrpc/auth_gss/svcauth_gss.c        |    2 
 net/sunrpc/svc_xprt.c                    |    8 
 net/sunrpc/xprtrdma/Makefile             |    4 
 net/sunrpc/xprtrdma/svc_rdma_marshal.c   |  168 -------
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |  734 ++++++++++++------------------
 net/sunrpc/xprtrdma/svc_rdma_rw.c        |  448 ++++++++++++++++++
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   15 -
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  250 +---------
 11 files changed, 769 insertions(+), 911 deletions(-)
 delete mode 100644 net/sunrpc/xprtrdma/svc_rdma_marshal.c

--
Chuck Lever
