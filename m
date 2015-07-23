Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:35953 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751154AbbGWBQk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jul 2015 21:16:40 -0400
Received: by pdjr16 with SMTP id r16so149958873pdj.3
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2015 18:16:39 -0700 (PDT)
Message-ID: <55B0406B.7010009@gmail.com>
Date: Thu, 23 Jul 2015 09:16:27 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: kinglongmee@gmail.com
Subject: Re: [PATCH 02/14] nfsd: Add missing gen_confirm in nfsd4_setclientid()
References: <55A384B1.8030207@gmail.com> <55A38505.6040405@gmail.com>
In-Reply-To: <55A38505.6040405@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This one needs be applied with
"nfsd: New counter for generating client confirm verifier"
that is only update client confirm verifier without fix this problem.

thanks,
Kinglong Mee

On 7/13/2015 17:29, Kinglong Mee wrote:
> Commit 294ac32e99 "nfsd: protect clid and verifier generation with client_lock"
> have moved gen_confirm() to gen_clid().
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
> 
