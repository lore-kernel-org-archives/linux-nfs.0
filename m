From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 08/14] nfsd4: fail when delegreturn gets a non-delegation
 stateid
Date: Wed, 11 Mar 2009 20:29:52 +0200
Message-ID: <49B80320.6080507@panasas.com>
References: <1236731222-3294-1-git-send-email-bfields@fieldses.org> <1236731222-3294-2-git-send-email-bfields@fieldses.org> <1236731222-3294-3-git-send-email-bfields@fieldses.org> <1236731222-3294-4-git-send-email-bfields@fieldses.org> <1236731222-3294-5-git-send-email-bfields@fieldses.org> <1236731222-3294-6-git-send-email-bfields@fieldses.org> <1236731222-3294-7-git-send-email-bfields@fieldses.org> <1236731222-3294-8-git-send-email-bfields@fieldses.org> <1236731222-3294-9-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:15919 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755366AbZCKS34 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Mar 2009 14:29:56 -0400
In-Reply-To: <1236731222-3294-9-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar. 11, 2009, 2:26 +0200, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> From: J. Bruce Fields <bfields@citi.umich.edu>
> 
> Previous cleanup reveals an obvious (though harmless) bug: when
> delegreturn gets a stateid that isn't for a delegation, it should return
> an error rather than doing nothing.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/nfsd/nfs4state.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index de1d68a..4a92d1e 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2418,7 +2418,7 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	status = nfserr_stale_stateid;
>  	if (STALE_STATEID(stateid)) 
>  		goto out;
> -	status = nfs_ok;
> +	status = nfserr_bad_stateid;
>  	if (is_delegation_stateid(stateid))
>  		goto out;
>  	status = nfserr_bad_stateid;

This assignment is redundant now, isn't it?

Benny
