Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34940 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751863AbbGOPDL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jul 2015 11:03:11 -0400
Date: Wed, 15 Jul 2015 11:03:11 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 01/14] nfsd: Add layouts checking for state resources
Message-ID: <20150715150311.GA19616@fieldses.org>
References: <55A384B1.8030207@gmail.com>
 <55A384DD.1000800@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55A384DD.1000800@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 13, 2015 at 05:29:01PM +0800, Kinglong Mee wrote:
> Layout is a state resource, nfsd should check it too.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4state.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 61dfb33..e0a4556 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2241,6 +2241,7 @@ static bool client_has_state(struct nfs4_client *clp)
>  	 * Also note we should probably be using this in 4.0 case too.
>  	 */
>  	return !list_empty(&clp->cl_openowners)
> +		|| !list_empty(&clp->cl_lo_states)
>  		|| !list_empty(&clp->cl_delegations)
>  		|| !list_empty(&clp->cl_sessions);
>  }
> @@ -4257,8 +4258,9 @@ nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		goto out;
>  	clp = cstate->clp;
>  	status = nfserr_cb_path_down;
> -	if (!list_empty(&clp->cl_delegations)
> -			&& clp->cl_cb_state != NFSD4_CB_UP)
> +	if ((!list_empty(&clp->cl_delegations)
> +	     || !list_empty(&clp->cl_lo_states))

nfsd4_renew is NFSv4.0 only, so I don't think this part is necessary.

That said, it's harmless--why don't we just call client_has_state() here
instead?

--b.

> +	    && clp->cl_cb_state != NFSD4_CB_UP)
>  		goto out;
>  	status = nfs_ok;
>  out:
> -- 
> 2.4.3
