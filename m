Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35105 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752957AbbGOUrs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jul 2015 16:47:48 -0400
Date: Wed, 15 Jul 2015 16:47:48 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 02/14] nfsd: Add missing gen_confirm in
 nfsd4_setclientid()
Message-ID: <20150715204748.GA21669@fieldses.org>
References: <55A384B1.8030207@gmail.com>
 <55A38505.6040405@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55A38505.6040405@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 13, 2015 at 05:29:41PM +0800, Kinglong Mee wrote:
> Commit 294ac32e99 "nfsd: protect clid and verifier generation with client_lock"
> have moved gen_confirm() to gen_clid().

This means the statement in that earlier commit is wrong:

	
	With this, there's no need to keep two counters as they'd always
	be in sync anyway, so just use the clientid_counter for both.

Looks to me like this may need a separate counter to eliminate the
possibibility of returning the same confirm twice for a one clientid?

--b.

> 
> After it, setclientid will return a bad reply with all zero confirms
> after copy_clid().
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4state.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index e0a4556..b1f84fc 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3042,10 +3042,11 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	unconf = find_unconfirmed_client_by_name(&clname, nn);
>  	if (unconf)
>  		unhash_client_locked(unconf);
> -	if (conf && same_verf(&conf->cl_verifier, &clverifier))
> +	if (conf && same_verf(&conf->cl_verifier, &clverifier)) {
>  		/* case 1: probable callback update */
>  		copy_clid(new, conf);
> -	else /* case 4 (new client) or cases 2, 3 (client reboot): */
> +		gen_confirm(new, nn);
> +	} else /* case 4 (new client) or cases 2, 3 (client reboot): */
>  		gen_clid(new, nn);
>  	new->cl_minorversion = 0;
>  	gen_callback(new, setclid, rqstp);
> -- 
> 2.4.3
