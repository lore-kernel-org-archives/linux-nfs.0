From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 3/3] SUNRPC: Clearer error message when user space is
 running portmap
Date: Tue, 13 Jan 2009 12:44:00 -0500
Message-ID: <1231868640.7036.11.camel@heimdal.trondhjem.org>
References: <20090113172538.6755.83766.stgit@ingres.1015granger.net>
	 <20090113173156.6755.86231.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:59353 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751952AbZAMRoK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Jan 2009 12:44:10 -0500
In-Reply-To: <20090113173156.6755.86231.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-01-13 at 12:31 -0500, Chuck Lever wrote:
> Detect the case where we sent an rpcbind v4 SET but user space doesn't
> support rpcbind protocol version 4.
> 
> When registering an AF_INET service, a warning is sent to the log once,
> and we down-shift to version 2.  With AF_INET6, an error is always sent
> to the log, and the registration fails.
> 
> This should help distributors and testers determine why their NFSD
> service won't start, but normal users/admins should really never see
> this message unless something very strange has happened.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  net/sunrpc/svc.c |   44 ++++++++++++++++++++++++++++++++++++++------
>  1 files changed, 38 insertions(+), 6 deletions(-)
> 
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index e93bc55..daed77f 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -736,6 +736,18 @@ static void __svc_rpcb_prog_mismatch_error(void)
>  	}
>  }
>  
> +static int __svc_rpcb_cant_register(const char *progname, const u32 version)
> +{
> +	printk(KERN_ERR
> +		"svc: Could not register an IPv6 listener for %s v%u "
> +		"with the local portmapper.\n"
> +		"svc: The kernel tried an rpcbind version 4 request, "
> +		"but your portmapper\n"
> +		"svc: does not support rpcbind version 4.",
> +		progname, version);
> +	return -EAFNOSUPPORT;
> +}

This is ___way___ too intrusive...

We already have stuff like the NFSv4 callback channel that automatically
assumes that it should use an IPv6 registration as long as CONFIG_IPV6
or CONFIG_IPV6_MODULE are defined.

Compiling in IPv6 without having an IPv6-capable portmapper should
certainly not be flagged as a kernel error.

>  /*
>   * Register an "inet" protocol family netid with the local
>   * rpcbind daemon via an rpcbind v4 SET request.
> @@ -811,10 +823,14 @@ static int __svc_rpcb_register6(const u32 program, const u32 version,
>  /*
>   * Register a kernel RPC service via rpcbind version 4.
>   *
> + * This logic is complicated by the case where user space is not
> + * running a portmapper that can handle a verison 4 request.
> + *
>   * Returns zero on success; a negative errno value is returned
>   * if any error occurs.
>   */
> -static int __svc_register(const u32 program, const u32 version,
> +static int __svc_register(const char *progname,
> +			  const u32 program, const u32 version,
>  			  const sa_family_t family,
>  			  const unsigned short protocol,
>  			  const unsigned short port)
> @@ -823,11 +839,25 @@ static int __svc_register(const u32 program, const u32 version,
>  
>  	switch (family) {
>  	case AF_INET:
> -		return __svc_rpcb_register4(program, version,
> -						protocol, port);
> +		if (__svc_register_version == 4) {
> +			error = __svc_rpcb_register4(program, version,
> +							protocol, port);
> +			if (error != -EPROTONOSUPPORT)
> +				return error;
> +		}
> +
> +		/* Down-shift. */
> +		__svc_rpcb_prog_mismatch_error();
> +		return rpcb_register(program, version, protocol, port);
>  	case AF_INET6:
> +		/* This won't work if we don't have version 4. */
> +		if (__svc_register_version != 4)
> +			return __svc_rpcb_cant_register(progname, version);
> +
>  		error = __svc_rpcb_register6(program, version,
>  						protocol, port);
> +		if (error == -EPROTONOSUPPORT)
> +			return __svc_rpcb_cant_register(progname, version);
>  		if (error < 0)
>  			return error;
>  
> @@ -854,7 +884,8 @@ static int __svc_register(const u32 program, const u32 version,
>   * Returns zero on success; a negative errno value is returned
>   * if any error occurs.
>   */
> -static int __svc_register(const u32 program, const u32 version,
> +static int __svc_register(const char *progname,
> +			  const u32 program, const u32 version,
>  			  sa_family_t family,
>  			  const unsigned short protocol,
>  			  const unsigned short port)
> @@ -901,8 +932,9 @@ int svc_register(const struct svc_serv *serv, const unsigned short proto,
>  			if (progp->pg_vers[i]->vs_hidden)
>  				continue;
>  
> -			error = __svc_register(progp->pg_prog, i,
> -						serv->sv_family, proto, port);
> +			error = __svc_register(progp->pg_name, progp->pg_prog,
> +						i, serv->sv_family,
> +						proto, port);
>  			if (error < 0)
>  				break;
>  		}
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

