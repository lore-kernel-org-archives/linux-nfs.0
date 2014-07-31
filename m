Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:32777 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751654AbaGaUog (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Jul 2014 16:44:36 -0400
Message-ID: <53DAAAAC.80900@Netapp.com>
Date: Thu, 31 Jul 2014 16:44:28 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: <linux-rdma@vger.kernel.org>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v5 00/21] NFS/RDMA client patches for 3.17
References: <20140729211534.2812.3128.stgit@manet.1015granger.net>
In-Reply-To: <20140729211534.2812.3128.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've applied v5 and updated my tree.  Thanks, Chuck!

Anna

On 07/29/2014 05:23 PM, Chuck Lever wrote:
> The main purpose of this series is to address connection drop
> recovery issues by fixing FRMR re-use to make it less likely the
> client will deadlock due to a memory management operation error.
> Some clean-ups and other fixes are present as well.
> 
> See topic branch nfs-rdma-for-3.17-plan-b in
> 
> git://git.linux-nfs.org/projects/cel/cel-2.6.git
> 
> Topic branch nfs-rdma-for-3.17 still contains v4 of this series.
> You can choose whichever series is convenient for you and Roland.
> 
> I tested with NFSv3 and NFSv4 on all three supported memory
> registration modes. Used cthon04, iozone, vdbench, and dbench with
> both Solaris and Linux NFS/RDMA servers. Used xfstests with Linux.
> 
> 
> v5:
> 
> - Rebased on v3.16-rc7
> 
> - Replaced patch 08/21 with an equivalent one-liner that does not
>   alter include/rdma/ib_verbs.h. A couple of subsequent patches were
>   updated to apply on the new 08/21. This allows the whole series to
>   be submitted through the NFS tree.
> 
> 
> v4:
> 
> - Rebased on v3.16-rc6
> 
> - Add Tested-by: from Shirley Ma and Devesh Sharma
> 
> 
> v3:
> Only two substantive changes:
> 
> - Patch 08/21 now uses generic IB helpers for managing FRMR
>   rkeys
> 
> - Add Tested-by: from Steve Wise
> 
> 
> v2:
> Many patches from v1 have been written or replaced.
> 
> The MW ref counting approach in v1 is abandoned. Instead, I've
> eliminated signaling FAST_REG_MR and LOCAL_INV, and added
> appropriate recovery mechanisms after a transport reconnect that
> should prevent rkey dis-synchrony entirely.
> 
> A couple of optimizations have been added, including:
> 
> - Allocating each MW separately rather than carving each out of a
>   large piece of contiguous memory
> 
> - Now that the receive CQ upcall handler dequeues a bundle of CQEs
>   at once, fire off the reply handler tasklet just once per upcall
>   to reduce context switches and how often hard IRQs are disabled
> 
> ---
> 
> Chuck Lever (21):
>       xprtrdma: Fix panic in rpcrdma_register_frmr_external()
>       xprtrdma: Protect ia->ri_id when unmapping/invalidating MRs
>       xprtrdma: Limit data payload size for ALLPHYSICAL
>       xprtrdma: Update rkeys after transport reconnect
>       xprtrdma: On disconnect, don't ignore pending CQEs
>       xprtrdma: Don't invalidate FRMRs if registration fails
>       xprtrdma: Unclutter struct rpcrdma_mr_seg
>       xprtrdma: Back off rkey when FAST_REG_MR fails
>       xprtrdma: Chain together all MWs in same buffer pool
>       xprtrdma: Properly handle exhaustion of the rb_mws list
>       xprtrdma: Reset FRMRs when FAST_REG_MR is flushed by a disconnect
>       xprtrdma: Reset FRMRs after a flushed LOCAL_INV Work Request
>       xprtrdma: Don't post a LOCAL_INV in rpcrdma_register_frmr_external()
>       xprtrdma: Disable completions for FAST_REG_MR Work Requests
>       xprtrdma: Disable completions for LOCAL_INV Work Requests
>       xprtrdma: Rename frmr_wr
>       xprtrdma: Allocate each struct rpcrdma_mw separately
>       xprtrdma: Schedule reply tasklet once per upcall
>       xprtrdma: Make rpcrdma_ep_disconnect() return void
>       xprtrdma: Remove RPCRDMA_PERSISTENT_REGISTRATION macro
>       xprtrdma: Handle additional connection events
> 
> 
>  include/linux/sunrpc/xprtrdma.h |    2 
>  net/sunrpc/xprtrdma/rpc_rdma.c  |   83 ++--
>  net/sunrpc/xprtrdma/transport.c |   17 +
>  net/sunrpc/xprtrdma/verbs.c     |  736 ++++++++++++++++++++++++++-------------
>  net/sunrpc/xprtrdma/xprt_rdma.h |   61 +++
>  5 files changed, 601 insertions(+), 298 deletions(-)
> 
> --
> Chuck Lever
> 

