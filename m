Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:33414 "EHLO
        mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967074AbdEWOxm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 May 2017 10:53:42 -0400
Subject: [PATCH v1 00/12] NFS/RDMA client-side patches proposed for v4.13
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 23 May 2017 10:53:37 -0400
Message-ID: <20170523142629.961.81233.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series contains a major fix for client-side NFS/RDMA.

When a signal fires, it's possible for the server's RPC reply to
race with the client code that terminates the RPC after a signal.
The result is both of these code paths try to invalidate the same
MR at the same time.

Because FRWR invalidation is typically fast, it's nearly impossible
to hit the race with FRWR. However, FMR invalidation happens at
about the same speed as the NFS server responds, so it's more likely
to hit this window when using FMR. FMR is also more sensitive to
concurrent operations on the same MR, which can result in a kernel
crash or an HCA firmware reset.

As part of closing the signal race window, the reply handler is
restructured and several error recovery paths in the invalidation
code are fixed.

In addition to this fix, there is a small but important change to
make NFSv4.1 Transparent State Migration work. This enables basic
test cases to pass successfully. However, NFSv4.1 TSM is still under
test, so the default setting of CONFIG_NFS_V4_1_MIGRATION remains
unchanged for the moment.


Available in the "nfs-rdma-for-4.13" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git


Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfs-rdma-for-4.13


Chuck Lever (12):
      xprtrdma: Don't defer MR recovery if ro_map fails
      xprtrdma: On invalidation failure, remove MWs from rl_registered
      xprtrdma: Fix FRWR invalidation error recovery
      xprtrdma: Pre-mark remotely invalidated MRs
      xprtrdma: Pass only the list of registered MRs to ro_unmap_sync
      xprtrdma: Rename rpcrdma_req::rl_free
      xprtrdma: Fix client lock-up after application signal fires
      NFSv4.1: Handle EXCHGID4_FLAG_CONFIRMED_R during NFSv4.1 migration
      xprtrdma: Demote "connect" log messages
      xprtrdma: FMR does not need list_del_init()
      xprtrdma: Replace PAGE_MASK with offset_in_page()
      xprtrdma: Fix documenting comments in frwr_ops.c


 fs/nfs/nfs4proc.c               |    2 -
 fs/nfs/nfs4state.c              |   11 +++
 net/sunrpc/xprtrdma/fmr_ops.c   |   47 ++++++++-------
 net/sunrpc/xprtrdma/frwr_ops.c  |   69 ++++++++++------------
 net/sunrpc/xprtrdma/rpc_rdma.c  |  125 +++++++++++++++++++++++++--------------
 net/sunrpc/xprtrdma/transport.c |    3 +
 net/sunrpc/xprtrdma/verbs.c     |   55 ++++-------------
 net/sunrpc/xprtrdma/xprt_rdma.h |   40 ++++++++++++
 8 files changed, 204 insertions(+), 148 deletions(-)

--
Chuck Lever
