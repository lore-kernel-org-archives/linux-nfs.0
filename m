Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:50464 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755173Ab0DEOza (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Apr 2010 10:55:30 -0400
Message-ID: <4BB9F9D0.1040203@oracle.com>
Date: Mon, 05 Apr 2010 10:55:12 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: Tom Tucker <tom@ogc.us>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Wise <swise@opengridcomputing.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH] svcrdma: RDMA support not yet compatible with RPC6
References: <4BB74241.4060308@ogc.us>
In-Reply-To: <4BB74241.4060308@ogc.us>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 04/03/2010 09:27 AM, Tom Tucker wrote:
> RPC6 requires that it be possible to create endpoints that listen
> exclusively for IPv4 or IPv6 connection requests. This is not currently
> supported by the RDMA API.
>
> Signed-off-by: Tom Tucker<tom@opengridcomputing.com>
> Tested-by: Steve Wise<swise@opengridcomputing.com>

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

> ---
>
> net/sunrpc/xprtrdma/svc_rdma_transport.c | 5 ++++-
> 1 files changed, 4 insertions(+), 1 deletions(-)
>
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index 3fa5751..4e6bbf9 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -678,7 +678,10 @@ static struct svc_xprt *svc_rdma_create(struct
> svc_serv *serv,
> int ret;
>
> dprintk("svcrdma: Creating RDMA socket\n");
> -
> + if (sa->sa_family != AF_INET) {
> + dprintk("svcrdma: Address family %d is not supported.\n", sa->sa_family);
> + return ERR_PTR(-EAFNOSUPPORT);
> + }
> cma_xprt = rdma_create_xprt(serv, 1);
> if (!cma_xprt)
> return ERR_PTR(-ENOMEM);
>


-- 
chuck[dot]lever[at]oracle[dot]com
