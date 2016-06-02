Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38453 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752911AbcFBOvZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Jun 2016 10:51:25 -0400
Subject: Re: [Libtirpc-devel] [PATCH 3/3] Do not hold a global mutex during
 connect
To: Paulo Andrade <paulo.cesar.pereira.de.andrade@gmail.com>,
        libtirpc-devel@lists.sourceforge.net
References: <1463593885-1179-1-git-send-email-pcpa@gnu.org>
 <1463672110-10026-1-git-send-email-pcpa@gnu.org>
 <1463672110-10026-4-git-send-email-pcpa@gnu.org>
Cc: linux-nfs@vger.kernel.org, Paulo Andrade <pcpa@gnu.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <42ceb376-1853-5ad6-2fa4-8022de48776e@RedHat.com>
Date: Thu, 2 Jun 2016 10:51:23 -0400
MIME-Version: 1.0
In-Reply-To: <1463672110-10026-4-git-send-email-pcpa@gnu.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/19/2016 11:35 AM, Paulo Andrade wrote:
>   A multi-threaded application, connecting to multiple rpc servers,
> may dead lock if the connect call stalls on a non responsive server.
> 
> Signed-off-by: Paulo Andrade <pcpa@gnu.org>
committed... 

steved.
> ---
>  src/clnt_vc.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/src/clnt_vc.c b/src/clnt_vc.c
> index 0da18ca..0f018d5 100644
> --- a/src/clnt_vc.c
> +++ b/src/clnt_vc.c
> @@ -233,15 +233,16 @@ clnt_vc_create(fd, raddr, prog, vers, sendsz, recvsz)
>  		assert(vc_cv != (cond_t *) NULL);
>  
>  	/*
> -	 * XXX - fvdl connecting while holding a mutex?
> +	 * Do not hold mutex during connect
>  	 */
> +	mutex_unlock(&clnt_fd_lock);
> +
>  	slen = sizeof ss;
>  	if (getpeername(fd, (struct sockaddr *)&ss, &slen) < 0) {
>  		if (errno != ENOTCONN) {
>  			struct rpc_createerr *ce = &get_rpc_createerr();
>  			ce->cf_stat = RPC_SYSTEMERROR;
>  			ce->cf_error.re_errno = errno;
> -			mutex_unlock(&clnt_fd_lock);
>  			thr_sigsetmask(SIG_SETMASK, &(mask), NULL);
>  			goto err;
>  		}
> @@ -249,12 +250,10 @@ clnt_vc_create(fd, raddr, prog, vers, sendsz, recvsz)
>  			struct rpc_createerr *ce = &get_rpc_createerr();
>  			ce->cf_stat = RPC_SYSTEMERROR;
>  			ce->cf_error.re_errno = errno;
> -			mutex_unlock(&clnt_fd_lock);
>  			thr_sigsetmask(SIG_SETMASK, &(mask), NULL);
>  			goto err;
>  		}
>  	}
> -	mutex_unlock(&clnt_fd_lock);
>  	if (!__rpc_fd2sockinfo(fd, &si))
>  		goto err;
>  	thr_sigsetmask(SIG_SETMASK, &(mask), NULL);
> 
