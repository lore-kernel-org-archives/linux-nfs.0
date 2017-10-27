Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:43159 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751736AbdJ0Qnr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Oct 2017 12:43:47 -0400
Subject: [PATCH 0/4] Last NFS/RDMA client patches for v4.15
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 27 Oct 2017 12:43:45 -0400
Message-ID: <20171027164014.10826.10151.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna-

Here's my final set of NFS/RDMA client patches for v4.15.

Three of these are clean up patches. The first patch is an important
change, however.

In the earlier set of patches, I changed the Receive CQ to run in
workqueue context. Here, I change the Send CQ to also run in
workqueue context.

In addition, I move it to a different compvec than the Receive CQ.
My performance measurements show that the two completion handlers
interfere with each other if they run in the same workqueue thread.

Please consider this set for v4.15.

---

Chuck Lever (4):
      xprtrdma: Put Send CQ in IB_POLL_WORKQUEUE mode
      rpcrdma: Remove C structure definitions of XDR data items
      xprtrdma: Remove include for linux/prefetch.h
      xprtrdma: Update copyright notices


 include/linux/sunrpc/rpc_rdma.h |   60 +--------------------------------------
 net/sunrpc/xprtrdma/rpc_rdma.c  |    7 +++--
 net/sunrpc/xprtrdma/transport.c |    1 +
 net/sunrpc/xprtrdma/verbs.c     |    4 +--
 net/sunrpc/xprtrdma/xprt_rdma.h |    7 +----
 5 files changed, 9 insertions(+), 70 deletions(-)

--
Chuck Lever
