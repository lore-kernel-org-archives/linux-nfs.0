Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:34335 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754379AbbETRvI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 May 2015 13:51:08 -0400
Received: by laat2 with SMTP id t2so84801721laa.1
        for <linux-nfs@vger.kernel.org>; Wed, 20 May 2015 10:51:06 -0700 (PDT)
From: Devesh Sharma <devesh.sharma@avagotech.com>
References: <20150511174401.31263.79596.stgit@manet.1015granger.net>
In-Reply-To: <20150511174401.31263.79596.stgit@manet.1015granger.net>
MIME-Version: 1.0
Date: Wed, 20 May 2015 23:21:05 +0530
Message-ID: <5ef257f7e6f813e71a2adc8db562129a@mail.gmail.com>
Subject: RE: [PATCH v2 00/16] NFS/RDMA patches proposed for 4.2
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Medusa test passes with average load.

Tested-By: Devesh Sharma <devesh.sharma@avagotech.com>

> -----Original Message-----
> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
> owner@vger.kernel.org] On Behalf Of Chuck Lever
> Sent: Monday, May 11, 2015 11:32 PM
> To: linux-rdma@vger.kernel.org; linux-nfs@vger.kernel.org
> Subject: [PATCH v2 00/16] NFS/RDMA patches proposed for 4.2
>
> I'd like these patches to be considered for merging upstream. This patch
> series
> includes:
>
>   - JIT allocation of rpcrdma_mw structures
>   - Break-up of rb_lock
>   - Reduction of how many rpcrdma_mw structs are needed per transport
>
> These are pre-requisites for increasing the RPC slot count and r/wsize on
> RPC/RDMA transports, and provide scalability benefits even on their own.
> And:
>
>   - A generic transport fault injector
>
> This is useful to discover regressions in logic that handles transport
> reconnection.
>
> You can find these in my git repo in the "nfs-rdma-for-4.2" topic branch.
> See:
>
>   git://git.linux-nfs.org/projects/cel/cel-2.6.git
>
>
> Changes since v1:
>
>   - Rebased on 4.1-rc3
>   - Transport fault injector controlled from debugfs rather than /proc
>   - Transport fault injector works for all transport types
>   - bc_send() clean up suggested by Christoph Hellwig
>   - Added Reviewed-by: tags. Many thanks to reviewers!
>   - Addressed all review comments but one: Sagi's comment about
>      ri_device remains unresolved.
>
> ---
>
> Chuck Lever (16):
>       SUNRPC: Transport fault injection
>       xprtrdma: Warn when there are orphaned IB objects
>       xprtrdma: Replace rpcrdma_rep::rr_buffer with rr_rxprt
>       xprtrdma: Remove rr_func
>       xprtrdma: Use ib_device pointer safely
>       xprtrdma: Introduce helpers for allocating MWs
>       xprtrdma: Acquire FMRs in rpcrdma_fmr_register_external()
>       xprtrdma: Introduce an FRMR recovery workqueue
>       xprtrdma: Acquire MRs in rpcrdma_register_external()
>       xprtrdma: Remove unused LOCAL_INV recovery logic
>       xprtrdma: Remove ->ro_reset
>       xprtrdma: Remove rpcrdma_ia::ri_memreg_strategy
>       xprtrdma: Split rb_lock
>       xprtrdma: Stack relief in fmr_op_map()
>       xprtrdma: Reduce per-transport MR allocation
>       SUNRPC: Clean up bc_send()
>
>
>  include/linux/sunrpc/bc_xprt.h     |    1
>  include/linux/sunrpc/xprt.h        |   19 +++
>  include/linux/sunrpc/xprtrdma.h    |    3
>  net/sunrpc/Makefile                |    2
>  net/sunrpc/bc_svc.c                |   63 ---------
>  net/sunrpc/clnt.c                  |    1
>  net/sunrpc/debugfs.c               |   77 +++++++++++
>  net/sunrpc/svc.c                   |   33 ++++-
>  net/sunrpc/xprt.c                  |    2
>  net/sunrpc/xprtrdma/fmr_ops.c      |  120 +++++++++++------
>  net/sunrpc/xprtrdma/frwr_ops.c     |  227
> +++++++++++++++++++++++---------
>  net/sunrpc/xprtrdma/physical_ops.c |   14 --
>  net/sunrpc/xprtrdma/rpc_rdma.c     |    8 -
>  net/sunrpc/xprtrdma/transport.c    |   30 +++-
>  net/sunrpc/xprtrdma/verbs.c        |  257
> +++++++++---------------------------
>  net/sunrpc/xprtrdma/xprt_rdma.h    |   38 ++++-
>  net/sunrpc/xprtsock.c              |   10 +
>  17 files changed, 492 insertions(+), 413 deletions(-)  delete mode 100644
> net/sunrpc/bc_svc.c
>
> --
> Chuck Lever
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body
> of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
