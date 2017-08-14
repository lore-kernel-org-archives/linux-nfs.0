Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36506 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752159AbdHNTiQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Aug 2017 15:38:16 -0400
Received: by mail-it0-f68.google.com with SMTP id o72so3896869ita.3
        for <linux-nfs@vger.kernel.org>; Mon, 14 Aug 2017 12:38:15 -0700 (PDT)
Subject: [PATCH v1 0/2] More xprt header XDR encoding clean up
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 14 Aug 2017 15:38:13 -0400
Message-ID: <20170814192946.25033.43917.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna-

Transport header encoding indexes some arrays. gcc doesn't seem to
be able to optimize the use of these arrays correctly (as it does in
other areas), and is instead using expensive integer multiplication
to compute array indices.

These two patches refactor the logic used during transport header
construction to eliminate the use of array[index] and instead use
*array++. This eliminates the use of imul instructions on x86.

As before, this is strictly a change to XDR encoding, so I have not
copied linux-rdma on these patches. Please have a look at these and
let me know if they are not acceptable for v4.14.

---

Chuck Lever (2):
      xprtrdma: Remove imul instructions from rpcrdma_convert_iovs()
      xprtrdma: Remove imul instructions from chunk list encoders


 net/sunrpc/xprtrdma/fmr_ops.c   |   10 +--
 net/sunrpc/xprtrdma/frwr_ops.c  |   12 ++-
 net/sunrpc/xprtrdma/rpc_rdma.c  |  150 ++++++++++++++++++---------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    3 +
 4 files changed, 82 insertions(+), 93 deletions(-)

--
Chuck Lever
