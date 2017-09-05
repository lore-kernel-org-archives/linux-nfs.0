Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34588 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752315AbdIERAO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Sep 2017 13:00:14 -0400
Subject: [PATCH RFC 0/5] xprtrdma Send completion batching
From: Chuck Lever <chuck.lever@oracle.com>
To: jgunthorpe@obsidianresearch.com, sagi@grimberg.me
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 05 Sep 2017 13:00:10 -0400
Message-ID: <20170905164347.11106.27140.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jason, Sagi-

As we discussed a few weeks ago, this patch series implements the
following:

- Send SGEs are now managed via lock-less, wait-free circular queues
- Send SGEs referring to page cache pages are DMA unmapped during
  Send completion
- Send completions are batched to reduce interrupts, but still
  provide a periodic heartbeat signal for SQ housekeeping
- The circular queue prevents Send Queue overflow

The purpose of this change is to address the issue Sagi reported
where the HCA continues to retry a delayed Send request _after_ RPC
completion, resulting in a DMA error.

Also available as the first five commits in this topic branch:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=shortlog;h=refs/heads/nfs-rdma-for-4.15

---

Chuck Lever (5):
      xprtrdma: Clean up SGE accounting in rpcrdma_prepare_msg_sges()
      xprtrdma: Change return value of rpcrdma_prepare_send_sges()
      xprtrdma: Add data structure to manage RDMA Send arguments
      xprtrdma: Manage RDMA Send arguments via lock-free circular queue
      xprtrdma: Remove atomic send completion counting


 net/sunrpc/xprtrdma/backchannel.c |    6 +
 net/sunrpc/xprtrdma/frwr_ops.c    |    8 -
 net/sunrpc/xprtrdma/rpc_rdma.c    |  104 +++++++++++-------
 net/sunrpc/xprtrdma/transport.c   |    6 +
 net/sunrpc/xprtrdma/verbs.c       |  210 +++++++++++++++++++++++++++++++++++--
 net/sunrpc/xprtrdma/xprt_rdma.h   |   66 +++++++-----
 6 files changed, 308 insertions(+), 92 deletions(-)

--
Chuck Lever
