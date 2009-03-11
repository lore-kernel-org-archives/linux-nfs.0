From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH 03/14] nfsd4: remove redundant "if" in nfs4_preprocess_stateid_op
Date: Wed, 11 Mar 2009 09:12:46 +0800
Message-ID: <49B7100E.2000209@cn.fujitsu.com>
References: <1236731222-3294-1-git-send-email-bfields@fieldses.org> <1236731222-3294-2-git-send-email-bfields@fieldses.org> <1236731222-3294-3-git-send-email-bfields@fieldses.org> <1236731222-3294-4-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52270 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752005AbZCKBN4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Mar 2009 21:13:56 -0400
In-Reply-To: <1236731222-3294-4-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> From: J. Bruce Fields <bfields@citi.umich.edu>
> 
> Note that we exit this first big "if" with stp == NULL iff we took the
                                                                                        ^^ typo
> first branch; therefore, the second "if" is redundant, and we can just
> combine the two, simplifying the logic.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/nfsd/nfs4state.c |   19 ++++++++-----------
>  1 files changed, 8 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index d6ca2be..16fcb65 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2087,6 +2087,14 @@ nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int fl
>  		status = check_stateid_generation(stateid, stidp);
>  		if (status)
>  			goto out;
> +		status = nfs4_check_delegmode(dp, flags);
> +		if (status)
> +			goto out;
> +		renew_client(dp->dl_client);
> +		if (flags & DELEG_RET)
> +			unhash_delegation(dp);
> +		if (filpp)
> +			*filpp = dp->dl_vfs_file;
>  	} else { /* open or lock stateid */
>  		stp = find_stateid(stateid, flags);
>  		if (!stp) {
> @@ -2101,23 +2109,12 @@ nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int fl
>  		status = check_stateid_generation(stateid, stidp);
>  		if (status)
>  			goto out;
> -	}
> -	if (stp) {
>  		status = nfs4_check_openmode(stp, flags);
>  		if (status)
>  			goto out;
>  		renew_client(stp->st_stateowner->so_client);
>  		if (filpp)
>  			*filpp = stp->st_vfs_file;
> -	} else {
> -		status = nfs4_check_delegmode(dp, flags);
> -		if (status)
> -			goto out;
> -		renew_client(dp->dl_client);
> -		if (flags & DELEG_RET)
> -			unhash_delegation(dp);
> -		if (filpp)
> -			*filpp = dp->dl_vfs_file;
>  	}
>  	status = nfs_ok;
>  out:


-- 
Regards
Yang Hongyang
