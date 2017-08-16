Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:38436 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751575AbdHPQTd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Aug 2017 12:19:33 -0400
Received: by mail-io0-f196.google.com with SMTP id o9so2553195iod.5
        for <linux-nfs@vger.kernel.org>; Wed, 16 Aug 2017 09:19:32 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/6] RPC client latency fixes
Date: Wed, 16 Aug 2017 12:19:23 -0400
Message-Id: <20170816161929.11271-1-trond.myklebust@primarydata.com>
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

Trond Myklebust (6):
  SUNRPC: Don't hold the transport lock across socket copy operations
  SUNRPC: Don't hold the transport lock when receiving backchannel data
  SUNRPC: Don't loop forever in xs_tcp_data_receive()
  SUNRPC: Cleanup xs_tcp_read_common()
  SUNRPC: Add a function to allow waiting for RPC transmission
  NFS: Throttle I/O to the NFS server

 fs/nfs/pagelist.c             |  3 +-
 include/linux/sunrpc/sched.h  |  5 ++++
 include/linux/sunrpc/xprt.h   |  2 ++
 net/sunrpc/backchannel_rqst.c |  4 +--
 net/sunrpc/sched.c            | 22 +++++++++++++++
 net/sunrpc/xprt.c             | 48 +++++++++++++++++++++++++++++++
 net/sunrpc/xprtsock.c         | 66 ++++++++++++++++++++++---------------------
 7 files changed, 115 insertions(+), 35 deletions(-)

-- 
2.13.5

