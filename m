From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH 08/14] nfsd4: fail when delegreturn gets a non-delegation
 stateid
Date: Wed, 11 Mar 2009 09:52:22 +0800
Message-ID: <49B71956.5030305@cn.fujitsu.com>
References: <1236731222-3294-1-git-send-email-bfields@fieldses.org> <1236731222-3294-2-git-send-email-bfields@fieldses.org> <1236731222-3294-3-git-send-email-bfields@fieldses.org> <1236731222-3294-4-git-send-email-bfields@fieldses.org> <1236731222-3294-5-git-send-email-bfields@fieldses.org> <1236731222-3294-6-git-send-email-bfields@fieldses.org> <1236731222-3294-7-git-send-email-bfields@fieldses.org> <1236731222-3294-8-git-send-email-bfields@fieldses.org> <1236731222-3294-9-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53776 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754279AbZCKBx3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Mar 2009 21:53:29 -0400
In-Reply-To: <1236731222-3294-9-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
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

this should be done in patch 7?

>  	if (is_delegation_stateid(stateid))
>  		goto out;

confused!
if (is_delegation_stateid(stateid)) means a stateid is for a delegation right?
Are we prefered if (!(is_delegation_stateid(stateid)))?

>  	status = nfserr_bad_stateid;


-- 
Regards
Yang Hongyang
