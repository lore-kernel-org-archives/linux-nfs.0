Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34194 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752006AbcBCPvX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Feb 2016 10:51:23 -0500
Subject: [PATCH v1 00/10] NFS/RDMA server patches for v4.6
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 03 Feb 2016 10:51:21 -0500
Message-ID: <20160203154411.13868.48268.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For review.

- Fix XDR round-up in write chunks (take 3)
- Pre-allocate FRWRs when accepting a connection
- Add proper handling of bad header XDR
- Convert the server to use the new core CQ API added in v4.5.

Also available in the "nfsd-rdma-for-4.6" topic branch of this git
repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git

Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfsd-rdma-for-4.6

---

Chuck Lever (10):
      svcrdma: Do not send XDR roundup bytes for a write chunk
      svcrdma: Make svc_rdma_get_frmr() not sleep
      svcrdma: svc_rdma_post_recv() should close connection on error
      rpcrdma: Add missing XDR union fields for RDMA errors
      svcrdma: Make RDMA_ERROR messages work
      svcrdma: Use correct XID in error replies
      svcrdma: Hook up the logic to return ERR_CHUNK
      svcrdma: Remove close_out exit path
      svcrdma: Use new CQ API for RPC-over-RDMA server receive CQs
      svcrdma: Use new CQ API for RPC-over-RDMA server send CQs


 include/linux/sunrpc/rpc_rdma.h            |   13 +
 include/linux/sunrpc/svc_rdma.h            |   18 +
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   15 -
 net/sunrpc/xprtrdma/svc_rdma_marshal.c     |   62 ++--
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |   61 +---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |   79 ++++-
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |  488 +++++++++++-----------------
 7 files changed, 346 insertions(+), 390 deletions(-)

--
Chuck Lever
