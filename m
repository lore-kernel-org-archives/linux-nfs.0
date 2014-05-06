Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33590 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750857AbaEFXlm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2014 19:41:42 -0400
Date: Tue, 6 May 2014 19:41:36 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 11/70] NFSd: Ensure delegation setup is safe w.r.t.
 break_lease()
Message-ID: <20140506234136.GU18281@fieldses.org>
References: <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-8-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-11-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 18, 2014 at 02:44:05PM -0400, Trond Myklebust wrote:
> Ensure that we add/remove the dl_perfile under the inode->i_lock

Looks like maybe this addresses my question on the previous patch--in
which case it should really be merged with the previous patch for
bisectability?

--b.

> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 14 +++++++++++---
>  1 file changed, 11 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 85fcbc9ebd40..3656980b5d19 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -441,7 +441,9 @@ static void
>  hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
>  {
>  	dp->dl_stid.sc_type = NFS4_DELEG_STID;
> +	spin_lock(&fp->fi_inode->i_lock);
>  	list_add(&dp->dl_perfile, &fp->fi_delegations);
> +	spin_unlock(&fp->fi_inode->i_lock);
>  	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
>  }
>  
> @@ -449,13 +451,19 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
>  static void
>  unhash_delegation(struct nfs4_delegation *dp)
>  {
> +	struct nfs4_file *fp = dp->dl_file;
> +
>  	spin_lock(&state_lock);
>  	list_del_init(&dp->dl_perclnt);
> -	list_del_init(&dp->dl_perfile);
>  	list_del_init(&dp->dl_recall_lru);
> +	if (!list_empty(&dp->dl_perfile)) {
> +		spin_lock(&fp->fi_inode->i_lock);
> +		list_del_init(&dp->dl_perfile);
> +		spin_unlock(&fp->fi_inode->i_lock);
> +	}
>  	spin_unlock(&state_lock);
> -	nfs4_put_deleg_lease(dp->dl_file);
> -	put_nfs4_file(dp->dl_file);
> +	nfs4_put_deleg_lease(fp);
> +	put_nfs4_file(fp);
>  	dp->dl_file = NULL;
>  }
>  
> -- 
> 1.9.0
> 
