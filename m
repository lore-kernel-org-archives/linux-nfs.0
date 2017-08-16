Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34847 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752377AbdHPXAO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Aug 2017 19:00:14 -0400
Received: by mail-io0-f196.google.com with SMTP id h70so3119338ioi.2
        for <linux-nfs@vger.kernel.org>; Wed, 16 Aug 2017 16:00:14 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 0/5] RPC client latency fixes
Date: Wed, 16 Aug 2017 19:00:03 -0400
Message-Id: <20170816230008.20006-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patches apply on top of the writeback patches sent last
week. They start the process of reducing contention in the RPC client
receive code due to excessive holding of the transport lock.

The first patch is the most important in that it allows the client to
drop the transport lock while copying data from the socket into the
RPC call's reply buffers.
The second ensures that we don't keep hogging the workqueue worker thread
forever, but that we reschedule the receive job if it keeps looping.
Finally, a small cleanup to avoid having to make a copy of the
struct xdr_skb_reader on the stack.

v2: Reorder patches to add I/O throttling after the core RPC latency
changes
    Fix a crash when receiving backchannel requests.

v3: Another bugfix for backchannel requests.
    Add a separate spinlock to protect the RPC request receive list

Trond Myklebust (5):
  SUNRPC: Don't hold the transport lock across socket copy operations
  SUNRPC: Don't hold the transport lock when receiving backchannel data
  SUNRPC: Don't loop forever in xs_tcp_data_receive()
  SUNRPC: Cleanup xs_tcp_read_common()
  SUNRPC: Add a separate spinlock to protect the RPC request receive
    list

 include/linux/sunrpc/sched.h   |  2 ++
 include/linux/sunrpc/xprt.h    |  3 ++
 net/sunrpc/backchannel_rqst.c  |  4 +--
 net/sunrpc/xprt.c              | 55 +++++++++++++++++++++++++---
 net/sunrpc/xprtrdma/rpc_rdma.c |  8 ++---
 net/sunrpc/xprtsock.c          | 82 ++++++++++++++++++++++--------------------
 6 files changed, 105 insertions(+), 49 deletions(-)

-- 
2.13.5

