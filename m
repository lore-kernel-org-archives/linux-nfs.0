Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34977 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753111AbcHVS5g (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Aug 2016 14:57:36 -0400
Subject: [PATCH v2 0/6] server-side NFS/RDMA patches proposed for v4.9
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 22 Aug 2016 14:57:33 -0400
Message-ID: <20160822185459.12076.43516.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Posted for review, the following patch series makes these changes:

- Bug fixes
- Introduce simple RDMA-CM private message exchange
- Support Remote Invalidation

Available in the "nfsd-rdma-for-4.9" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git


Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfsd-rdma-for-4.9


Changes since v1:
- Rebased on v4.8-rc3
- Added Reviewed-by tags
- Fixed additional bugs found in v4.8


---

Chuck Lever (6):
      SUNRPC: Silence WARN_ON when NFSv4.1 over RDMA is in use
      svcrdma: Tail iovec leaves an orphaned DMA mapping
      svcrdma: Skip put_page() when send_reply() fails
      rpcrdma: RDMA/CM private message data structure
      svcrdma: Server-side support for rpcrdma_connect_private
      svcrdma: support Remote Invalidation for prototyping


 include/linux/sunrpc/rpc_rdma.h            |   35 ++++++++++++
 include/linux/sunrpc/svc_rdma.h            |   10 +++
 net/sunrpc/clnt.c                          |    4 +
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    2 -
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |    2 -
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |   82 ++++++++++++++++++++--------
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |   60 +++++++++++++++++---
 7 files changed, 158 insertions(+), 37 deletions(-)

--
Chuck Lever
