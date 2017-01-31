Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:38506 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751865AbdAaSiO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Jan 2017 13:38:14 -0500
Subject: [PATCH v2 0/7] NFS/RDMA client-side patches for 4.11
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 31 Jan 2017 13:38:08 -0500
Message-ID: <20170131183345.5325.47072.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These are bug fixes based on v4.10-rc6 + my for-4.10-rc fixes.

The keepalive patches are still waiting for internal testing
resources.

Available in the "nfs-rdma-for-4.11" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git


Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfs-rdma-for-4.11


Changes since v1:
- Rebased on v4.10-rc6
- Tested-by and additional clean-up in 1/7
- Patch description clarifications
- Renamed some constants and variables


---

Chuck Lever (7):
      xprtrdma: Properly recover FRWRs with in-flight FASTREG WRs
      xprtrdma: Handle stale connection rejection
      xprtrdma: Refactor management of mw_list field
      sunrpc: Allow xprt->ops->timer method to sleep
      sunrpc: Enable calls to rpc_call_null_helper() from other modules
      xprtrdma: Detect unreachable NFS/RDMA servers more reliably
      sunrpc: Allow keepalive ping on a credit-full transport


 fs/nfs/nfs4proc.c               |    3 -
 fs/nfsd/nfs4callback.c          |    2 -
 include/linux/sunrpc/clnt.h     |    5 ++
 include/linux/sunrpc/sched.h    |    4 ++
 net/sunrpc/clnt.c               |   28 ++++++------
 net/sunrpc/xprt.c               |    6 ++
 net/sunrpc/xprtrdma/fmr_ops.c   |    5 --
 net/sunrpc/xprtrdma/frwr_ops.c  |   11 ++---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   20 +++++---
 net/sunrpc/xprtrdma/transport.c |   74 +++++++++++++++++++++++++++++--
 net/sunrpc/xprtrdma/verbs.c     |   94 ++++++++++++++-------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |   23 ++++++++++
 net/sunrpc/xprtsock.c           |    2 +
 13 files changed, 174 insertions(+), 103 deletions(-)

--
Chuck Lever
