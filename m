Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:56595 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755317AbcIFTif (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Sep 2016 15:38:35 -0400
Subject: Re: [PATCH 0/2] NFS/RDMA bug fixes for v4.8-rc
To: Chuck Lever <chuck.lever@oracle.com>,
        <trond.myklebust@primarydata.com>
References: <20160906151843.4958.84689.stgit@manet.1015granger.net>
CC: <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <9c236d3c-dcf4-dd61-a017-b07c86193850@Netapp.com>
Date: Tue, 6 Sep 2016 15:38:32 -0400
MIME-Version: 1.0
In-Reply-To: <20160906151843.4958.84689.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

You can add my:  "Reviewed-by: Anna Schumaker <Anna.Schumaker@Netapp.com>" if you want to take these patches directly for the next bugfix pull request.

Thanks,
Anna

On 09/06/2016 11:22 AM, Chuck Lever wrote:
> Hi Anna, Trond-
> 
> Commit 3d4cf35bd4fa is wrong, as described in the patch description
> of the revert commit below. It was submitted for v4.8, but needs to
> be removed before v4.8 final, to avoid a regression.
> 
> The second patch below addresses the original problem that
> 3d4cf35bd4fa was attempting to fix.
> 
> Would you consider these for v4.8-rc ?
> 
> ---
> 
> Chuck Lever (2):
>       xprtrdma: Revert 3d4cf35bd4fa ("xprtrdma: Reply buffer exhaustion...")
>       xprtrdma: Fix receive buffer accounting
> 
> 
>  net/sunrpc/xprtrdma/verbs.c     |   45 ++++++++++++++++++++++++++++-----------
>  net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
>  2 files changed, 33 insertions(+), 13 deletions(-)
> 
> --
> Chuck Lever
> 

