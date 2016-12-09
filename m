Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:45954 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751388AbcLIVCA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Dec 2016 16:02:00 -0500
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Subject: [GIT PULL] Please pull NFSoRDMA client side changes for 4.10
Message-ID: <3ab13b73-d1ca-5b7e-b8e4-ec1385c2e612@Netapp.com>
Date: Fri, 9 Dec 2016 16:01:50 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

The following changes since commit e5517c2a5a49ed5e99047008629f1cd60246ea0e:

  Linux 4.9-rc7 (2016-11-27 13:08:04 -0800)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/nfs-rdma.git tags/nfs-rdma-4.10-1

for you to fetch changes up to 3a72dc771cc38e4d6e441a86256a3d7788a84c01:

  xprtrdma: Relocate connection helper functions (2016-11-29 16:45:44 -0500)

----------------------------------------------------------------
New Features:
- Support for SG_GAP devices

Bugfixes and cleanups:
- Cap size of callback buffer resources
- Improve send queue and RPC metric accounting
- Fix coverity warning
- Avoid calls to ro_unmap_safe()
- Refactor FRMR invalidation
- Error message improvements

Thanks,
Anna
----------------------------------------------------------------
Chuck Lever (12):
      xprtrdma: Cap size of callback buffer resources
      xprtrdma: Make FRWR send queue entry accounting more accurate
      xprtrdma: Support for SG_GAP devices
      SUNRPC: Proper metric accounting when RPC is not transmitted
      xprtrdma: Address coverity complaint about wait_for_completion()
      xprtrdma: Avoid calls to ro_unmap_safe()
      xprtrdma: Refactor FRMR invalidation
      xprtrdma: Update documenting comment
      xprtrdma: Squelch "max send, max recv" messages at connect time
      xprtrdma: Shorten QP access error message
      xprtrdma: Update dprintk in rpcrdma_count_chunks
      xprtrdma: Relocate connection helper functions

 net/sunrpc/stats.c                | 10 ++++++----
 net/sunrpc/xprtrdma/backchannel.c |  4 +++-
 net/sunrpc/xprtrdma/frwr_ops.c    | 94 ++++++++++++++++++++++++++++++++++++++++++++--------------------------------------------------
 net/sunrpc/xprtrdma/rpc_rdma.c    | 36 +-----------------------------------
 net/sunrpc/xprtrdma/transport.c   | 34 ++++++++++++++++++++++++++++++++--
 net/sunrpc/xprtrdma/verbs.c       | 37 ++++++++++++++++++++-----------------
 net/sunrpc/xprtrdma/xprt_rdma.h   | 31 ++++++++++++++++++++++---------
 7 files changed, 128 insertions(+), 118 deletions(-)
