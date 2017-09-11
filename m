Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35018 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751498AbdIKPPV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Sep 2017 11:15:21 -0400
Subject: [PATCH v1 0/7] xprtrdma Send completion batching
From: Chuck Lever <chuck.lever@oracle.com>
To: jgunthorpe@obsidianresearch.com, sagi@grimberg.me
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 11 Sep 2017 11:17:15 -0400
Message-ID: <150514269466.1307.1991885208569456320.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jason, Sagi-

Here's an updated version of last week's patches to implement
strong Send Queue accounting and Send completion batching in
the Linux RPC-over-RDMA client implementation. I've addressed
Jason's concern about patch description language and Sagi's
concern about leaking data in Send buffers that are re-used
after RPC completion, in addition to a number of smaller
clean ups.

Also available as the first several commits in this topic branch:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=shortlog;h=refs/heads/nfs-rdma-for-4.15


Changes since RFC:
* Replace "completion heartbeat" language in patch descriptions and
  code comments
* Ensure RPC completion waits for pages to be unmapped
* Remove incorrect clean up in rpcrdma_sendctxs_destroy
* Further clean up of rl_mapped_sges
* Create separate patch (description) for change in
  rpcrdma_prepare_hdr_sges
* Various micro-optimizations of branches and loops

---

Chuck Lever (7):
      xprtrdma: Clean up SGE accounting in rpcrdma_prepare_msg_sges()
      xprtrdma: Change return value of rpcrdma_prepare_send_sges()
      xprtrdma: Add data structure to manage RDMA Send arguments
      xprtrdma: "Unoptimize" rpcrdma_prepare_hdr_sges()
      xprtrdma: Manage RDMA Send arguments via lock-free circular queue
      xprtrdma: RPC completion should wait for Send completion
      xprtrdma: Remove atomic send completion counting


 net/sunrpc/xprtrdma/backchannel.c |    6 +
 net/sunrpc/xprtrdma/frwr_ops.c    |    8 -
 net/sunrpc/xprtrdma/rpc_rdma.c    |  119 +++++++++++++++-------
 net/sunrpc/xprtrdma/transport.c   |    7 +
 net/sunrpc/xprtrdma/verbs.c       |  198 +++++++++++++++++++++++++++++++++++--
 net/sunrpc/xprtrdma/xprt_rdma.h   |   76 +++++++++-----
 6 files changed, 320 insertions(+), 94 deletions(-)

--
Chuck Lever
