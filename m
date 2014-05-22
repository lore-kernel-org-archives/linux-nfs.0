Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f54.google.com ([209.85.192.54]:57334 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260AbaEVCHF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 May 2014 22:07:05 -0400
MIME-Version: 1.0
In-Reply-To: <20140522005707.27190.2035.stgit@manet.1015granger.net>
References: <20140522004505.27190.58897.stgit@manet.1015granger.net>
	<20140522005707.27190.2035.stgit@manet.1015granger.net>
Date: Wed, 21 May 2014 22:07:03 -0400
Message-ID: <CAABAsM5m_CT7qUv4Xbm+LKoSZaia55APO3kgnt7Ti1x24gsrbg@mail.gmail.com>
Subject: Re: [PATCH v4 20/24] xprtrdma: Reset connection timeout after
 successful reconnect
From: Trond Myklebust <trondmy@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 21, 2014 at 8:57 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> If the new connection is able to make forward progress, reset the
> re-establish timeout. Otherwise it keeps growing even if disconnect
> events are rare.
>
> The same behavior as TCP is adopted: reconnect immediately if the
> transport instance has been able to make some forward progress.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>
>  net/sunrpc/xprtrdma/rpc_rdma.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
> index dc4a826..1334646 100644
> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
> @@ -770,6 +770,8 @@ repost:
>
>         /* from here on, the reply is no longer an orphan */
>         req->rl_reply = rep;
> +       if (xprt->reestablish_timeout)
> +               xprt->reestablish_timeout = 0;

What's the point of making this conditional?
