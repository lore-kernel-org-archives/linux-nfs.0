Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:53278 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932736AbbLRUot (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Dec 2015 15:44:49 -0500
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: [GIT PULL] Please Pull NFSoRDMA Client Side Changes for 4.5
Message-ID: <5674703D.4050001@Netapp.com>
Date: Fri, 18 Dec 2015 15:44:45 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

The following changes since commit 9f9499ae8e6415cefc4fe0a96ad0e27864353c89:

  Linux 4.4-rc5 (2015-12-13 17:42:58 -0800)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/nfs-rdma.git tags/nfs-rdma-4.5

for you to fetch changes up to 26ae9d1c5af1b1d669ca1c28fc02bbca3d778d45:

  xprtrdma: Revert commit e7104a2a9606 ('xprtrdma: Cap req_cqinit'). (2015-12-18 15:34:33 -0500)

Thanks,
Anna

----------------------------------------------------------------
Chuck Lever (10):
      xprtrdma: Fix additional uses of spin_lock_irqsave(rb_lock)
      xprtrdma: xprt_rdma_free() must not release backchannel reqs
      xprtrdma: Disable RPC/RDMA backchannel debugging messages
      xprtrdma: Move struct ib_send_wr off the stack
      xprtrdma: Introduce ro_unmap_sync method
      xprtrdma: Add ro_unmap_sync method for FRWR
      xprtrdma: Add ro_unmap_sync method for FMR
      xprtrdma: Add ro_unmap_sync method for all-physical registration
      xprtrdma: Invalidate in the RPC reply handler
      xprtrdma: Revert commit e7104a2a9606 ('xprtrdma: Cap req_cqinit').

Dan Carpenter (2):
      xprtrdma: clean up some curly braces
      xprtrdma: checking for NULL instead of IS_ERR()

 net/sunrpc/xprtrdma/backchannel.c  |  26 ++++++-------
 net/sunrpc/xprtrdma/fmr_ops.c      |  64 +++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/frwr_ops.c     | 174 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-----------
 net/sunrpc/xprtrdma/physical_ops.c |  13 +++++++
 net/sunrpc/xprtrdma/rpc_rdma.c     |  16 ++++++++
 net/sunrpc/xprtrdma/transport.c    |   3 ++
 net/sunrpc/xprtrdma/verbs.c        |  16 ++++----
 net/sunrpc/xprtrdma/xprt_rdma.h    |  14 ++++---
 8 files changed, 275 insertions(+), 51 deletions(-)
