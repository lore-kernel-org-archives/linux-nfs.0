Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:50012 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933318AbbI1Oaq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Sep 2015 10:30:46 -0400
Subject: Re: [PATCH 1/3] xprtrdma: disconnect and flush cqs before freeing
 buffers
To: trond.myklebust@primarydata.com, bfields@fieldses.org
References: <20150921172423.9761.92399.stgit@build2.ogc.int>
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
From: Steve Wise <swise@opengridcomputing.com>
Message-ID: <56094F16.3040608@opengridcomputing.com>
Date: Mon, 28 Sep 2015 09:30:46 -0500
MIME-Version: 1.0
In-Reply-To: <20150921172423.9761.92399.stgit@build2.ogc.int>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 9/21/2015 12:24 PM, Steve Wise wrote:
> Otherwise a FRMR completion can cause a touch-after-free crash.
>
> In xprt_rdma_destroy(), call rpcrdma_buffer_destroy() only after calling
> rpcrdma_ep_destroy().
>
> In rpcrdma_ep_destroy(), disconnect the cm_id first which should flush the
> qp, then drain the cqs, then destroy the qp, and finally destroy the cqs.
>
> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
> Tested-by: Chuck Lever <chuck.lever@oracle.com>
> ---

Hey Trond,  I'm hoping this can make 4.3-rc (and stable if you agree).

Thanks,

Steve.

