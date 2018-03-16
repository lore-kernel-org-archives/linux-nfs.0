Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:45775 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750986AbeCPO2W (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Mar 2018 10:28:22 -0400
Subject: [PATCH 0/2] Move Receive posting
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 16 Mar 2018 10:28:18 -0400
Message-ID: <20180316141927.14085.31012.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna-

Here is the main floor show for the RPC/RDMA client-side transport
implementation, for v4.17, now that the pre-requisites are out of
the way. With PATCH 1/2 applied, per-RPC RT latency improves by
about three microseconds, a substantial benefit for small RPCs on
typical fabrics.

I have one more RPC/RDMA patch for v4.17 that is a recent fix. It
is waiting for linux-rdma review and maybe a Tested-by.

---

Chuck Lever (2):
      xprtrdma: Move Receive posting to rpcrdma_reply_handler
      xprtrdma: Add static trace point in post_recvs


 include/trace/events/rpcrdma.h    |   40 ++++++++--
 net/sunrpc/xprtrdma/backchannel.c |   10 +-
 net/sunrpc/xprtrdma/rpc_rdma.c    |   17 ++--
 net/sunrpc/xprtrdma/transport.c   |    3 -
 net/sunrpc/xprtrdma/verbs.c       |  154 ++++++++++++++-----------------------
 net/sunrpc/xprtrdma/xprt_rdma.h   |    7 --
 6 files changed, 108 insertions(+), 123 deletions(-)

--
Chuck Lever
