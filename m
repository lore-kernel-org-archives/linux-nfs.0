Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:38149 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510AbbJHGD5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Oct 2015 02:03:57 -0400
Received: by igxx6 with SMTP id x6so5756489igx.1
        for <linux-nfs@vger.kernel.org>; Wed, 07 Oct 2015 23:03:56 -0700 (PDT)
From: Selvin Xavier <selvin.xavier@avagotech.com>
References: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
In-Reply-To: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
MIME-Version: 1.0
Date: Thu, 8 Oct 2015 11:33:55 +0530
Message-ID: <578d249d106203063b0ba29fba626195@mail.gmail.com>
Subject: RE: [PATCH v2 00/26] New fast registration API
To: Sagi Grimberg <sagig@mellanox.com>, linux-rdma@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sagi,

With the RDMA CM patch to accept RoCE
connections(https://patchwork.kernel.org/patch/7335451/) on top of
reg_api.5 branch,  I have tested  nfs rdma over ocrdma. Looks good.

Tested-by: Selvin Xavier <selvin.xavier@avagotech.com>

Thanks,
Selvin Xavier

> -----Original Message-----
> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
> owner@vger.kernel.org] On Behalf Of Sagi Grimberg
> Sent: Thursday, September 24, 2015 11:05 PM
> To: linux-rdma@vger.kernel.org
> Cc: linux-nfs@vger.kernel.org; Nicholas A. Bellinger
> Subject: [PATCH v2 00/26] New fast registration API
>
> Hi all,
>
> As discussed on the linux-rdma list, there is plenty of room for
improvement
> in our memory registration APIs. We keep finding ULPs that are
duplicating
> code, sometimes use wrong strategies and mis-use our current API.
>
> As a first step, this patch set replaces the fast registration API to
accept a
> kernel common struct scatterlist and takes care of the page vector
> construction in the core layer with hooks for the drivers HW specific
> assignments. This allows to remove a common code duplication as it was
> done in each and every ULP driver.
>
> Changes from v1:
> - Add ib_map_mr_sg_zbva() for RDS which uses it (preferred it over
>   polluting the API).
>
> - Replaced coherent allocations in mlx4, mlx5 with DMA streaming
>   APIs (Bart)
>
> - Changed ib_map_mr_sg description (Bart)
>
> - Split SRP driver patches (Bart)
>
> - Added missing wr->next = NULL from various ULPs (Steve, Santosh)
>
> - Fixed 0-day testing errors in nes driver, xprtrdma and svcrdma
>
> - Fixed checkpatch issues
>
> Changes from v0:
> - Rebased on top of 4.3-rc1 + Christoph's ib_send_wr conversion patches
>
> - Allow the ULP to pass page_size argument to ib_map_mr_sg in order
>   to have it work better in some specific workloads. This suggestion
>   came from Bart Van Assche which pointed out that some applications
>   might use page sizes significantly smaller than the system PAGE_SIZE
>   of specific architectures
>
> - Fixed some logical bugs in ib_sg_to_pages
>
> - Added a set_page function pointer for drivers to pass to
ib_sg_to_pages
>   so some drivers (e.g mlx4, mlx5, nes) can avoid keeping a second page
>   vector and/or re-iterate on the page vector in order to perform HW
specific
>   assignments (big/little endian conversion, extra flags)
>
> - Converted SRP initiator and RDS iwarp ULPs to the new API
>
> - Removed fast registration code from hfi1 driver (as it isn't supported
>   anyway). I assume that the correct place to get the support back would
>   be in a shared SW library (hfi1, qib, rxe).
>
> - Updated the change logs
>
> So far my tests covered:
> - ULPs:
> 	* iser initiator
> 	* iser target
> 	* xprtrdma
> 	* svcrdma
> - Drivers:
> 	* mlx4
> 	* mlx5
> 	* Steve Wise was kind enough to run NFS client/server over cxgb4
> and
> 	  reported good results.
> 	* Santosh reports that RDS IB conversion is functional and working
> 	  with ib_map_mr_sg_zbva
>
> I don't have access to other HW devices (qib, nes) nor iwarp devices so
RDS is
> compile tested only. Santosh reports
>
> I'm targeting this to 4.4 so I'll appreciate more feedback and a bigger
testing
> coverage.
>
> The code is available at:
> https://github.com/sagigrimberg/linux/tree/reg_api.4
>
> Sagi Grimberg (26):
>   IB/core: Introduce new fast registration API
>   IB/mlx5: Remove dead fmr code
>   IB/mlx5: Support the new memory registration API
>   IB/mlx4: Support the new memory registration API
>   RDMA/ocrdma: Support the new memory registration API
>   RDMA/cxgb3: Support the new memory registration API
>   iw_cxgb4: Support the new memory registration API
>   IB/qib: Support the new memory registration API
>   RDMA/nes: Support the new memory registration API
>   IB/iser: Port to new fast registration API
>   iser-target: Port to new memory registration API
>   xprtrdma: Port to new memory registration API
>   svcrdma: Port to new memory registration API
>   RDS/IW: Convert to new memory registration API
>   IB/srp: Split srp_map_sg
>   IB/srp: Convert to new registration API
>   IB/srp: Dont allocate a page vector when using fast_reg
>   IB/mlx5: Remove old FRWR API support
>   IB/mlx4: Remove old FRWR API support
>   RDMA/ocrdma: Remove old FRWR API
>   RDMA/cxgb3: Remove old FRWR API
>   iw_cxgb4: Remove old FRWR API
>   IB/qib: Remove old FRWR API
>   RDMA/nes: Remove old FRWR API
>   IB/hfi1: Remove Old fast registraion API support
>   IB/core: Remove old fast registration API
>
>  drivers/infiniband/core/verbs.c             | 132 +++++++++++---
>  drivers/infiniband/hw/cxgb3/iwch_cq.c       |   2 +-
>  drivers/infiniband/hw/cxgb3/iwch_provider.c |  39 +++--
>  drivers/infiniband/hw/cxgb3/iwch_provider.h |   2 +
>  drivers/infiniband/hw/cxgb3/iwch_qp.c       |  37 ++--
>  drivers/infiniband/hw/cxgb4/cq.c            |   2 +-
>  drivers/infiniband/hw/cxgb4/iw_cxgb4.h      |  25 +--
>  drivers/infiniband/hw/cxgb4/mem.c           |  61 +++----
>  drivers/infiniband/hw/cxgb4/provider.c      |   3 +-
>  drivers/infiniband/hw/cxgb4/qp.c            |  47 +++--
>  drivers/infiniband/hw/mlx4/cq.c             |   2 +-
>  drivers/infiniband/hw/mlx4/main.c           |   3 +-
>  drivers/infiniband/hw/mlx4/mlx4_ib.h        |  22 +--
>  drivers/infiniband/hw/mlx4/mr.c             | 143 ++++++++++------
>  drivers/infiniband/hw/mlx4/qp.c             |  34 ++--
>  drivers/infiniband/hw/mlx5/cq.c             |   4 +-
>  drivers/infiniband/hw/mlx5/main.c           |   3 +-
>  drivers/infiniband/hw/mlx5/mlx5_ib.h        |  47 +----
>  drivers/infiniband/hw/mlx5/mr.c             | 129 +++++++++-----
>  drivers/infiniband/hw/mlx5/qp.c             | 140 +++++++--------
>  drivers/infiniband/hw/nes/nes_hw.h          |   6 -
>  drivers/infiniband/hw/nes/nes_verbs.c       | 163 +++++++-----------
>  drivers/infiniband/hw/nes/nes_verbs.h       |   4 +
>  drivers/infiniband/hw/ocrdma/ocrdma.h       |   2 +
>  drivers/infiniband/hw/ocrdma/ocrdma_main.c  |   3 +-
>  drivers/infiniband/hw/ocrdma/ocrdma_verbs.c | 154 ++++++++---------
>  drivers/infiniband/hw/ocrdma/ocrdma_verbs.h |   7 +-
>  drivers/infiniband/hw/qib/qib_keys.c        |  42 ++---
>  drivers/infiniband/hw/qib/qib_mr.c          |  46 ++---
>  drivers/infiniband/hw/qib/qib_verbs.c       |  13 +-
>  drivers/infiniband/hw/qib/qib_verbs.h       |  13 +-
>  drivers/infiniband/ulp/iser/iscsi_iser.h    |   8 +-
>  drivers/infiniband/ulp/iser/iser_memory.c   |  54 +++---
>  drivers/infiniband/ulp/iser/iser_verbs.c    |  16 +-
>  drivers/infiniband/ulp/isert/ib_isert.c     | 130 +++-----------
>  drivers/infiniband/ulp/isert/ib_isert.h     |   2 -
>  drivers/infiniband/ulp/srp/ib_srp.c         | 255
++++++++++++++++------------
>  drivers/infiniband/ulp/srp/ib_srp.h         |  11 +-
>  drivers/staging/hfi1/keys.c                 |  55 ------
>  drivers/staging/hfi1/mr.c                   |  32 +---
>  drivers/staging/hfi1/verbs.c                |   9 +-
>  drivers/staging/hfi1/verbs.h                |   8 -
>  include/linux/sunrpc/svc_rdma.h             |   6 +-
>  include/rdma/ib_verbs.h                     |  86 +++++-----
>  net/rds/iw.h                                |   5 +-
>  net/rds/iw_rdma.c                           | 128 +++++---------
>  net/rds/iw_send.c                           |  57 +++----
>  net/sunrpc/xprtrdma/frwr_ops.c              | 113 +++++++-----
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c     |  76 +++++----
>  net/sunrpc/xprtrdma/svc_rdma_transport.c    |  34 ++--
>  net/sunrpc/xprtrdma/xprt_rdma.h             |   3 +-
>  51 files changed, 1143 insertions(+), 1275 deletions(-)
>
> --
> 1.8.4.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
