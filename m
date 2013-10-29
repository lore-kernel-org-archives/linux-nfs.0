Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46899 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753264Ab3J2OrA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Oct 2013 10:47:00 -0400
Date: Tue, 29 Oct 2013 10:46:58 -0400
To: Benny Halevy <bhalevy@primarydata.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/7] nfsd4: fix recall_lock use in unhash_delegation
Message-ID: <20131029144658.GR31322@fieldses.org>
References: <526F81DE.6060704@primarydata.com>
 <1383039544-27157-1-git-send-email-bhalevy@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1383039544-27157-1-git-send-email-bhalevy@primarydata.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 29, 2013 at 11:39:04AM +0200, Benny Halevy wrote:
> Access to dp->dl_perclnt must be synchronized by the recall_lock

Are you sure?  recall_lock is for stuff that's needed in the delegation
break callback (nfsd_break_deleg_cb() and any of the subsequent callback
handling).  I don't think that includes dl_perclnt.

--b.

> 
> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index a90949a..a403502 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -436,8 +436,8 @@ static void unhash_stid(struct nfs4_stid *s)
>  static void
>  unhash_delegation(struct nfs4_delegation *dp)
>  {
> -	list_del_init(&dp->dl_perclnt);
>  	spin_lock(&recall_lock);
> +	list_del_init(&dp->dl_perclnt);
>  	list_del_init(&dp->dl_perfile);
>  	list_del_init(&dp->dl_recall_lru);
>  	spin_unlock(&recall_lock);
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
