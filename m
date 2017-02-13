Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34872 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750943AbdBMQ4W (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Feb 2017 11:56:22 -0500
Subject: [PATCH v4 0/9] Series short description
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 13 Feb 2017 11:56:19 -0500
Message-ID: <20170213163936.15801.31225.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna-

Since we have a v4.10-rc8, I've taken the opportunity to update my
for-4.11 series based on mailing list discussion late last week.

Except for the ->timer fix, all keepalive-related patches have been
dropped for now. I have constructed a third keepalive prototype,
which I plan to submit for v4.12.


Also vailable in the "nfs-rdma-for-4.11" topic branch of this git
repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git

Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfs-rdma-for-4.11


Changes since v3:
- Rebased on v4.10-rc8
- RPC-over-RDMA keep-alive patches have been dropped

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

Chuck Lever (9):
      xprtrdma: Fix Read chunk padding
      xprtrdma: Per-connection pad optimization
      xprtrdma: Disable pad optimization by default
      xprtrdma: Reduce required number of send SGEs
      xprtrdma: Shrink send SGEs array
      xprtrdma: Properly recover FRWRs with in-flight FASTREG WRs
      xprtrdma: Handle stale connection rejection
      xprtrdma: Refactor management of mw_list field
      sunrpc: Allow xprt->ops->timer method to sleep


 net/sunrpc/xprt.c               |    2 -
 net/sunrpc/xprtrdma/fmr_ops.c   |    5 --
 net/sunrpc/xprtrdma/frwr_ops.c  |   11 ++--
 net/sunrpc/xprtrdma/rpc_rdma.c  |   82 +++++++++++++++++++++------------
 net/sunrpc/xprtrdma/transport.c |    6 --
 net/sunrpc/xprtrdma/verbs.c     |   96 ++++++++++++++-------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |   30 +++++++++++-
 net/sunrpc/xprtsock.c           |    2 +
 8 files changed, 120 insertions(+), 114 deletions(-)

--
Chuck Lever
