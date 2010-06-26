From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH] SQUASHME: pnfsd: setup backchannel in create_session
 also in session reestablishment
Date: Sat, 26 Jun 2010 11:24:42 -0400
Message-ID: <20100626152442.GB3432@fieldses.org>
References: <1276815696-19281-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bharrosh@panasas.com, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41924 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752705Ab0FZPYs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 26 Jun 2010 11:24:48 -0400
In-Reply-To: <1276815696-19281-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 17, 2010 at 07:01:36PM -0400, Benny Halevy wrote:
> The client may send an EXCHANGE_ID and a following CREATE_SESSION for an
> existing clientid.  In this case we'll find the nfs4_client in the confirmed
> list.

This changes callback information on a client after the client may
already have callbacks in progress.  I think there will be races.

I have a partial attempt at fixing this at:

	git://linux-nfs.org/~bfields/linux-topics.git callbacks

--b.

> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4state.c |   24 +++++++++++-------------
>  1 files changed, 11 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 3e012d4..0df5483 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1405,25 +1405,23 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  		if (is_ds_only_session(unconf->cl_exchange_flags))
>  			cr_ses->flags &= ~SESSION4_BACK_CHAN;
>  
> -		if (cr_ses->flags & SESSION4_BACK_CHAN) {
> -			unconf->cl_cb_conn.cb_xprt = rqstp->rq_xprt;
> -			svc_xprt_get(rqstp->rq_xprt);
> -			rpc_copy_addr(
> -				(struct sockaddr *)&unconf->cl_cb_conn.cb_addr,
> -				sa);
> -			unconf->cl_cb_conn.cb_addrlen = svc_addr_len(sa);
> -			unconf->cl_cb_conn.cb_minorversion =
> -				cstate->minorversion;
> -			unconf->cl_cb_conn.cb_prog = cr_ses->callback_prog;
> -			unconf->cl_cb_seq_nr = 1;
> -			nfsd4_probe_callback(unconf, &unconf->cl_cb_conn);
> -		}
>  		conf = unconf;
>  	} else {
>  		status = nfserr_stale_clientid;
>  		goto out;
>  	}
>  
> +	if (cr_ses->flags & SESSION4_BACK_CHAN) {
> +		conf->cl_cb_conn.cb_xprt = rqstp->rq_xprt;
> +		svc_xprt_get(rqstp->rq_xprt);
> +		rpc_copy_addr((struct sockaddr *)&conf->cl_cb_conn.cb_addr, sa);
> +		conf->cl_cb_conn.cb_addrlen = svc_addr_len(sa);
> +		conf->cl_cb_conn.cb_minorversion = cstate->minorversion;
> +		conf->cl_cb_conn.cb_prog = cr_ses->callback_prog;
> +		conf->cl_cb_seq_nr = 1;
> +		nfsd4_probe_callback(conf, &conf->cl_cb_conn);
> +	}
> +
>  	/*
>  	 * We do not support RDMA or persistent sessions
>  	 */
> -- 
> 1.6.4.4
