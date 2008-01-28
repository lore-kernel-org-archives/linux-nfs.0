From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 036/100] lockd: fix reference count leaks in async locking case
Date: Mon, 28 Jan 2008 14:46:41 -0500
Message-ID: <CC70187B-9DB5-49EA-8905-51E8D15DC3B7@oracle.com>
References: <20080125231521.GG25141@fieldses.org> <1201303040-7779-1-git-send-email-bfields@citi.umich.edu> <1201303040-7779-2-git-send-email-bfields@citi.umich.edu> <1201303040-7779-3-git-send-email-bfields@citi.umich.edu> <1201303040-7779-4-git-send-email-bfields@citi.umich.edu> <1201303040-7779-5-git-send-email-bfields@citi.umich.edu> <1201303040-7779-6-git-send-email-bfields@citi.umich.edu> <1201303040-7779-7-git-send-email-bfields@citi.umich.edu> <1201303040-7779-8-git-send-email-bfields@citi.umich.edu> <1201303040-7779-9-git-send-email-bfields@citi.umich.edu> <1201303040-7779-10-git-send-email-bfields@citi.umich.edu> <1201303040-7779-11-git-send-email-bfields@citi.umich.edu> <1201303040-7779-12-git-send-email-bfields@citi.umich.edu> <1201303040-7779-13-git-send-email-bfields@citi.umi
 ch.edu> <1201303040-7779-14-git-send-email-bfields@citi.umich.edu> <1201303040-7779-15-git-send-email-bfields@citi.umich.edu> <1201303040-7779-16-git-send-email-bfields@citi.umich.edu> <120!
 1303040-7779-17-git-send-email-bfields@citi.umich.edu> <1201303040-7779-18-git-send-email-bfields@citi.umich.edu> <1201303040-7779-19-git-send-email-bfields@citi.umich.edu> <1201303040-7779-20-git-send-email-bfields@citi.umich.edu> <1201303040-7779-21-git-send-email-bfields@citi.umich.edu> <1201303040-7779-22-git-send-email-bfields@citi.umich.edu> <1201303040-7779-23-git-send-email-bfields@citi.umich.edu> <1201303040-7779-24-git-send-email-bfields@citi.umich.edu> <1201303040-7779-25-git-send-email-bfields@citi.umich.edu> <1201303040-7779-26-git-send-email-bfields@citi.umich.edu> <1201303040-7779-27-git-send-email-bfields@citi.umich.edu> <1201303040-7779-28-git-send-email-bfields@citi.umich.edu> <1201303040-7779-29-git-send-email-bfields@citi.umich.edu> <1201303040-7779-30-git-send-email-b
 fields@citi.umich.edu> <1201303040-7779-31-git-send-email-bfields@citi.umich.edu> <1201303040-7779-32-git-send-email-bfields@citi.umich.edu> <1201303040-7779-33-git-send-email-bfields@citi.!
 umich.edu> <1201303040-7779-34-git-send-email-bfields@citi.umi!
 ch.edu> <1201303040-7779-35-git-send-email-bfields@citi.umich.edu> <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green-SOTZviwpzew/JUsKyNonYw@public.gmane.org>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:10529 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604AbYA1TrM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2008 14:47:12 -0500
In-Reply-To: <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 25, 2008, at 6:16 PM, J. Bruce Fields wrote:
> From: Oleg Drokin <green-SOTZviwpzew/JUsKyNonYw@public.gmane.org>
>
> In a number of places where we wish only to translate  
> nlm_drop_reply to
> rpc_drop_reply errors we instead return early with rpc_drop_reply,
> skipping some important end-of-function cleanup.
>
> This results in reference count leaks when lockd is doing posix  
> locking
> on GFS2.

Is Oleg's Signed-off-by: missing?

> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/lockd/svc4proc.c |   20 ++++++++++++--------
>  fs/lockd/svcproc.c  |   22 +++++++++++++---------
>  2 files changed, 25 insertions(+), 17 deletions(-)

More below.

> diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
> index bf27b6c..225304d 100644
> --- a/fs/lockd/svc4proc.c
> +++ b/fs/lockd/svc4proc.c
> @@ -84,6 +84,7 @@ nlm4svc_proc_test(struct svc_rqst *rqstp, struct  
> nlm_args *argp,
>  {
>  	struct nlm_host	*host;
>  	struct nlm_file	*file;
> +	int rc = rpc_success;
>
>  	dprintk("lockd: TEST4        called\n");
>  	resp->cookie = argp->cookie;
> @@ -91,7 +92,7 @@ nlm4svc_proc_test(struct svc_rqst *rqstp, struct  
> nlm_args *argp,
>  	/* Don't accept test requests during grace period */
>  	if (nlmsvc_grace_period) {
>  		resp->status = nlm_lck_denied_grace_period;
> -		return rpc_success;
> +		return rc;
>  	}
>
>  	/* Obtain client and file */
> @@ -101,12 +102,13 @@ nlm4svc_proc_test(struct svc_rqst *rqstp,  
> struct nlm_args *argp,
>  	/* Now check for conflicting locks */
>  	resp->status = nlmsvc_testlock(rqstp, file, &argp->lock, &resp- 
> >lock, &resp->cookie);
>  	if (resp->status == nlm_drop_reply)
> -		return rpc_drop_reply;
> +		rc = rpc_drop_reply;
> +        else
> +                dprintk("lockd: TEST4        status %d\n", ntohl 
> (resp->status));

This appears to introduce some white space damage.

> -	dprintk("lockd: TEST4          status %d\n", ntohl(resp->status));
>  	nlm_release_host(host);
>  	nlm_release_file(file);
> -	return rpc_success;
> +	return rc;
>  }
>
>  static __be32
> @@ -115,6 +117,7 @@ nlm4svc_proc_lock(struct svc_rqst *rqstp,  
> struct nlm_args *argp,
>  {
>  	struct nlm_host	*host;
>  	struct nlm_file	*file;
> +	int rc = rpc_success;
>
>  	dprintk("lockd: LOCK          called\n");
>
> @@ -123,7 +126,7 @@ nlm4svc_proc_lock(struct svc_rqst *rqstp,  
> struct nlm_args *argp,
>  	/* Don't accept new lock requests during grace period */
>  	if (nlmsvc_grace_period && !argp->reclaim) {
>  		resp->status = nlm_lck_denied_grace_period;
> -		return rpc_success;
> +		return rc;
>  	}
>
>  	/* Obtain client and file */
> @@ -146,12 +149,13 @@ nlm4svc_proc_lock(struct svc_rqst *rqstp,  
> struct nlm_args *argp,
>  	resp->status = nlmsvc_lock(rqstp, file, &argp->lock,
>  					argp->block, &argp->cookie);
>  	if (resp->status == nlm_drop_reply)
> -		return rpc_drop_reply;
> +		rc = rpc_drop_reply;
> +        else
> +                dprintk("lockd: LOCK         status %d\n", ntohl 
> (resp->status));
>
> -	dprintk("lockd: LOCK          status %d\n", ntohl(resp->status));
>  	nlm_release_host(host);
>  	nlm_release_file(file);
> -	return rpc_success;
> +	return rc;
>  }
>
>  static __be32
> diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
> index 9cd5c8b..1a2b10c 100644
> --- a/fs/lockd/svcproc.c
> +++ b/fs/lockd/svcproc.c
> @@ -113,6 +113,7 @@ nlmsvc_proc_test(struct svc_rqst *rqstp, struct  
> nlm_args *argp,
>  {
>  	struct nlm_host	*host;
>  	struct nlm_file	*file;
> +	int rc = rpc_success;
>
>  	dprintk("lockd: TEST          called\n");
>  	resp->cookie = argp->cookie;
> @@ -120,7 +121,7 @@ nlmsvc_proc_test(struct svc_rqst *rqstp, struct  
> nlm_args *argp,
>  	/* Don't accept test requests during grace period */
>  	if (nlmsvc_grace_period) {
>  		resp->status = nlm_lck_denied_grace_period;
> -		return rpc_success;
> +		return rc;
>  	}
>
>  	/* Obtain client and file */
> @@ -130,13 +131,14 @@ nlmsvc_proc_test(struct svc_rqst *rqstp,  
> struct nlm_args *argp,
>  	/* Now check for conflicting locks */
>  	resp->status = cast_status(nlmsvc_testlock(rqstp, file, &argp- 
> >lock, &resp->lock, &resp->cookie));
>  	if (resp->status == nlm_drop_reply)
> -		return rpc_drop_reply;
> +		rc = rpc_drop_reply;
> +        else
> +                dprintk("lockd: TEST          status %d vers %d\n",
> +                        ntohl(resp->status), rqstp->rq_vers);

More white space damage here.

> -	dprintk("lockd: TEST          status %d vers %d\n",
> -		ntohl(resp->status), rqstp->rq_vers);
>  	nlm_release_host(host);
>  	nlm_release_file(file);
> -	return rpc_success;
> +	return rc;
>  }
>
>  static __be32
> @@ -145,6 +147,7 @@ nlmsvc_proc_lock(struct svc_rqst *rqstp, struct  
> nlm_args *argp,
>  {
>  	struct nlm_host	*host;
>  	struct nlm_file	*file;
> +	int rc = rpc_success;
>
>  	dprintk("lockd: LOCK          called\n");
>
> @@ -153,7 +156,7 @@ nlmsvc_proc_lock(struct svc_rqst *rqstp, struct  
> nlm_args *argp,
>  	/* Don't accept new lock requests during grace period */
>  	if (nlmsvc_grace_period && !argp->reclaim) {
>  		resp->status = nlm_lck_denied_grace_period;
> -		return rpc_success;
> +		return rc;
>  	}
>
>  	/* Obtain client and file */
> @@ -176,12 +179,13 @@ nlmsvc_proc_lock(struct svc_rqst *rqstp,  
> struct nlm_args *argp,
>  	resp->status = cast_status(nlmsvc_lock(rqstp, file, &argp->lock,
>  					       argp->block, &argp->cookie));
>  	if (resp->status == nlm_drop_reply)
> -		return rpc_drop_reply;
> +		rc = rpc_drop_reply;
> +        else
> +                dprintk("lockd: LOCK         status %d\n", ntohl 
> (resp->status));

And here.

> -	dprintk("lockd: LOCK          status %d\n", ntohl(resp->status));
>  	nlm_release_host(host);
>  	nlm_release_file(file);
> -	return rpc_success;
> +	return rc;
>  }
>
>  static __be32

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
