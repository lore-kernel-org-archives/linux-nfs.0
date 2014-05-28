Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:39311 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217AbaE1XPs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 May 2014 19:15:48 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Subject: Re: [PATCH v5 00/24] Series short description
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20140528142521.23214.39655.stgit@manet.1015granger.net>
Date: Wed, 28 May 2014 19:15:44 -0400
Cc: Anna.Schumaker@netapp.com
Message-Id: <B50B248D-901F-41FE-B6B1-A99A6F22E1CC@oracle.com>
References: <20140528142521.23214.39655.stgit@manet.1015granger.net>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Test results:

On May 28, 2014, at 10:31 AM, Chuck Lever <chuck.lever@oracle.com> wrote:

> Updates since v4:
> 
> - Rebased on v3.15-rc7
> - Addressed Trond's review comment in "Reset connection timeout..."
> - Wake up RPC tasks only when cwnd is growing in "Avoid deadlock when..."
> - Fix patch description of "Remove MEMWINDOWS registration modes"
> 
> Pull from the "nfs-rdma-client" branch of my git repo:
> 
>  git://git.linux-nfs.org/projects/cel/cel-2.6.git

Client:
v3.15-rc7 with my 24 patches applied.
ConnectX-2 adapter (mlx4)

Server:
Solaris 11.2 beta
ConnectX-2 adapter

Server:
stock Linux v3.15-rc7
InfiniHost III adapter (mthca)



Connectathon tests: “./server -a -N30” with NFSv3 and NFSv4 against
Solaris and Linux servers. All passed. No hangs, stalls, or crashes.

Client tested in FRMR, FMR, and PHYSICAL memory registration modes.

With Linux server, added “rsize=32768” mount option for PHYSICAL.

With Solaris server, added “rsize=131072,wsize=65536” mount options
for PHYSICAL.



xfstests: “sudo ./check -nfs” with NFSv3 and NFSv4 against Linux
server. Test failure rate same as over TCP. No hangs, stalls, or
crashes.

Client ran in FRMR, FMR, and PHYSICAL memory registration modes.
PHYSICAL registration added “rsize=32768” mount option



> ---
> 
> Allen Andrews (1):
>      nfs-rdma: Fix for FMR leaks
> 
> Chuck Lever (21):
>      xprtrdma: Disconnect on registration failure
>      xprtrdma: Remove BUG_ON() call sites
>      xprtrdma: Avoid deadlock when credit window is reset
>      SUNRPC: Move congestion window constants to header file
>      xprtrdma: Reset connection timeout after successful reconnect
>      xprtrdma: Use macros for reconnection timeout constants
>      xprtrdma: Remove Tavor MTU setting
>      xprtrdma: Ensure ia->ri_id->qp is not NULL when reconnecting
>      xprtrdma: Reduce the number of hardway buffer allocations
>      xprtrdma: Limit work done by completion handler
>      xprtrmda: Reduce calls to ib_poll_cq() in completion handlers
>      xprtrmda: Reduce lock contention in completion handlers
>      xprtrdma: Split the completion queue
>      xprtrdma: Make rpcrdma_ep_destroy() return void
>      xprtrdma: Simplify rpcrdma_deregister_external() synopsis
>      xprtrdma: mount reports "Invalid mount option" if memreg mode not supported
>      xprtrdma: Fall back to MTHCAFMR when FRMR is not supported
>      xprtrdma: Remove REGISTER memory registration mode
>      xprtrdma: Remove MEMWINDOWS registration modes
>      xprtrdma: Remove BOUNCEBUFFERS memory registration mode
>      xprtrdma: RPC/RDMA must invoke xprt_wake_pending_tasks() in process context
> 
> Shirley Ma (1):
>      xprtrdma: Allocate missing pagelist
> 
> Steve Wise (1):
>      xprtrdma: mind the device's max fast register page list depth
> 
> 
> include/linux/sunrpc/xprt.h     |    6 
> net/sunrpc/xprt.c               |   28 -
> net/sunrpc/xprtrdma/rpc_rdma.c  |  119 +++---
> net/sunrpc/xprtrdma/transport.c |   90 ++---
> net/sunrpc/xprtrdma/verbs.c     |  753 ++++++++++++++++-----------------------
> net/sunrpc/xprtrdma/xprt_rdma.h |   17 +
> 6 files changed, 411 insertions(+), 602 deletions(-)
> 
> -- 
> Chuck Lever
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



