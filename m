Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34596 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758832AbcIMOwg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Sep 2016 10:52:36 -0400
Subject: [PATCH v3 0/6] server-side NFS/RDMA patches proposed for v4.9
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 13 Sep 2016 10:52:33 -0400
Message-ID: <20160913144246.5733.66229.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

These are ready for you to consider for your "for v4.9" branch. They
include:

- Fix a couple of reference counting issues
- Introduce simple RDMA-CM private message exchange
- Support Remote Invalidation

Available in the "nfsd-rdma-for-4.9" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git


Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfsd-rdma-for-4.9


Changes since v2:
- Rebased on v4.8-rc6
- "SUNRPC: Silence WARN_ON when NFSv4.1 over RDMA is in use" has been merged
- Revert 64c59a3726f2 (add a "Cc: stable" if you think that's appropriate)


Changes since v1:
- Rebased on v4.8-rc3
- Added Reviewed-by tags
- Fixed additional bugs found in v4.8


---

Chuck Lever (6):
      svcauth_gss: Revert 64c59a3726f2 ("Remove unnecessary allocation")
      svcrdma: Tail iovec leaves an orphaned DMA mapping
      svcrdma: Skip put_page() when send_reply() fails
      rpcrdma: RDMA/CM private message data structure
      svcrdma: Server-side support for rpcrdma_connect_private
      svcrdma: support Remote Invalidation


 include/linux/sunrpc/rpc_rdma.h            |   35 ++++++++++++
 include/linux/sunrpc/svc_rdma.h            |   10 +++
 net/sunrpc/auth_gss/svcauth_gss.c          |    5 +-
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    2 -
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |    2 -
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |   82 ++++++++++++++++++++--------
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |   60 +++++++++++++++++---
 7 files changed, 159 insertions(+), 37 deletions(-)

--
Chuck Lever
