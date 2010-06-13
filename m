From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/3] nfsd: don't try to shut down nfs4 state handling
	unless it's up
Date: Sun, 13 Jun 2010 16:28:42 -0400
Message-ID: <20100613202842.GA14132@fieldses.org>
References: <1275924800-5214-1-git-send-email-jlayton@redhat.com> <1275924800-5214-2-git-send-email-jlayton@redhat.com> <20100608235828.GK26435@fieldses.org> <20100609062922.4bae21ac@corrin.poochiereds.net> <20100609180907.GB10953@fieldses.org> <20100609142943.60d31a11@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43867 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753430Ab0FMU2o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Jun 2010 16:28:44 -0400
In-Reply-To: <20100609142943.60d31a11-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 09, 2010 at 02:29:43PM -0400, Jeff Layton wrote:
> Ahh ok, I see what you're talking about now. Yeah, that should probably
> also be fixed. I think we just need to ensure to shut down the state in
> an error condition. Something like this compile-tested only patch?
> 
> From 19bd25ea9a76ea184e4c30831765e812ce19b0a5 Mon Sep 17 00:00:00 2001
> From: Jeff Layton <jlayton@redhat.com>
> Date: Wed, 9 Jun 2010 14:21:51 -0400
> Subject: [PATCH] nfsd: shut down NFSv4 state when nfsd_svc encounters an error
> 
> Currently, it's left up in some situations. That could cause the grace
> period to be shorter than it should be (along with other problems).

The patch looks right to me, thanks.

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfsd/nfssvc.c |   11 +++++++----
>  1 files changed, 7 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index 06b2a26..a06ea99 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -402,9 +402,9 @@ nfsd_svc(unsigned short port, int nrservs)
>  	nfsd_reset_versions();
>  
>  	error = nfsd_create_serv();
> -
>  	if (error)
> -		goto out;
> +		goto shutdown_state;
> +
>  	error = nfsd_init_socks(port);
>  	if (error)
>  		goto failure;
> @@ -416,9 +416,12 @@ nfsd_svc(unsigned short port, int nrservs)
>  		 * so subtract 1
>  		 */
>  		error = nfsd_serv->sv_nrthreads - 1;
> - failure:
> +failure:
>  	svc_destroy(nfsd_serv);		/* Release server */
> - out:
> +shutdown_state:
> +	if (error < 0)
> +		nfs4_state_shutdown();
> +out:
>  	mutex_unlock(&nfsd_mutex);
>  	return error;
>  }
> -- 
> 1.5.5.6
> 
