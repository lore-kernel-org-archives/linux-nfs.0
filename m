Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:49264 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934AbbJXSlL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Oct 2015 14:41:11 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [GIT PULL] Please pull NFSoRDMA changes for 4.4
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <562A9C42.7030506@Netapp.com>
Date: Sat, 24 Oct 2015 14:41:00 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>
Message-Id: <914C310D-238E-4646-891F-7680492D440C@oracle.com>
References: <562A9C42.7030506@Netapp.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Oct 23, 2015, at 4:44 PM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
> 
> Hi Trond,
> 
> The following changes since commit 7379047d5585187d1288486d4627873170d0005a:
> 
>  Linux 4.3-rc6 (2015-10-18 16:08:42 -0700)
> 
> are available in the git repository at:
> 
>  git://git.linux-nfs.org/projects/anna/nfs-rdma.git tags/nfs-rdma-4.4
> 
> for you to fetch changes up to 50add18fd4c82cc1eaedc6ce879d998a66f20e1f:
> 
>  NFS: Enable client side NFSv4.1 backchannel to use other transports (2015-10-19 14:48:18 -0400)

Anna, did you already send Steve Wise’s fix for 4.4?

http://marc.info/?l=linux-nfs&m=144285627709672&w=2


> Thanks,
> Anna
> 
> ----------------------------------------------------------------
> Chuck Lever (16):
>      xprtrdma: Enable swap-on-NFS/RDMA
>      xprtrdma: Re-arm after missed events
>      xprtrdma: Prevent loss of completion signals
>      xprtrdma: Refactor reply handler error handling
>      xprtrdma: Replace send and receive arrays
>      xprtrdma: Use workqueue to process RPC/RDMA replies
>      xprtrdma: Remove reply tasklet
>      xprtrdma: Saving IRQs no longer needed for rb_lock
>      SUNRPC: Abstract backchannel operations
>      xprtrdma: Pre-allocate backward rpc_rqst and send/receive buffers
>      xprtrdma: Pre-allocate Work Requests for backchannel
>      xprtrdma: Add support for sending backward direction RPC replies
>      xprtrdma: Handle incoming backward direction RPC calls
>      svcrdma: Add backward direction service for RPC/RDMA transport
>      SUNRPC: Remove the TCP-only restriction in bc_svc_process()
>      NFS: Enable client side NFSv4.1 backchannel to use other transports
> 
> fs/nfs/callback.c                        |  33 +++++++++------
> include/linux/sunrpc/bc_xprt.h           |   5 +++
> include/linux/sunrpc/svc_rdma.h          |   6 ++-
> include/linux/sunrpc/xprt.h              |   7 ++++
> net/sunrpc/backchannel_rqst.c            |  24 ++++++++++-
> net/sunrpc/svc.c                         |   5 ---
> net/sunrpc/xprtrdma/Makefile             |   1 +
> net/sunrpc/xprtrdma/backchannel.c        | 373 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> net/sunrpc/xprtrdma/rpc_rdma.c           | 148 +++++++++++++++++++++++++++++++++++++++++++++--------------------
> net/sunrpc/xprtrdma/svc_rdma.c           |   6 +++
> net/sunrpc/xprtrdma/svc_rdma_transport.c |  58 ++++++++++++++++++++++++++
> net/sunrpc/xprtrdma/transport.c          |  18 +++++++-
> net/sunrpc/xprtrdma/verbs.c              | 479 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---------------------------------------------------------------------------------------------------------
> net/sunrpc/xprtrdma/xprt_rdma.h          |  53 +++++++++++++++++++-----
> net/sunrpc/xprtsock.c                    |  16 ++++++++
> 15 files changed, 916 insertions(+), 316 deletions(-)
> create mode 100644 net/sunrpc/xprtrdma/backchannel.c
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

—
Chuck Lever



