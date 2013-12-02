Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37230 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751432Ab3LBO7S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Dec 2013 09:59:18 -0500
Date: Mon, 2 Dec 2013 09:59:17 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Do not enter setup_callback_client when finding
 backchannel failed
Message-ID: <20131202145917.GF1960@fieldses.org>
References: <5295C982.1030904@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5295C982.1030904@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 27, 2013 at 06:29:22PM +0800, Kinglong Mee wrote:
> If finding backchannel failed, nfsd should not enter setup_callback_client.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4callback.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index 7f05cd1..755d6d6 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -664,7 +664,7 @@ static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *c
>  		args.authflavor = clp->cl_cred.cr_flavor;
>  		clp->cl_cb_ident = conn->cb_ident;
>  	} else {
> -		if (!conn->cb_xprt)
> +		if (!conn->cb_xprt || !ses)

It looks to me like ses should be set whenenver conn is.  Do you have
reason to believe the contrary?

>  			return -EINVAL;
>  		clp->cl_cb_conn.cb_xprt = conn->cb_xprt;
>  		clp->cl_cb_session = ses;
> @@ -982,7 +982,7 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
>  	}
>  	spin_unlock(&clp->cl_lock);
>  
> -	err = setup_callback_client(clp, &conn, ses);
> +	err = c ? setup_callback_client(clp, &conn, ses) : -ENOENT;

But, whoops, yes, this looks like a good fix.  (Have you hit this
failure in practice?)  But I think we should probably adopt the sort of
control flow that's more idiomatic in the kernel:

	c = __nfsd4_find_backchannel(clp)
	if (!c)
		goto out_unlock;
	...
	spin_unlock(&clp->cl_lock);
	err = setup_callback_client(clp, &conn, ses);
	if (err)
		goto out_err;

etc.

--b.

>  	if (err) {
>  		nfsd4_mark_cb_down(clp, err);
>  		return;
> -- 
> 1.8.4.2
