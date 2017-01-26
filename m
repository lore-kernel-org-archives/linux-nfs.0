Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:33304 "EHLO
        mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753880AbdAZSVT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2017 13:21:19 -0500
Subject: [PATCH v1 0/7] NFS/RDMA client-side patches for 4.11
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 26 Jan 2017 12:55:30 -0500
Message-ID: <20170126174806.5794.14678.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry this is later than usual. Fortunately the patches are small
and few in number.

These are bug fixes based on v4.10-rc5 + my for-4.10-rc fixes. They
are still being tested; I'm posting for review only.

I've included an updated set of patches that implement keepalive
for RPC-over-RDMA with the changes discussed recently in this
thread:

  http://marc.info/?l=linux-nfs&m=148433523625936&w=2


Available in the "nfs-rdma-for-4.11" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git


Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfs-rdma-for-4.11


---

Chuck Lever (7):
      xprtrdma: Properly recover FRWRs with in-flight FASTREG WRs
      xprtrdma: Handle stale connection rejection
      xprtrdma: Refactor management of mw_list field
      sunrpc: Allow xprt->ops->timer method to sleep
      sunrpc: Enable calls to rpc_call_null_helper() from other modules
      xprtrdma: Detect unreachable NFS/RDMA servers more reliably
      sunrpc: Allow keepalive ping on a credit-full transport


 include/linux/sunrpc/clnt.h     |    5 ++
 include/linux/sunrpc/sched.h    |    2 +
 net/sunrpc/clnt.c               |   21 +++++----
 net/sunrpc/xprt.c               |    6 ++-
 net/sunrpc/xprtrdma/fmr_ops.c   |    5 --
 net/sunrpc/xprtrdma/frwr_ops.c  |   11 ++---
 net/sunrpc/xprtrdma/rpc_rdma.c  |    7 +--
 net/sunrpc/xprtrdma/transport.c |   63 ++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/verbs.c     |   93 ++++++++++++++-------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |   21 +++++++++
 net/sunrpc/xprtsock.c           |    2 +
 11 files changed, 149 insertions(+), 87 deletions(-)

--
Chuck Lever
