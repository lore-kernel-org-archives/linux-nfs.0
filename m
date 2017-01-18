Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46416 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751231AbdARWU6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 18 Jan 2017 17:20:58 -0500
Date: Wed, 18 Jan 2017 17:20:28 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] SUNRPC: Make sure authorize svc when meeting SVC_CLOSE
Message-ID: <20170118222028.GB4272@fieldses.org>
References: <090f6673-1bb3-d626-e27e-6be5afcda782@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <090f6673-1bb3-d626-e27e-6be5afcda782@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 16, 2017 at 08:23:37AM +0800, Kinglong Mee wrote:
> Commit 4d712ef1db05 "svcauth_gss: Close connection when
>  dropping an incoming message" will close connection,
> but forget authorizing the svc when meeting SVC_CLOSE.
> 
> That, there will be an module reference to sunrpc,
> and some memory leak.
> 
> When mounting an nfs filesystem, the reference leak increase one.

Thanks, applying for 4.10.

(I'm not too happy with this function--e.g. it'd be easier to avoid this
sort of bug if we had a single unavoidable common exit that always
called svc_authenticate.

But I'm not sure of the best cleanup on a quick look.  And this is a
simple bugfix.  Maybe we could add some cleanup on top for 4.11.)

--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  net/sunrpc/svc.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index 75f290b..63ca2ea 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -1155,6 +1155,11 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
>  	case SVC_DENIED:
>  		goto err_bad_auth;
>  	case SVC_CLOSE:
> +		/*
> +		 * Makesure authorise svc if progp->pg_authenticate fail,
> +		 * it's harmless if svc_authenticate fail.
> +		 */
> +		svc_authorise(rqstp);
>  		goto close;
>  	case SVC_DROP:
>  		goto dropit;
> -- 
> 2.9.3
