Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa11-10.prod.phx3.secureserver.net ([68.178.252.111]:55389
	"EHLO p3plsmtpa11-10.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753215AbbGNTAy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jul 2015 15:00:54 -0400
Message-ID: <55A55C63.50403@talpey.com>
Date: Tue, 14 Jul 2015 15:00:51 -0400
From: Tom Talpey <tom@talpey.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 07/14] xprtrdma: Remove logic that constructs RDMA_MSGP
 type calls
References: <20150713160617.17630.97475.stgit@manet.1015granger.net> <20150713163048.17630.86326.stgit@manet.1015granger.net>
In-Reply-To: <20150713163048.17630.86326.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/13/2015 12:30 PM, Chuck Lever wrote:
> RDMA_MSGP type calls insert a zero pad in the middle of the RPC
> message to align the RPC request's data payload to the server's
> alignment preferences. A server can then "page flip" the payload
> into place to avoid a data copy in certain circumstances. However:
>...
>
> Clean up the marshaling code by removing the logic that constructs
> RDMA_MSGP type calls. This also reduces the maximum send iovec size
> from four to just two elements.
>

> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index 8219011..0b50103 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
...>
> +#define RPCRDMA_MAX_IOVS	(4)
> +

So, shouldn't this constant be "2"? The extra 2 iov's were used
only for constructing the pad.



