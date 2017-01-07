Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:35296 "EHLO
        mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755798AbdAGRPS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jan 2017 12:15:18 -0500
Subject: [PATCH v1 00/22] convert NFS server to new rdma_rw API
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 07 Jan 2017 12:15:15 -0500
Message-ID: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series converts the Linux NFS server RPC-over-RDMA
implementation to use the new core rdma_rw API and to poll its CQs
in workqueue mode.

Previously published work prototyped only the path that sends RPC
replies. This series converts both send and receive sides, and
includes significant clean ups that result from using the new API.

This series has been successfully tested with NFSv3, 4.0, and 4.1;
with clients that use FRWR and FMR; and with sec=sys, krb5, krb5i,
and krb5p.

Available in the "nfsd-rdma-rw-api" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git

And for online review:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=shortlog;h=refs/heads/nfsd-rdma-rw-api

---

Chuck Lever (22):
      svcrdma: Another sendto chunk list parsing update
      svcrdma: Replace RPCRDMA_SQ_DEPTH_MULT
      svcrdma: Remove unused sc_dto_q field
      svcrdma: Combine list fields in struct svc_rdma_op_ctxt
      svcrdma: Poll CQs in "workqueue" mode
      svcrdma: Clean up RPC-over-RDMA Reply header encoder
      svcrdma: Clean up RPC-over-RDMA Call header decoder
      svcrdma: Introduce local rdma_rw API helpers
      svcrdma: Use rdma_rw API in RPC reply path
      svcrdma: Backchannel sendto clean up
      svcrdma: Clean up RDMA_ERROR path
      svcrdma: Reduce size of sge array in struct svc_rdma_op_ctxt
      svcrdma: Remove old RDMA Write completion handlers
      svcrdma: Remove the req_map cache
      svcrdma: Clean up RPC-over-RDMA backchannel reply processing
      svcrdma: Use generic RDMA R/W API in RPC Call path
      svcrdma: Remove unused Read completion handlers
      svcrdma: Remove frmr cache
      svcrdma: Clean up after converting svc_rdma_recvfrom to rdma_rw API
      svcrdma: Clean-up in svc_rdma_post_recv
      svcrdma: Clean-up svc_rdma_unmap_dma
      svcrdma: Re-order fields in svc_rdma_op_ctxt


 include/linux/sunrpc/rpc_rdma.h            |   12 
 include/linux/sunrpc/svc_rdma.h            |  147 ++---
 net/sunrpc/xprtrdma/Makefile               |    2 
 net/sunrpc/xprtrdma/svc_rdma.c             |    8 
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   73 +--
 net/sunrpc/xprtrdma/svc_rdma_marshal.c     |  478 +++++++++--------
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |  518 +++---------------
 net/sunrpc/xprtrdma/svc_rdma_rw.c          |  731 ++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |  802 +++++++++++-----------------
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |  506 +++++-------------
 10 files changed, 1621 insertions(+), 1656 deletions(-)
 create mode 100644 net/sunrpc/xprtrdma/svc_rdma_rw.c

--
Chuck Lever
