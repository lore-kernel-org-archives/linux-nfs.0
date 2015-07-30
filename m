Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:52668 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751074AbbG3HdN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jul 2015 03:33:13 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
        target-devel@vger.kernel.org
Subject: [PATCH for-4.3 00/15] Modify MR allocation API
Date: Thu, 30 Jul 2015 10:32:33 +0300
Message-Id: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch set is detached from my WIP for modifying our
fast registration kernel API. I incorporated some comments
from Jason and Christoph. The current set is a drop-in replacement
of ib_alloc_fast_reg_mr to ib_alloc_mr which receives a memory
region type (whcih can be IB_MR_TYPE_MEM_REG for normal memory
registration, IB_MR_TYPE_SIGNATURE for a data-integrity capable
memory region and future arbitrary SG support capable memory
region).

Sagi Grimberg (15):
  IB/core: Get rid of redundant verb ib_destroy_mr
  IB: Modify ib_create_mr API
  IB/iser: Convert to ib_alloc_mr
  iser-target: Convert to ib_alloc_mr
  IB/srp: Convert to ib_alloc_mr
  xprtrdma, svcrdma: Convert to ib_alloc_mr
  RDS: Convert to ib_alloc_mr
  mlx5: Drop mlx5_ib_alloc_fast_reg_mr
  mlx4: Support ib_alloc_mr verb
  ocrdma: Support ib_alloc_mr verb
  iw_cxgb4: Support ib_alloc_mr verb
  cxgb3: Support ib_alloc_mr verb
  nes: Support ib_alloc_mr verb
  qib: Support ib_alloc_mr verb
  IB/core: Drop ib_alloc_fast_reg_mr

 drivers/infiniband/core/verbs.c             |  62 +++++------------
 drivers/infiniband/hw/cxgb3/iwch_provider.c |  14 ++--
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h      |   4 +-
 drivers/infiniband/hw/cxgb4/mem.c           |  12 +++-
 drivers/infiniband/hw/cxgb4/provider.c      |   2 +-
 drivers/infiniband/hw/mlx4/main.c           |   2 +-
 drivers/infiniband/hw/mlx4/mlx4_ib.h        |   5 +-
 drivers/infiniband/hw/mlx4/mr.c             |  11 ++-
 drivers/infiniband/hw/mlx5/main.c           |   4 +-
 drivers/infiniband/hw/mlx5/mlx5_ib.h        |   8 +--
 drivers/infiniband/hw/mlx5/mr.c             | 104 +++++++---------------------
 drivers/infiniband/hw/nes/nes_verbs.c       |  19 +++--
 drivers/infiniband/hw/ocrdma/ocrdma_main.c  |   2 +-
 drivers/infiniband/hw/ocrdma/ocrdma_verbs.c |  11 ++-
 drivers/infiniband/hw/ocrdma/ocrdma_verbs.h |   4 +-
 drivers/infiniband/hw/qib/qib_mr.c          |   9 ++-
 drivers/infiniband/hw/qib/qib_verbs.c       |   2 +-
 drivers/infiniband/hw/qib/qib_verbs.h       |   4 +-
 drivers/infiniband/ulp/iser/iser_verbs.c    |  15 ++--
 drivers/infiniband/ulp/isert/ib_isert.c     |  14 ++--
 drivers/infiniband/ulp/srp/ib_srp.c         |   3 +-
 include/rdma/ib_verbs.h                     |  58 ++++------------
 net/rds/iw_rdma.c                           |   5 +-
 net/rds/iw_send.c                           |   5 +-
 net/sunrpc/xprtrdma/frwr_ops.c              |   6 +-
 net/sunrpc/xprtrdma/svc_rdma_transport.c    |   2 +-
 26 files changed, 159 insertions(+), 228 deletions(-)

-- 
1.8.4.3

