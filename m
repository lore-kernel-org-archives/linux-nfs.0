Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:35943 "EHLO
        mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751134AbdBHWBp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Feb 2017 17:01:45 -0500
Subject: [PATCH v3 00/12] NFS/RDMA client-side patches for 4.11
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 08 Feb 2017 16:59:37 -0500
Message-ID: <20170208214854.7152.83331.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna-

These are bug fixes and add support for RPC-over-RDMA connection
keepalive. The keepalive patches are still waiting for internal
testing resources to confirm they trigger connection loss in the
right circumstances, but my own testing shows they are behaving as
expected and do not introduce instability.

Available in the "nfs-rdma-for-4.11" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git


Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfs-rdma-for-4.11


Changes since v2:
- Rebased on v4.10-rc7
- v4.10-rc bugfixes merged into this series
- Minor improvements to patch descriptions
- Field moved in 12/12 now done in the correct patch


Changes since v1:
- Rebased on v4.10-rc6
- Tested-by and additional clean-up in 1/7
- Patch description clarifications
- Renamed some constants and variables

---

Chuck Lever (12):
      xprtrdma: Fix Read chunk padding
      xprtrdma: Per-connection pad optimization
      xprtrdma: Disable pad optimization by default
      xprtrdma: Reduce required number of send SGEs
      xprtrdma: Shrink send SGEs array
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
 include/linux/sunrpc/sched.h    |    4 +
 net/sunrpc/clnt.c               |   28 +++++-----
 net/sunrpc/xprt.c               |    6 +-
 net/sunrpc/xprtrdma/fmr_ops.c   |    5 --
 net/sunrpc/xprtrdma/frwr_ops.c  |   11 +---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   82 ++++++++++++++++++-----------
 net/sunrpc/xprtrdma/transport.c |   76 +++++++++++++++++++++++++--
 net/sunrpc/xprtrdma/verbs.c     |  109 +++++++++++++++------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |   37 ++++++++++++-
 net/sunrpc/xprtsock.c           |    2 +
 13 files changed, 234 insertions(+), 136 deletions(-)

--
Chuck Lever
