Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:48799 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751798AbcHHNuD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Aug 2016 09:50:03 -0400
Subject: Re: [PATCH] sunrpc: Remove unnecessary variable
To: Amitoj Kaur Chawla <amitoj1606@gmail.com>, <bfields@fieldses.org>,
        <jlayton@poochiereds.net>, <trond.myklebust@primarydata.com>,
        <davem@davemloft.net>, <linux-nfs@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
References: <20160808091349.GA20849@amitoj-Inspiron-3542>
CC: <julia.lawall@lip6.fr>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <8822c3be-56c1-d9ac-7f7d-164804322083@Netapp.com>
Date: Mon, 8 Aug 2016 09:49:56 -0400
MIME-Version: 1.0
In-Reply-To: <20160808091349.GA20849@amitoj-Inspiron-3542>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/08/2016 05:13 AM, Amitoj Kaur Chawla wrote:
> The variable `err` is not used anywhere and just returns the
> predefined value `0` at the end of the function. Hence, remove the
> variable and return 0 explicitly.

Makes sense to me.  Thanks!

Anna

> 
> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
> ---
>  net/sunrpc/clnt.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index b7f2104..0a775fa 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -184,7 +184,6 @@ static int __rpc_clnt_handle_event(struct rpc_clnt *clnt, unsigned long event,
>  				   struct super_block *sb)
>  {
>  	struct dentry *dentry;
> -	int err = 0;
>  
>  	switch (event) {
>  	case RPC_PIPEFS_MOUNT:
> @@ -201,7 +200,7 @@ static int __rpc_clnt_handle_event(struct rpc_clnt *clnt, unsigned long event,
>  		printk(KERN_ERR "%s: unknown event: %ld\n", __func__, event);
>  		return -ENOTSUPP;
>  	}
> -	return err;
> +	return 0;
>  }
>  
>  static int __rpc_pipefs_event(struct rpc_clnt *clnt, unsigned long event,
> 

