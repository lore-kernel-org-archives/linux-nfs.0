Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33971 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755102AbcCQImR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Mar 2016 04:42:17 -0400
Received: by mail-wm0-f66.google.com with SMTP id p65so13529131wmp.1
        for <linux-nfs@vger.kernel.org>; Thu, 17 Mar 2016 01:42:16 -0700 (PDT)
Date: Thu, 17 Mar 2016 10:42:10 +0200
From: Leon Romanovsky <leon@leon.nu>
To: Shirley Ma <shirley.ma@oracle.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Chuck Lever <Chuck.Lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>
Subject: Re: [PATCH v2] svcrdma: add IPv6 support
Message-ID: <20160317084210.GE25216@leon.nu>
Reply-To: leon@leon.nu
References: <56E9A8DD.8030308@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <56E9A8DD.8030308@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 16, 2016 at 11:41:33AM -0700, Shirley Ma wrote:
> Add rdma6 option to support NFS/RDMA IPv6.
> Allow both IPv4 and IPv6 to bind same port at the same time,
> restricts use of the IPv6 socket to IPv6 communication.
> 
> Changes from v1:
> - Check rdma_set_afonly return value (suggested by Leon Romanovsky)

Looks good to me.
Acked-by: Leon Romanovsky <leonro@mellanox.com>

Thanks.

> 
> Signed-off-by: Shirley Ma <shirley.ma@oracle.com>
> ---
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -869,7 +869,7 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
>  	int ret;
>  
>  	dprintk("svcrdma: Creating RDMA socket\n");
> -	if (sa->sa_family != AF_INET) {
> +	if ((sa->sa_family != AF_INET) && (sa->sa_family != AF_INET6)) {

>  		dprintk("svcrdma: Address family %d is not supported.\n", sa->sa_family);
>  		return ERR_PTR(-EAFNOSUPPORT);
>  	}
> @@ -885,6 +885,16 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
>  		goto err0;
>  	}
>  
> +	/* Allow both IPv4 and IPv6 sockets to bind a single port
> +	 * at the same time.
> +	 */
> +#if IS_ENABLED(CONFIG_IPV6)
> +	ret = rdma_set_afonly(listen_id, 1);
> +	if (ret) {
> +		dprintk("svcrdma: rdma_set_afonly failed = %d\n", ret);
> +		goto err1;
> +	}
> +#endif
>  	ret = rdma_bind_addr(listen_id, sa);
>  	if (ret) {
>  		dprintk("svcrdma: rdma_bind_addr failed = %d\n", ret);
