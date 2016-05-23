Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:35663 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752335AbcEWOG1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2016 10:06:27 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] svcrpc: autoload rdma module
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20160520154814.GG2119@fieldses.org>
Date: Mon, 23 May 2016 10:06:23 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <425CCD8C-1661-4B77-92CD-EC393665238B@oracle.com>
References: <20160520154814.GG2119@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On May 20, 2016, at 11:48 AM, bfields@fieldses.org wrote:
> 
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> This should fix failures like:
> 
> 	# rpc.nfsd --rdma
> 	rpc.nfsd: Unable to request RDMA services: Protocol not supported
> 
> Reported-by: Steve Dickson <steved@redhat.com>
> Tested-by: Steve Dickson <steved@redhat.com>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> ---
> net/sunrpc/svc_xprt.c | 23 +++++++++++++++++++----
> 1 file changed, 19 insertions(+), 4 deletions(-)
> 
> I'm intending to apply this for 4.7.
> 
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 7422f28818b2..f5572e31d518 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -244,13 +244,12 @@ void svc_add_new_perm_xprt(struct svc_serv *serv, struct svc_xprt *new)
> 	svc_xprt_received(new);
> }
> 
> -int svc_create_xprt(struct svc_serv *serv, const char *xprt_name,
> +int _svc_create_xprt(struct svc_serv *serv, const char *xprt_name,
> 		    struct net *net, const int family,
> 		    const unsigned short port, int flags)
> {
> 	struct svc_xprt_class *xcl;
> 
> -	dprintk("svc: creating transport %s[%d]\n", xprt_name, port);
> 	spin_lock(&svc_xprt_class_lock);
> 	list_for_each_entry(xcl, &svc_xprt_class_list, xcl_list) {
> 		struct svc_xprt *newxprt;
> @@ -274,12 +273,28 @@ int svc_create_xprt(struct svc_serv *serv, const char *xprt_name,
> 	}
>  err:
> 	spin_unlock(&svc_xprt_class_lock);
> -	dprintk("svc: transport %s not found\n", xprt_name);
> -
> 	/* This errno is exposed to user space.  Provide a reasonable
> 	 * perror msg for a bad transport. */
> 	return -EPROTONOSUPPORT;
> }
> +
> +int svc_create_xprt(struct svc_serv *serv, const char *xprt_name,
> +		    struct net *net, const int family,
> +		    const unsigned short port, int flags)
> +{
> +	int err;
> +
> +	dprintk("svc: creating transport %s[%d]\n", xprt_name, port);
> +	err = _svc_create_xprt(serv, xprt_name, net, family, port, flags);
> +	if (err == -EPROTONOSUPPORT) {
> +		request_module("svc%s", xprt_name);
> +		err = _svc_create_xprt(serv, xprt_name, net, family, port, flags);
> +	}
> +	if (err)
> +		dprintk("svc: transport %s not found, err %d\n",
> +			xprt_name, err);
> +	return err;
> +}
> EXPORT_SYMBOL_GPL(svc_create_xprt);
> 
> /*
> -- 
> 2.5.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



