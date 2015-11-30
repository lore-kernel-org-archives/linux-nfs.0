Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:34643 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753854AbbK3WY1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Nov 2015 17:24:27 -0500
Subject: [PATCH v2 0/8] NFS/RDMA server patches for 4.5
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 30 Nov 2015 17:24:25 -0500
Message-ID: <20151130222141.13029.98664.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here are patches to support server-side bi-directional RPC/RDMA
operation (to enable NFSv4.1 on RPC/RDMA transports). Thanks to
all who reviewed v1.

Also available in the "nfsd-rdma-for-4.5" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git

Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfsd-rdma-for-4.5

Changes since v1:

- Rebased on v4.4-rc3
- Removed the use of CONFIG_SUNRPC_BACKCHANNEL
- Fixed computation of forward and backward max_requests
- Updated some comments and patch descriptions
- pr_err and pr_info converted to dprintk
- Simplified svc_rdma_get_context()
- Dropped patch removing access_flags field
- NFSv4.1 callbacks tested with for-4.5 client

---

Chuck Lever (8):
      svcrdma: Do not send XDR roundup bytes for a write chunk
      svcrdma: Add svc_rdma_get_context() API that is allowed to fail
      svcrdma: Define maximum number of backchannel requests
      svcrdma: Add infrastructure to send backwards direction RPC/RDMA calls
      svcrdma: Add infrastructure to receive backwards direction RPC/RDMA replies
      xprtrdma: Add class for RDMA backwards direction transport
      svcrdma: Display failed completions
      svcrdma: No need to count WRs in svc_rdma_send()


 include/linux/sunrpc/svc_rdma.h          |    8 +
 include/linux/sunrpc/xprt.h              |    1 
 net/sunrpc/xprt.c                        |    1 
 net/sunrpc/xprtrdma/rpc_rdma.c           |   72 +++++++++
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   61 ++++++++
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   72 +++++++++
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   88 +++++++----
 net/sunrpc/xprtrdma/transport.c          |  230 ++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/xprt_rdma.h          |    6 +
 9 files changed, 500 insertions(+), 39 deletions(-)

--
Chuck Lever
