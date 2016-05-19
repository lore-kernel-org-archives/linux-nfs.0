Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46561 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750946AbcESFTk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 May 2016 01:19:40 -0400
Message-ID: <1463635176.3017.75.camel@redhat.com>
Subject: Re: [Libtirpc-devel] [PATCH] Do not hold clnt_fd_lock mutex during
 connect
From: Ian Kent <ikent@redhat.com>
To: Paulo Andrade <paulo.cesar.pereira.de.andrade@gmail.com>,
        libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org, Paulo Andrade <pcpa@gnu.org>
Date: Thu, 19 May 2016 13:19:36 +0800
In-Reply-To: <1463594091-1289-1-git-send-email-pcpa@gnu.org>
References: <1463594091-1289-1-git-send-email-pcpa@gnu.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-05-18 at 14:54 -0300, Paulo Andrade wrote:
>   An user  reports  that  their  application  connects to  multiple  servers
> through a rpc interface using  libtirpc. When one of  the servers misbehaves
> (goes down  ungracefully or  has a  delay of  a few  seconds in  the traffic
> flow), it was observed that the traffic from the  client to other servers is
> decreased by  the  traffic  anomaly  of  the failing  server,  i.e.  traffic
> decreases or goes to 0 in all the servers.
> 
>   When investigated further, specifically into the behavior  of the libtirpc
> at the  time of  the issue,  it  was observed  that all  of the  application
> threads specifically interacting with  libtirpc were locked into  one single
> lock inside  the  libtirpc library.  This  was a  race  condition which  had
> resulted in a deadlock and hence the resultant dip/stoppage of traffic.
> 
>   As an experiment, the user removed the libtirpc from the application build
> and used the  standard glibc  library for rpc  communication. In  that case,
> everything worked perfectly even  in the time  of the issue of  server nodes
> misbehaving.
> 
> Signed-off-by: Paulo Andrade <pcpa@gnu.org>
> ---
>  src/clnt_vc.c | 8 ++------
>  1 file changed, 2 insertions(+), 6 deletions(-)
> 
> diff --git a/src/clnt_vc.c b/src/clnt_vc.c
> index a72f9f7..2396f34 100644
> --- a/src/clnt_vc.c
> +++ b/src/clnt_vc.c
> @@ -229,27 +229,23 @@ clnt_vc_create(fd, raddr, prog, vers, sendsz, recvsz)
>  	} else
>  		assert(vc_cv != (cond_t *) NULL);
>  
> -	/*
> -	 * XXX - fvdl connecting while holding a mutex?
> -	 */
> +	mutex_unlock(&clnt_fd_lock);
> +
>  	slen = sizeof ss;
>  	if (getpeername(fd, (struct sockaddr *)&ss, &slen) < 0) {
>  		if (errno != ENOTCONN) {
>  			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
>  			rpc_createerr.cf_error.re_errno = errno;
> -			mutex_unlock(&clnt_fd_lock);
>  			thr_sigsetmask(SIG_SETMASK, &(mask), NULL);
>  			goto err;
>  		}

Oh, right, the mutex is probably needed to ensure that errno is reliable.

>  		if (connect(fd, (struct sockaddr *)raddr->buf, raddr->len) <
> 0){

But this is probably where the caller is blocking so a small variation of this
patch should achieve the required result.

btw, I had a quick look at some of the other code and so far it looks like they
lead to clnt_tp_create() or clnt_dg_create() calls.

clnt_dg_create() is not connection oriented so it doesn't have the same mutex
lock problem.

So this patch might be all that's needed.

Ian
