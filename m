Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:53513 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752755AbbBYWxE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Feb 2015 17:53:04 -0500
Date: Wed, 25 Feb 2015 17:53:02 -0500
To: Andrew Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org, Eric Meddaugh <etmsys@rit.edu>
Subject: Re: [PATCH] NFS: fix clp->cl_revoked list deletion causing softlock
 in nfsd
Message-ID: <20150225225302.GA20495@fieldses.org>
Reply-To: 1424871775-98137-1-git-send-email-aweits@rit.edu
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying for 3.20.

--b.

> commit 2d4a532d385f ("nfsd: ensure that clp->cl_revoked list is
> protected by clp->cl_lock") removed the use of the reaplist to
> clean out clp->cl_revoked. It failed to change list_entry() to
> walk clp->cl_revoked.next instead of reaplist.next
> 
> Fixes: 2d4a532d385f ("nfsd: ensure that clp->cl_revoked list is protected by clp->cl_lock")
> Cc: stable@vger.kernel.org
> Reported-by: Eric Meddaugh <etmsys@rit.edu>
> Tested-by: Eric Meddaugh <etmsys@rit.edu>
> Signed-off-by: Andrew Elble <aweits@rit.edu>
> ---
>  fs/nfsd/nfs4state.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index f6b2a09f793f..d2f2c37dc2db 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1638,7 +1638,7 @@ __destroy_client(struct nfs4_client *clp)
>  		nfs4_put_stid(&dp->dl_stid);
>  	}
>  	while (!list_empty(&clp->cl_revoked)) {
> -		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
> +		dp = list_entry(clp->cl_revoked.next, struct nfs4_delegation, dl_recall_lru);
>  		list_del_init(&dp->dl_recall_lru);
>  		nfs4_put_stid(&dp->dl_stid);
>  	}
> -- 
> 2.2.1
