From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] SUNRPC: IS_ERR/PTR_ERR confusion
Date: Mon, 7 Dec 2009 10:26:54 -0500
Message-ID: <20091207152654.GA29416@fieldses.org>
References: <4B1CE844.1040108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Roel Kluin <roel.kluin@gmail.com>
To: Trond Myklebust <trond@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:32896 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935289AbZLGP0t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2009 10:26:49 -0500
In-Reply-To: <4B1CE844.1040108@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 07, 2009 at 12:34:28PM +0100, Roel Kluin wrote:
> IS_ERR returns 1 or 0, PTR_ERR returns the error value.

Whoops, thanks, looks like that was my mistake, from
79a3f20b641f9f93787ada49d1d7cfa98ee5a11e "rpc: use count of pipe openers
to wait for first open".

--b.

> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
>  net/sunrpc/auth_gss/auth_gss.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index fc6a43c..129d75e 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -485,7 +485,7 @@ gss_refresh_upcall(struct rpc_task *task)
>  	dprintk("RPC: %5u gss_refresh_upcall for uid %u\n", task->tk_pid,
>  								cred->cr_uid);
>  	gss_msg = gss_setup_upcall(task->tk_client, gss_auth, cred);
> -	if (IS_ERR(gss_msg) == -EAGAIN) {
> +	if (PTR_ERR(gss_msg) == -EAGAIN) {
>  		/* XXX: warning on the first, under the assumption we
>  		 * shouldn't normally hit this case on a refresh. */
>  		warn_gssd();
