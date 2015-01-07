Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:39013 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808AbbAGXLs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jan 2015 18:11:48 -0500
Received: by mail-ie0-f177.google.com with SMTP id rd18so6603148iec.8
        for <linux-nfs@vger.kernel.org>; Wed, 07 Jan 2015 15:11:47 -0800 (PST)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id aw9sm1677416igc.18.2015.01.07.15.11.46
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Jan 2015 15:11:47 -0800 (PST)
Subject: [PATCH v1 00/20] NFS/RDMA client for 3.20
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Wed, 07 Jan 2015 18:11:46 -0500
Message-ID: <20150107230859.13466.67723.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following series of patches for the Linux NFS client breaks up
the per-transport buffer pool data structures to help them scale
better with the size of SEND/RECV buffers (the inline threshold),
the maximum NFS r/wsize, and the number of RDMA credits (concurrent
RPC requests).

The primary change is that the header send buffers have been split
from struct rpcrdma_req. This has a number of benefits which are
outlined in the patch descriptions.

More pre-requisites are required. Actual changes to the maximum
r/wsize and other limits is left for a future merge window.

---

Chuck Lever (20):
      xprtrdma: human-readable completion status
      xprtrdma: Modernize htonl and ntohl
      xprtrdma: Display XIDs in host byte order
      xprtrdma: Clean up hdrlen
      xprtrdma: Rename "xprt" and "rdma_connect" fields in struct rpcrdma_xprt
      xprtrdma: Remove rpcrdma_ep::rep_ia
      xprtrdma: Remove rl_mr field, and the mr_chunk union
      xprtrdma: Move credit update to RPC reply handler
      xprtrdma: Remove rpcrdma_ep::rep_func and ::rep_xprt
      xprtrdma: Free the pd if ib_query_qp() fails
      xprtrdma: Take struct ib_device_attr off the stack
      xprtrdma: Take struct ib_qp_attr and ib_qp_init_attr off the stack
      xprtrdma: Simplify synopsis of rpcrdma_buffer_create()
      xprtrdma: Refactor rpcrdma_buffer_create() and rpcrdma_buffer_destroy()
      xprtrdma: Add struct rpcrdma_regbuf and helpers
      xprtrdma: Allocate RPC send buffer separately from struct rpcrdma_req
      xprtrdma: Allocate RDMA/RPC send buffer separately from struct rpcrdma_req
      xprtrdma: Allocate RPC/RDMA receive buffer separately from struct rpcrdma_rep
      xprtrdma: Allocate zero pad separately from rpcrdma_buffer
      xprtrdma: Clean up after adding regbuf management


 include/linux/sunrpc/rpc_rdma.h |   14 +
 include/linux/sunrpc/svc_rdma.h |    2 
 net/sunrpc/xprtrdma/rpc_rdma.c  |  108 ++++++----
 net/sunrpc/xprtrdma/transport.c |  179 +++++++----------
 net/sunrpc/xprtrdma/verbs.c     |  411 ++++++++++++++++++++++++---------------
 net/sunrpc/xprtrdma/xprt_rdma.h |  111 +++++++----
 6 files changed, 478 insertions(+), 347 deletions(-)

--
Chuck Lever
