Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:36741 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752352AbaFYWr1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jun 2014 18:47:27 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Chuck Lever'" <chuck.lever@oracle.com>, <linux-rdma@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
References: <20140623223201.1634.83888.stgit@manet.1015granger.net>
In-Reply-To: <20140623223201.1634.83888.stgit@manet.1015granger.net>
Subject: RE: [PATCH v1 00/13] NFS/RDMA patches for 3.17
Date: Wed, 25 Jun 2014 17:47:54 -0500
Message-ID: <007f01cf90c7$802c9210$8085b630$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Chuck, 

I did some testing on this series.  Just 2 nodes, both nfs3 and nfs4 over cxgb4 and mlx4:

cthon b/g/s 10 iterations
iozone -a with direct IO and data validation
fio write and rand-rw testing of large IO/files and 8 threads.
xfs test suite.

No regressions seen.

Tested-by: Steve Wise <swise@opengridcomputing.com>


> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf
> Of Chuck Lever
> Sent: Monday, June 23, 2014 5:39 PM
> To: linux-rdma@vger.kernel.org; linux-nfs@vger.kernel.org
> Subject: [PATCH v1 00/13] NFS/RDMA patches for 3.17
> 
> The main purpose of this series is to address more connection drop
> recovery issues by fixing FRMR re-use to make it less likely the
> client will drop the connection due to a memory operation error.
> 
> Some other clean-ups and fixes are present as well.
> 
> See topic branch nfs-rdma-for-3.17 in
> 
>   git://git.linux-nfs.org/projects/cel/cel-2.6.git
> 
> I tested with NFSv3 and NFSv4 on all three supported memory
> registration modes. Used cthon04 and iozone with both Solaris
> and Linux NFS/RDMA servers. Used xfstests with Linux.
> 
> ---
> 
> Chuck Lever (13):
>       xprtrdma: Fix panic in rpcrdma_register_frmr_external()
>       xprtrdma: Protect ->qp during FRMR deregistration
>       xprtrdma: Limit data payload size for ALLPHYSICAL
>       xprtrdma: Update rkeys after transport reconnect
>       xprtrdma: Don't drain CQs on transport disconnect
>       xprtrdma: Unclutter struct rpcrdma_mr_seg
>       xprtrdma: Encode Work Request opcode in wc->wr_id
>       xprtrdma: Back off rkey when FAST_REG_MR fails
>       xprtrdma: Refactor rpcrdma_buffer_put()
>       xprtrdma: Release FRMR segment buffers during LOCAL_INV completion
>       xprtrdma: Clean up rpcrdma_ep_disconnect()
>       xprtrdma: Remove RPCRDMA_PERSISTENT_REGISTRATION macro
>       xprtrdma: Handle additional connection events
> 
> 
>  include/linux/sunrpc/xprtrdma.h |    2
>  net/sunrpc/xprtrdma/rpc_rdma.c  |   77 +++++----
>  net/sunrpc/xprtrdma/transport.c |   17 +-
>  net/sunrpc/xprtrdma/verbs.c     |  330 +++++++++++++++++++++++++++------------
>  net/sunrpc/xprtrdma/xprt_rdma.h |   63 ++++++-
>  5 files changed, 332 insertions(+), 157 deletions(-)
> 
> --
> Chuck Lever
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

