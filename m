Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:34963 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752282AbbKWWUP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Nov 2015 17:20:15 -0500
Subject: [PATCH v1 0/8] NFS/RDMA server patches for 4.5
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 23 Nov 2015 17:20:13 -0500
Message-ID: <20151123221738.13040.26277.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here are patches to support server-side bi-directional RPC/RDMA
operation (to enable NFSv4.1 on RPC/RDMA transports). These still
need testing, but they are ready for initial review.

Also available in the "nfsd-rdma-for-4.5" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git

Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfsd-rdma-for-4.5

---

Chuck Lever (8):
      svcrdma: Do not send XDR roundup bytes for a write chunk
      svcrdma: Define maximum number of backchannel requests
      svcrdma: Add svc_rdma_get_context() API that is allowed to fail
      svcrdma: Add infrastructure to send backwards direction RPC/RDMA calls
      svcrdma: Add infrastructure to receive backwards direction RPC/RDMA replies
      xprtrdma: Add class for RDMA backwards direction transport
      svcrdma: No need to count WRs in svc_rdma_send()
      svcrdma: Remove svc_rdma_fastreg_mr::access_flags field


 include/linux/sunrpc/svc_rdma.h          |   12 +
 include/linux/sunrpc/xprt.h              |    1 
 net/sunrpc/xprt.c                        |    1 
 net/sunrpc/xprtrdma/rpc_rdma.c           |   76 +++++++++
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   72 ++++++++-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   74 +++++++++
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   65 ++++++--
 net/sunrpc/xprtrdma/transport.c          |  243 ++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/xprt_rdma.h          |    6 +
 9 files changed, 519 insertions(+), 31 deletions(-)

--
Chuck Lever
