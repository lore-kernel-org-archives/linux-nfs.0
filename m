From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/1] nfsd41: slots are freed with session
Date: Sun, 3 May 2009 14:45:45 -0400
Message-ID: <20090503184545.GC20762@fieldses.org>
References: <1241192033-4493-1-git-send-email-andros@netapp.com> <1241192033-4493-2-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:40071 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800AbZECSpp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 May 2009 14:45:45 -0400
In-Reply-To: <1241192033-4493-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 01, 2009 at 11:33:53AM -0400, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> The session and slots are allocated all in one piece.

Thanks, applied for 2.6.30.--b.

> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfsd/nfs4state.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index c65a27b..3b711f5 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -580,7 +580,6 @@ free_session(struct kref *kref)
>  		struct nfsd4_cache_entry *e = &ses->se_slots[i].sl_cache_entry;
>  		nfsd4_release_respages(e->ce_respages, e->ce_resused);
>  	}
> -	kfree(ses->se_slots);
>  	kfree(ses);
>  }
>  
> -- 
> 1.5.4.3
> 
