Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:50930 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753511AbbGXQSQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jul 2015 12:18:16 -0400
From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH V6 0/9] iSER support for iWARP
To: dledford@redhat.com
Cc: infinipath@intel.com, sagig@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        bfields@fieldses.org
Date: Fri, 24 Jul 2015 11:18:15 -0500
Message-ID: <20150724161331.25617.8475.stgit@build2.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following series implements support for iWARP transports in the iSER
initiator and target.  This is based on v4.2-rc3.

I know we're in the middle of some API changes that will affect the isert
patches in this series, but I wanted to get these out for another round
of review.  I can merge the isert changes on top of the new API once
it solidifies and we have a staging tree for them.  My goal is to get
this series in for 4.3, so if the API changes don't gel fairly soon,
I ask that we consider pulling this series in first.  But I'm definitly
willing to help get this -and- the API stuff in for 4.3.

Changes since V5:

The big change in V6 is to introduce new register/unregister functions in isert
to use FRMRs + local dma lkey for devices that support this yet do not
support DIF/PI.  So iWARP devices do not require a DMA-MR.

svcrdma patch added to use max_sge_rd.

reordered the series some:
	patch 1 is the small iser changes to support iwarp
	patches 2..5 fix drivers to set max_sge_rd and ULPs to use them
	patches 6-9 enhance isert to support iwarp

Changes since V4:

iser: fixedcompiler warning

isert: back to setting REMOTE_WRITE only for iWARP devices

Changes since V3:

Fixed commit messages based on feedback.

iser: adjust max_sectors

isert: split into 2 patches

isert: always set REMOTE_WRITE for dma mrs

Changes since V2:

The transport independent work is removed from this series and will
be submitted in a subsequent series.  This V3 series now enables iWARP
using existing core services.

Changes since V1:

Introduce and use transport-independent RDMA core services for allocating
DMA MRs and computing fast register access flags.

Correctly set the device max_sge_rd capability in several rdma device
drivers.

isert: use device capability max_sge_rd for the read sge depth.

isert: change max_sge to max_write_sge in struct isert_conn.

---

Sagi Grimberg (1):
      mlx4, mlx5, mthca: Expose max_sge_rd correctly

Steve Wise (8):
      isert: Support iWARP transports using FRMRs
      isert: Use local_dma_lkey whenever possible.
      isert: Use the device's max fastreg page list depth
      isert: Rename IO functions to more descriptive names
      RDMA/isert: Limit read depth based on the device max_sge_rd capability
      svcrdma: Use max_sge_rd for destination read depths
      ipath,qib: Expose max_sge_rd correctly
      RDMA/iser: Limit sg tablesize and max_sectors to device fastreg max depth


 drivers/infiniband/hw/ipath/ipath_verbs.c    |    1 
 drivers/infiniband/hw/mlx4/main.c            |    1 
 drivers/infiniband/hw/mlx5/main.c            |    1 
 drivers/infiniband/hw/mthca/mthca_provider.c |    1 
 drivers/infiniband/hw/qib/qib_verbs.c        |    1 
 drivers/infiniband/ulp/iser/iscsi_iser.c     |    9 +
 drivers/infiniband/ulp/isert/ib_isert.c      |  345 ++++++++++++++++++++++----
 drivers/infiniband/ulp/isert/ib_isert.h      |    5 
 include/linux/sunrpc/svc_rdma.h              |    1 
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c      |   12 -
 net/sunrpc/xprtrdma/svc_rdma_transport.c     |    4 
 11 files changed, 320 insertions(+), 61 deletions(-)

-- 
Steve
