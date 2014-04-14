Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:56623 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754275AbaDNWWZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2014 18:22:25 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/8] NFS/RDMA patches for review
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Mon, 14 Apr 2014 18:22:23 -0400
Message-ID: <20140414220041.20646.63991.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm interested in comments and testing, especially with
RPCRDMA_REGISTER mode because I don't have that capability set up on
my client yet.

These apply on top of Allen Andrews' and Steve Wise's recent patches,
which are included in the nfs-rdma-client topic branch at

  git://git.linux-nfs.org/projects/cel/cel-2.6.git

---

Chuck Lever (8):
      xprtrdma: Reduce the number of hardway buffer allocations
      xprtrdma: Split the completion queue
      xprtrdma: Make rpcrdma_ep_destroy() return void
      xprtrdma: Simplify rpcrdma_deregister_external() synopsis
      xprtrdma: Remove support for MEMWINDOWS registration mode
      xprtrdma: Disable ALLPHYSICAL mode by default
      xprtrdma: Remove BOUNCEBUFFERS memory registration mode
      xprtrdma: RPC/RDMA must invoke xprt_wake_pending_tasks() in process context


 include/linux/sunrpc/xprtrdma.h |    3 
 net/sunrpc/Kconfig              |   15 +
 net/sunrpc/xprtrdma/rpc_rdma.c  |   56 +----
 net/sunrpc/xprtrdma/transport.c |   32 ---
 net/sunrpc/xprtrdma/verbs.c     |  457 ++++++++++++++-------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |   10 -
 6 files changed, 195 insertions(+), 378 deletions(-)

-- 
Chuck Lever
