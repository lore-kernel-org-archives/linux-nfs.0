Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35885 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752316AbdHJQrF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Aug 2017 12:47:05 -0400
Received: by mail-it0-f65.google.com with SMTP id r9so2049372ita.3
        for <linux-nfs@vger.kernel.org>; Thu, 10 Aug 2017 09:47:05 -0700 (PDT)
Subject: [PATCH v1 0/5] Clean up XDR encoding of RPC/RDMA xprt hdrs
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 10 Aug 2017 12:47:03 -0400
Message-ID: <20170810164425.23774.91430.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna-

These patches harden xprtrdma's send_request code path, particu-
larly XDR encoding of outgoing transport headers. This is the flip
side of the series I sent last week. Again, I didn't copy
linux-rdma on this series since it is strictly XDR-related.

Please have a look at these and let me know if they are not
acceptable for v4.14.

---

Chuck Lever (5):
      xprtrdma: Clean up rpcrdma_marshal_req() synopsis
      xprtrdma: Remove rpclen from rpcrdma_marshal_req
      xprtrdma: Set up an xdr_stream in rpcrdma_marshal_req()
      xprtrdma: Harden chunk list encoding against send buffer overflow
      xprtrdma: Clean up rpcrdma_bc_marshal_reply()


 net/sunrpc/xprtrdma/backchannel.c |   31 ++--
 net/sunrpc/xprtrdma/rpc_rdma.c    |  280 +++++++++++++++++++++++--------------
 net/sunrpc/xprtrdma/transport.c   |    3 
 net/sunrpc/xprtrdma/xprt_rdma.h   |    4 -
 4 files changed, 199 insertions(+), 119 deletions(-)

--
Chuck Lever
