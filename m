Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40190 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753334AbcETCAm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 May 2016 22:00:42 -0400
Message-ID: <1463709636.3034.55.camel@redhat.com>
Subject: Re: [Libtirpc-devel] [PATCH 3/3] Do not hold a global mutex during
 connect
From: Ian Kent <ikent@redhat.com>
To: Paulo Andrade <paulo.cesar.pereira.de.andrade@gmail.com>,
        libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org, Paulo Andrade <pcpa@gnu.org>
Date: Fri, 20 May 2016 10:00:36 +0800
In-Reply-To: <1463672110-10026-4-git-send-email-pcpa@gnu.org>
References: <1463593885-1179-1-git-send-email-pcpa@gnu.org>
	 <1463672110-10026-1-git-send-email-pcpa@gnu.org>
	 <1463672110-10026-4-git-send-email-pcpa@gnu.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-05-19 at 12:35 -0300, Paulo Andrade wrote:
>   A multi-threaded application, connecting to multiple rpc servers,
> may dead lock if the connect call stalls on a non responsive server.

It's occurred to me that the mutex may be held over the connect(2) call to
prevent concurrent calls to connect(2) using the same fd.

That's a race and is a lot harder to deal with.

Comments, thoughts anyone?

I guess it's time to have a look at the connect(2) source ....

> 
> Signed-off-by: Paulo Andrade <pcpa@gnu.org>
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
