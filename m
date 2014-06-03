Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f176.google.com ([209.85.220.176]:36805 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933863AbaFCVi5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Jun 2014 17:38:57 -0400
Received: by mail-vc0-f176.google.com with SMTP id im17so383452vcb.35
        for <linux-nfs@vger.kernel.org>; Tue, 03 Jun 2014 14:38:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <538E35AB.3000108@netapp.com>
References: <538E35AB.3000108@netapp.com>
Date: Tue, 3 Jun 2014 17:38:56 -0400
Message-ID: <CAHQdGtT=3wo+dCeKVQjejdKxZqaFKF2X0bpFxnEpQBK6cmcSeQ@mail.gmail.com>
Subject: Re: [GIT PULL v2] Please pull NFS client RDMA changes for 3.16
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: "linux >> linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 3, 2014 at 4:52 PM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> Hey Trond,
>
> The following changes since commit cc6d854967ce8c7be9c9b6c1c9719604b36b925a:
>
>   Linux 3.15-rc8 (2014-06-03 13:56:29 -0400)
>
> are available in the git repository at:
>
>   git://git.linux-nfs.org/projects/anna/nfs-rdma.git tags/nfs-rdma-3.16
>
> for you to fetch changes up to d2c1c87ff96ac3cd85f75aa826ceef1f12d4a21d:
>
>   xprtrdma: Disconnect on registration failure (2014-06-03 15:45:40 -0400)
>
> This pull request fixes the process-related bugs from earlier this afternoon:
> - Signed-off-by lines have been added
> - A signed tag has been created
>
> There are no changes to the actual code.
>

Thanks! Pulled now...

> Anna
>
> ----------------------------------------------------------------
> NFS: Client side changes for RDMA
>
> These patches are mostly cleanups and bugfixes for using RDMA as an
> over-the-wire transport.
>
> Highlights include:
>
> - Remove obsolete memory registration modes.
> - Removing BUG_ON()s to keep client's running.
> - Fix deadlocks, NULL-pointer dereferences, and memory leaks.
>
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
>
> ----------------------------------------------------------------
> Allen Andrews (1):
>       nfs-rdma: Fix for FMR leaks
>
> Chuck Lever (21):
>       xprtrdma: RPC/RDMA must invoke xprt_wake_pending_tasks() in process context
>       xprtrdma: Remove BOUNCEBUFFERS memory registration mode
>       xprtrdma: Remove MEMWINDOWS registration modes
>       xprtrdma: Remove REGISTER memory registration mode
>       xprtrdma: Fall back to MTHCAFMR when FRMR is not supported
>       xprtrdma: mount reports "Invalid mount option" if memreg mode not supported
>       xprtrdma: Simplify rpcrdma_deregister_external() synopsis
>       xprtrdma: Make rpcrdma_ep_destroy() return void
>       xprtrdma: Split the completion queue
>       xprtrmda: Reduce lock contention in completion handlers
>       xprtrmda: Reduce calls to ib_poll_cq() in completion handlers
>       xprtrdma: Limit work done by completion handler
>       xprtrdma: Reduce the number of hardway buffer allocations
>       xprtrdma: Ensure ia->ri_id->qp is not NULL when reconnecting
>       xprtrdma: Remove Tavor MTU setting
>       xprtrdma: Use macros for reconnection timeout constants
>       xprtrdma: Reset connection timeout after successful reconnect
>       SUNRPC: Move congestion window constants to header file
>       xprtrdma: Avoid deadlock when credit window is reset
>       xprtrdma: Remove BUG_ON() call sites
>       xprtrdma: Disconnect on registration failure
>
> Shirley Ma (1):
>       xprtrdma: Allocate missing pagelist
>
> Steve Wise (1):
>       xprtrdma: mind the device's max fast register page list depth
>
>  include/linux/sunrpc/xprt.h     |   6 ++
>  net/sunrpc/xprt.c               |  28 +++------
>  net/sunrpc/xprtrdma/rpc_rdma.c  | 119 +++++++++++++++++---------------------
>  net/sunrpc/xprtrdma/transport.c |  90 ++++++++++-------------------
>  net/sunrpc/xprtrdma/verbs.c     | 753 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++----------------------------------------------------------------------------------------------------------------------------------------------
>  net/sunrpc/xprtrdma/xprt_rdma.h |  17 ++++--
>  6 files changed, 411 insertions(+), 602 deletions(-)



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
