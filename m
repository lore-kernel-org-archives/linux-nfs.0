Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44354 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751197AbaDRJKf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Apr 2014 05:10:35 -0400
Date: Fri, 18 Apr 2014 05:10:33 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: set timeparms.to_maxval in setup_callback_client
Message-ID: <20140418091033.GA18612@fieldses.org>
References: <1397566308-16871-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397566308-16871-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 15, 2014 at 08:51:48AM -0400, Jeff Layton wrote:
> ...otherwise the logic in the timeout handling doesn't work correctly.
> 
> Spotted-by: Trond Myklebust <trond.myklebust@primarydata.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Thanks, queueing up for 3.15 and stable.

--b.

> ---
>  fs/nfsd/nfs4callback.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index 39c8ef875f91..2c73cae9899d 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -654,9 +654,11 @@ static struct rpc_clnt *create_backchannel_client(struct rpc_create_args *args)
>  
>  static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *conn, struct nfsd4_session *ses)
>  {
> +	int maxtime = max_cb_time(clp->net);
>  	struct rpc_timeout	timeparms = {
> -		.to_initval	= max_cb_time(clp->net),
> +		.to_initval	= maxtime,
>  		.to_retries	= 0,
> +		.to_maxval	= maxtime,
>  	};
>  	struct rpc_create_args args = {
>  		.net		= clp->net,
> -- 
> 1.9.0
> 
