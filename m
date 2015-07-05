Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:51027 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751544AbbGEXVy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Jul 2015 19:21:54 -0400
From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH V3 0/5] Transport-independent MRs
To: dledford@redhat.com
Cc: sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org
Date: Sun, 05 Jul 2015 18:21:53 -0500
Message-ID: <20150705231831.12029.80307.stgit@build2.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series introduces transport-independent RDMA core services for
allocating DMA MRs and computing fast register access flags.  Included are
changes to the iSER and NFSRDMA ULPs to make use of the new services.

I've done iozone/fio testing on NFSRDMA with cxgb4, and fio testing over
iSER with cxgb4 and mlx4 devices.

I'm sending this out now for more review, but will be gone most of next
week, so I might not reply to any comments until after 7/12.

Changes since V2:

This series is a spin-off of the iSER/iWARP series.  I've tried to incorporate
all the feedback from that series regarding the core changes.  One outstanding
issue is whether to merge this into ib_create_mr().  Still waiting on feedback
from others on this.

Added iSER changes to make use of the new services.  This series is dependent on
the iSER/iWARP series currently under review (V5 of that serie ssent out today). 

Added NFSRDMA patches to make use of the new services.

---

Steve Wise (5):
      xprtrdma: Use transport independent MR allocation
      svcrdma: Use transport independent MR allocation
      RDMA/isert: Use transport independent MR allocation
      RDMA/iser: Use transport independent MR allocation
      RDMA/core: Transport-independent access flags


 drivers/infiniband/core/verbs.c           |   30 ++++++++
 drivers/infiniband/ulp/iser/iser_memory.c |    7 +-
 drivers/infiniband/ulp/iser/iser_verbs.c  |    7 +-
 drivers/infiniband/ulp/isert/ib_isert.c   |   36 ++--------
 include/rdma/ib_verbs.h                   |  106 +++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/frwr_ops.c            |    6 +-
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c   |    3 +
 net/sunrpc/xprtrdma/svc_rdma_transport.c  |   41 ++++-------
 net/sunrpc/xprtrdma/verbs.c               |   11 +--
 9 files changed, 175 insertions(+), 72 deletions(-)

-- 
Steve
