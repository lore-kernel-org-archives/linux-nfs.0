Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41971 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756443Ab2LGPFB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Dec 2012 10:05:01 -0500
Date: Fri, 7 Dec 2012 10:04:59 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, devel@openvz.org
Subject: Re: [PATCH] SUNRPC: remove redundant "linux/nsproxy.h" includes
Message-ID: <20121207150459.GH17115@fieldses.org>
References: <20121204121856.3029.355.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121204121856.3029.355.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 04, 2012 at 03:18:58PM +0300, Stanislav Kinsbursky wrote:
> This is a cleanup patch.

OK, applying.--b.

> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> ---
>  net/sunrpc/rpcb_clnt.c |    1 -
>  net/sunrpc/svc.c       |    1 -
>  2 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
> index a70acae..109a67a 100644
> --- a/net/sunrpc/rpcb_clnt.c
> +++ b/net/sunrpc/rpcb_clnt.c
> @@ -23,7 +23,6 @@
>  #include <linux/errno.h>
>  #include <linux/mutex.h>
>  #include <linux/slab.h>
> -#include <linux/nsproxy.h>
>  #include <net/ipv6.h>
>  
>  #include <linux/sunrpc/clnt.h>
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index be301e1..529400d 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -20,7 +20,6 @@
>  #include <linux/module.h>
>  #include <linux/kthread.h>
>  #include <linux/slab.h>
> -#include <linux/nsproxy.h>
>  
>  #include <linux/sunrpc/types.h>
>  #include <linux/sunrpc/xdr.h>
> 
