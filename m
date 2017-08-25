Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:35177 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754646AbdHYU1I (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Aug 2017 16:27:08 -0400
Received: by mail-it0-f52.google.com with SMTP id f1so55491ith.0
        for <linux-nfs@vger.kernel.org>; Fri, 25 Aug 2017 13:27:08 -0700 (PDT)
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Anna Schumaker <schumaker.anna@gmail.com>
Subject: [GIT PULL] Please pull NFSoRDMA client changes for Linux 4.14
Message-ID: <a4f65696-0602-cde6-fd6e-3017e268297f@gmail.com>
Date: Fri, 25 Aug 2017 16:27:05 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

The following changes since commit 16f73eb02d7e1765ccab3d2018e0bd98eb93d973:

  Linux 4.13-rc3 (2017-07-30 12:40:36 -0700)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-rdma-for-4.14-1

for you to fetch changes up to 67af6f652f9ccad772c48f7c959ad5aa23bdfb40:

  xprtrdma: Re-arrange struct rx_stats (2017-08-22 16:19:32 -0400)

----------------------------------------------------------------
These are mostly cleanups that remove unused variables, improve cache handling in structs,
and improve XDR encoding and decoding by switching over to xdr_streams.  This pull request
does not include "xprtdrdma: Use xprt_pin_rqst in rpcrdma_reply_handler" that you said you
could put on top of your other patches.

Thanks,
Anna
----------------------------------------------------------------
Chuck Lever (16):
      sunrpc: Const-ify all instances of struct rpc_xprt_ops
      xprtrdma: Add xdr_init_decode to rpcrdma_reply_handler()
      xprtrdma: Harden backchannel call decoding
      xprtrdma: Refactor rpcrdma_reply_handler()
      xprtrdma: Replace rpcrdma_count_chunks()
      xprtrdma: Remove opcode check in Receive completion handler
      xprtrdma: Remove rpcrdma_rep::rr_len
      xprtrdma: Clean up XDR decoding in rpcrdma_update_granted_credits()
      xprtrdma: Clean up rpcrdma_marshal_req() synopsis
      xprtrdma: Remove rpclen from rpcrdma_marshal_req
      xprtrdma: Set up an xdr_stream in rpcrdma_marshal_req()
      xprtrdma: Harden chunk list encoding against send buffer overflow
      xprtrdma: Clean up rpcrdma_bc_marshal_reply()
      xprtrdma: Remove imul instructions from rpcrdma_convert_iovs()
      xprtrdma: Remove imul instructions from chunk list encoders
      xprtrdma: Re-arrange struct rx_stats

 include/linux/sunrpc/xdr.h                 |  13 ++++
 include/linux/sunrpc/xprt.h                |   2 +-
 net/sunrpc/xprtrdma/backchannel.c          |  71 +++++++-----------
 net/sunrpc/xprtrdma/fmr_ops.c              |  10 +--
 net/sunrpc/xprtrdma/frwr_ops.c             |  12 +--
 net/sunrpc/xprtrdma/rpc_rdma.c             | 844 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++------------------------------------------------------------------------------------
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   2 +-
 net/sunrpc/xprtrdma/transport.c            |   7 +-
 net/sunrpc/xprtrdma/verbs.c                |  21 +++---
 net/sunrpc/xprtrdma/xprt_rdma.h            |  33 ++++++---
 net/sunrpc/xprtsock.c                      |   8 +-
 11 files changed, 597 insertions(+), 426 deletions(-)
