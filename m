Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33818 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752482AbdC0NsM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Mar 2017 09:48:12 -0400
Subject: [PATCH v2 00/13] Server-side NFS/RDMA changes proposed for v4.12
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 27 Mar 2017 09:47:54 -0400
Message-ID: <20170327132329.5585.98465.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series overhauls the "reply send" side of the RPC-over-RDMA
transport to use the new rdma_rw API. No significant performance
changes were noticed with this overhaul. Benefits include:

<> Better code modularity, less code duplication with other ULPs

<> Ability for svcrdma to use any registration mode for RDMA Writes

<> Correctly handle RPCs that have both a Write and a Reply chunk

<> Correctly handle Write chunk overrun


Available in the "nfsd-rdma-for-4.12" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git


Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfsd-rdma-for-4.12


Changes since v1:
- Rebased on v4.11-rc4
- Dropped clean up of svc_rdma_post_recv
- Postponed addition of code related to recvfrom
- Made svc_rdma_{get,put}_rw_ctxt behave symmetrically
- Converted scatterlist to sg_table
- Moved transport header construction into svc_rdma_sendto.c

This last one was the result of discussion with Sagi and Christoph
at LSF. Christoph wants to simplify the organization of this code
into fewer source files, and Sagi wants the rdma_rw code separated
from the code that builds the reply's transport header.

The remaining parts of the overhaul are in this topic branch:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfsd-rdma-rw-api

There are three significant pieces of work to do in nfsd-rdma-rw-api:

1. A new rdma_rw function needs to be introduced so that ULPs can
size their CQ, and perform SQ accounting, properly.

2. Similar separation of rdma_rw-related code and transport header
mangling needs to be done.

3. Organize this code path so that it might someday be invoked
directly by the upper layer, to better handle NFS WRITE.


---

Chuck Lever (13):
      svcrdma: Move send_wr to svc_rdma_op_ctxt
      svcrdma: Add svc_rdma_map_reply_hdr()
      svcrdma: Eliminate RPCRDMA_SQ_DEPTH_MULT
      svcrdma: Add helper to save pages under I/O
      svcrdma: Introduce local rdma_rw API helpers
      svcrdma: Use rdma_rw API in RPC reply path
      svcrdma: Clean up RDMA_ERROR path
      svcrdma: Report Write/Reply chunk overruns
      svcrdma: Clean up RPC-over-RDMA backchannel reply processing
      svcrdma: Reduce size of sge array in struct svc_rdma_op_ctxt
      svcrdma: Remove unused RDMA Write completion handler
      svcrdma: Remove the req_map cache
      svcrdma: Clean out old XDR encoders


 include/linux/sunrpc/rpc_rdma.h            |    3 
 include/linux/sunrpc/svc_rdma.h            |   74 +-
 net/sunrpc/xprtrdma/Makefile               |    2 
 net/sunrpc/xprtrdma/svc_rdma.c             |    8 
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   72 +-
 net/sunrpc/xprtrdma/svc_rdma_marshal.c     |   89 ---
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |   80 ++
 net/sunrpc/xprtrdma/svc_rdma_rw.c          |  463 +++++++++++++
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |  969 ++++++++++++++--------------
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |  110 ---
 10 files changed, 1073 insertions(+), 797 deletions(-)
 create mode 100644 net/sunrpc/xprtrdma/svc_rdma_rw.c

--
Chuck Lever
