Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6166 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756860Ab0HDCmO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Aug 2010 22:42:14 -0400
Subject: Re: [PATCH 0/4] nfsrdma: Miscellanseous Bug Fixes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Tom Tucker <tom@ogc.us>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, swise@ogc.us
In-Reply-To: <20100803164411.2567.31416.stgit@build.ogc.int>
References: <20100803164411.2567.31416.stgit@build.ogc.int>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 03 Aug 2010 22:42:02 -0400
Message-ID: <1280889722.24669.31.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-08-03 at 11:44 -0500, Tom Tucker wrote:
> The following series fixes a number of bugs in the NFSRDMA transport.
> 
> ---
> 
> Steve Wise (1):
>       xprtrdma: Do not truncate iova_start values in frmr registrations.
> 
> Tom Tucker (3):
>       rpcrdma: Fix SQ size calculation when memreg is FRMR
>       svcrdma: Cleanup DMA unmapping in error paths.
>       svcrdma: Change DMA mapping logic to avoid the page_address kernel API
> 
> 
>  net/sunrpc/xprtrdma/rpc_rdma.c           |    2 +
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   19 ++++---
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   82 ++++++++++++++++++++++--------
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   41 +++++++--------
>  net/sunrpc/xprtrdma/verbs.c              |   22 ++++++--
>  5 files changed, 111 insertions(+), 55 deletions(-)

Hi Tom,

How do you want to split these patches? The first one looks definitely
like a client bug, and the next 2 look like server bugs, but what about
the last patch?

Cheers
  Trond
