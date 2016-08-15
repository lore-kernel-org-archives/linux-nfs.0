Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35323 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932182AbcHOU6B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Aug 2016 16:58:01 -0400
Subject: [PATCH v1 0/3] server-side NFS/RDMA patches proposed for v4.9
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 15 Aug 2016 16:57:58 -0400
Message-ID: <20160815205032.11731.16708.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Posted for review, the following patch series makes these changes:

- Introduce simple RDMA-CM private message exchange
- Support Remote Invalidation

Available in the "nfsd-rdma-for-4.9" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git


Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfsd-rdma-for-4.9


---

Chuck Lever (3):
      rpcrdma: RDMA/CM private message data structure
      svcrdma: Server-side support for rpcrdma_connect_private
      svcrdma: support Remote Invalidation for prototyping


 include/linux/sunrpc/rpc_rdma.h          |   35 ++++++++++++++++++
 include/linux/sunrpc/svc_rdma.h          |    1 +
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   58 ++++++++++++++++++++++++++++--
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   42 +++++++++++++++++++---
 4 files changed, 128 insertions(+), 8 deletions(-)

--
Chuck Lever
