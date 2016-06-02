Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60290 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752365AbcFBOum (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Jun 2016 10:50:42 -0400
Subject: Re: [Libtirpc-devel] [PATCH 1/3] Make it clear rpc_createerr is
 thread safe
To: Paulo Andrade <paulo.cesar.pereira.de.andrade@gmail.com>,
        libtirpc-devel@lists.sourceforge.net
References: <1463593885-1179-1-git-send-email-pcpa@gnu.org>
 <1463672110-10026-1-git-send-email-pcpa@gnu.org>
 <1463672110-10026-2-git-send-email-pcpa@gnu.org>
Cc: linux-nfs@vger.kernel.org, Paulo Andrade <pcpa@gnu.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <84940ee5-ca5b-c07b-521e-9a89c98fdf93@RedHat.com>
Date: Thu, 2 Jun 2016 10:50:40 -0400
MIME-Version: 1.0
In-Reply-To: <1463672110-10026-2-git-send-email-pcpa@gnu.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/19/2016 11:35 AM, Paulo Andrade wrote:
>   Avoid hidding it under a macro, and also avoid multiple function
> calls when accessing structure fields.
> 
> Signed-off-by: Paulo Andrade <pcpa@gnu.org>
Committed... 

steved.

> ---
>  src/clnt_vc.c | 17 +++++++++++------
>  1 file changed, 11 insertions(+), 6 deletions(-)
> 
> diff --git a/src/clnt_vc.c b/src/clnt_vc.c
> index a72f9f7..8af7ddd 100644
> --- a/src/clnt_vc.c
> +++ b/src/clnt_vc.c
> @@ -72,6 +72,8 @@
>  #define CMGROUP_MAX    16
>  #define SCM_CREDS      0x03            /* process creds (struct cmsgcred) */
>  
> +#undef rpc_createerr                   /* make it clear it is a thread safe variable */
> +
>  /*
>   * Credentials structure, used to verify the identity of a peer
>   * process that has sent us a message. This is allocated by the
> @@ -188,10 +190,11 @@ clnt_vc_create(fd, raddr, prog, vers, sendsz, recvsz)
>  	cl = (CLIENT *)mem_alloc(sizeof (*cl));
>  	ct = (struct ct_data *)mem_alloc(sizeof (*ct));
>  	if ((cl == (CLIENT *)NULL) || (ct == (struct ct_data *)NULL)) {
> +		struct rpc_createerr *ce = &get_rpc_createerr();
>  		(void) syslog(LOG_ERR, clnt_vc_errstr,
>  		    clnt_vc_str, __no_mem_str);
> -		rpc_createerr.cf_stat = RPC_SYSTEMERROR;
> -		rpc_createerr.cf_error.re_errno = errno;
> +		ce->cf_stat = RPC_SYSTEMERROR;
> +		ce->cf_error.re_errno = errno;
>  		goto err;
>  	}
>  	ct->ct_addr.buf = NULL;
> @@ -235,15 +238,17 @@ clnt_vc_create(fd, raddr, prog, vers, sendsz, recvsz)
>  	slen = sizeof ss;
>  	if (getpeername(fd, (struct sockaddr *)&ss, &slen) < 0) {
>  		if (errno != ENOTCONN) {
> -			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
> -			rpc_createerr.cf_error.re_errno = errno;
> +			struct rpc_createerr *ce = &get_rpc_createerr();
> +			ce->cf_stat = RPC_SYSTEMERROR;
> +			ce->cf_error.re_errno = errno;
>  			mutex_unlock(&clnt_fd_lock);
>  			thr_sigsetmask(SIG_SETMASK, &(mask), NULL);
>  			goto err;
>  		}
>  		if (connect(fd, (struct sockaddr *)raddr->buf, raddr->len) < 0){
> -			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
> -			rpc_createerr.cf_error.re_errno = errno;
> +			struct rpc_createerr *ce = &get_rpc_createerr();
> +			ce->cf_stat = RPC_SYSTEMERROR;
> +			ce->cf_error.re_errno = errno;
>  			mutex_unlock(&clnt_fd_lock);
>  			thr_sigsetmask(SIG_SETMASK, &(mask), NULL);
>  			goto err;
> 
