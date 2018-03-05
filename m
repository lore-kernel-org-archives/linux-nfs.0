Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34108 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751462AbeCEUMx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2018 15:12:53 -0500
Subject: [PATCH 0/9] Second round of v4.17 NFS/RDMA client patches
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 05 Mar 2018 15:12:51 -0500
Message-ID: <20180305200825.10904.40829.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna-

Second round of three. This set could be more controversial. In it,
I adjust some code paths so that I can create rpcrdma-specific
alloc_slot and free_slot methods. These are clean-ups that make
it straightforward to do the changes coming in the third round,
and hopefully add a little bit of a scalability boost as well.


---

Chuck Lever (9):
      SUNRPC: Move xprt_update_rtt callsite
      SUNRPC: Make RTT measurement more precise (Receive)
      SUNRPC: Make RTT measurement more precise (Send)
      SUNRPC: Make num_reqs a non-atomic integer
      SUNRPC: Initialize rpc_rqst outside of xprt->reserve_lock
      SUNRPC: Add a ->free_slot transport callout
      xprtrdma: Introduce ->alloc_slot call-out for xprtrdma
      xprtrdma: Make rpc_rqst part of rpcrdma_req
      xprtrdma: Allocate rpcrdma_reps during Receive completion


 include/linux/sunrpc/xprt.h                |    9 ++-
 net/sunrpc/clnt.c                          |    1 
 net/sunrpc/xprt.c                          |   51 +++++++++------
 net/sunrpc/xprtrdma/backchannel.c          |   94 ++++++++++------------------
 net/sunrpc/xprtrdma/rpc_rdma.c             |    8 ++
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    1 
 net/sunrpc/xprtrdma/transport.c            |   61 ++++++++++++++----
 net/sunrpc/xprtrdma/verbs.c                |   35 ++++++++--
 net/sunrpc/xprtrdma/xprt_rdma.h            |   13 +---
 net/sunrpc/xprtsock.c                      |    8 ++
 10 files changed, 166 insertions(+), 115 deletions(-)

--
Chuck Lever
