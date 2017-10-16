Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:56779 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753146AbdJPTBA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Oct 2017 15:01:00 -0400
Subject: [PATCH 1 0/5] NFS/RDMA client patches for v4.15, pt. 2
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 16 Oct 2017 15:00:57 -0400
Message-ID: <20171016185641.13594.5374.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This second set of NFS/RDMA client patches addresses shortcomings in
the rpcrdma.ko RPC Reply handler path. The major piece of work here
is moving the Receive completion handler out of soft IRQ and into a
friendlier workqueue context.

Please consider these patches for v4.15.


---

Chuck Lever (5):
      xprtrdma: Throw away reply when version is unrecognized
      xprtrdma: Move decoded header fields into rpcrdma_rep
      xprtrdma: Refactor rpcrdma_reply_handler some more
      xprtrdma: Invoke rpcrdma_reply_handler directly from RECV completion
      xprtrdma: Decode credits field in rpcrdma_reply_handler


 net/sunrpc/xprtrdma/rpc_rdma.c  |  200 ++++++++++++++++++++++-----------------
 net/sunrpc/xprtrdma/verbs.c     |   33 +-----
 net/sunrpc/xprtrdma/xprt_rdma.h |   31 ++++--
 3 files changed, 138 insertions(+), 126 deletions(-)

--
Chuck Lever
