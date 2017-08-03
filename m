Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:38868 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751696AbdHCS34 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 14:29:56 -0400
Received: by mail-it0-f67.google.com with SMTP id h199so1839153ith.5
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 11:29:56 -0700 (PDT)
Subject: [PATCH v1 0/7] Clean up XDR decoding of RPC/RDMA xprt hdrs
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 03 Aug 2017 14:29:54 -0400
Message-ID: <20170803182623.14672.77636.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna-

These patches harden xprtrdma's reply handler code path, particu-
larly XDR decoding of incoming transport headers. I didn't copy
linux-rdma on this series since it is strictly XDR-related.

Please have a look at these and let me know if they are not
acceptable for v4.14.

---

Chuck Lever (7):
      xprtrdma: Add xdr_init_decode to rpcrdma_reply_handler()
      xprtrdma: Harden backchannel call decoding
      xprtrdma: Refactor rpcrdma_reply_handler()
      xprtrdma: Replace rpcrdma_count_chunks()
      xprtrdma: Remove opcode check in Receive completion handler
      xprtrdma: Remove rpcrdma_rep::rr_len
      xprtrdma: Clean up XDR decoding in rpcrdma_update_granted_credits()


 include/linux/sunrpc/xdr.h        |   13 +
 net/sunrpc/xprtrdma/backchannel.c |   40 +---
 net/sunrpc/xprtrdma/rpc_rdma.c    |  422 +++++++++++++++++++++++--------------
 net/sunrpc/xprtrdma/verbs.c       |   21 +-
 net/sunrpc/xprtrdma/xprt_rdma.h   |   13 +
 5 files changed, 304 insertions(+), 205 deletions(-)

--
Chuck Lever
