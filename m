Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:38066 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751807AbdHNTQ6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Aug 2017 15:16:58 -0400
Received: by mail-io0-f194.google.com with SMTP id o9so8062086iod.5
        for <linux-nfs@vger.kernel.org>; Mon, 14 Aug 2017 12:16:58 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] RPC client latency fixes
Date: Mon, 14 Aug 2017 15:16:49 -0400
Message-Id: <20170814191652.18263-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following 3 patches apply on top of the writeback patches sent last
week. They start the process of reducing contention in the RPC client
receive code due to excessive holding of the transport lock.

The first patch is the most important in that it allows the client to
drop the transport lock while copying data from the socket into the
RPC call's reply buffers.
The second ensures that we don't keep hogging the workqueue worker thread
forever, but that we reschedule the receive job if it keeps looping.
Finally, a small cleanup to avoid having to make a copy of the
struct xdr_skb_reader on the stack.

Trond Myklebust (3):
  SUNRPC: Don't hold the transport lock across socket copy operations
  SUNRPC: Don't loop forever in xs_tcp_data_receive()
  SUNRPC: Cleanup xs_tcp_read_common()

 include/linux/sunrpc/sched.h |  2 ++
 include/linux/sunrpc/xprt.h  |  2 ++
 net/sunrpc/xprt.c            | 42 ++++++++++++++++++++++++++++
 net/sunrpc/xprtsock.c        | 65 +++++++++++++++++++++++++-------------------
 4 files changed, 83 insertions(+), 28 deletions(-)

-- 
2.13.5

