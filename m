Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:35121 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932204Ab0HCQo4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Aug 2010 12:44:56 -0400
From: Tom Tucker <tom@ogc.us>
Subject: [PATCH 0/4] nfsrdma: Miscellanseous Bug Fixes
To: trond.myklebust@netapp.com, bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, swise@ogc.us, tom@ogc.us
Date: Tue, 03 Aug 2010 11:44:56 -0500
Message-ID: <20100803164411.2567.31416.stgit@build.ogc.int>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The following series fixes a number of bugs in the NFSRDMA transport.

---

Steve Wise (1):
      xprtrdma: Do not truncate iova_start values in frmr registrations.

Tom Tucker (3):
      rpcrdma: Fix SQ size calculation when memreg is FRMR
      svcrdma: Cleanup DMA unmapping in error paths.
      svcrdma: Change DMA mapping logic to avoid the page_address kernel API


 net/sunrpc/xprtrdma/rpc_rdma.c           |    2 +
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   19 ++++---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   82 ++++++++++++++++++++++--------
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   41 +++++++--------
 net/sunrpc/xprtrdma/verbs.c              |   22 ++++++--
 5 files changed, 111 insertions(+), 55 deletions(-)

-- 
Signed-off-by: Tom Tucker <tom@ogc.us>
