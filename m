Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47374 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750899Ab2FEU14 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Jun 2012 16:27:56 -0400
Date: Tue, 5 Jun 2012 16:27:55 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Weston Andros Adamson <dros@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd: probe the back channel on new connections
Message-ID: <20120605202755.GB27061@fieldses.org>
References: <1337888537-21754-1-git-send-email-dros@netapp.com>
 <1337888537-21754-2-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1337888537-21754-2-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 24, 2012 at 03:42:17PM -0400, Weston Andros Adamson wrote:
> Initiate a CB probe when a new connection with the correct direction is added
> to a session (IFF backchannel is marked as down).  Without this a
> BIND_CONN_TO_SESSION has no effect on the internal backchannel state, which
> causes the server to reply to every SEQUENCE op with the
> SEQ4_STATUS_CB_PATH_DOWN flag set until DESTROY_SESSION.
> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
> Hey Bruce -
>  In an earlier thread I mentioned that I was setting the backchannel state to
> CB_UNKNOWN to clear the SEQ4_STATUS flag, but this was wrong - I don't believe
> it would ever change (to CB_UP/CB_DOWN).  This patch seems like the right way
> to handle the internal backchannel state.

Thanks, yes, this looks right, queueing up for 3.6.

> Also, I'm a bit confused as how we're supposed to maintain atomicity around
> cl_cb_state:
> 
> from nfs4callback.c:nfsd4_probe_callback():
>   /* XXX: atomicity?  Also, should we be using cl_flags? */
>   clp->cl_cb_state = NFSD4_CB_UNKNOWN;
> 
> and there are several places that check the value of cl_cb_state without holding
> a lock (as far as I can tell).

I think that's probably OK.

We set cl_cb_state to UNKNOWN only before initiating a callback that
will eventually result in setting it to UP, DOWN, or FAULT.

And I think that's good enough for the readers.

So probably that comment should just go.

--b.

> 
>  fs/nfsd/nfs4state.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 9afc902..99f092e 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -862,6 +862,11 @@ static __be32 nfsd4_new_conn(struct svc_rqst *rqstp, struct nfsd4_session *ses,
>  	if (ret)
>  		/* oops; xprt is already down: */
>  		nfsd4_conn_lost(&conn->cn_xpt_user);
> +	if (ses->se_client->cl_cb_state == NFSD4_CB_DOWN &&
> +		dir & NFS4_CDFC4_BACK) {
> +		/* callback channel may be back up */
> +		nfsd4_probe_callback(ses->se_client);
> +	}
>  	return nfs_ok;
>  }
>  
> -- 
> 1.7.4.4
> 
