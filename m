From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH 3/5] nfsd41: reclaim DRC memory on session free
Date: Thu, 16 Jul 2009 10:18:05 -0400
Message-ID: <20090716141805.GD30477@fieldses.org>
References: <1245872278-18743-1-git-send-email-andros@netapp.com> <1245872278-18743-2-git-send-email-andros@netapp.com> <1245872278-18743-3-git-send-email-andros@netapp.com> <1245872278-18743-4-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46103 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757212AbZGPOSG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jul 2009 10:18:06 -0400
In-Reply-To: <1245872278-18743-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 24, 2009 at 03:37:47PM -0400, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfsd/nfs4state.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index b4a536d..991c3cc 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -583,6 +583,9 @@ free_session(struct kref *kref)
>  		struct nfsd4_cache_entry *e = &ses->se_slots[i].sl_cache_entry;
>  		nfsd4_release_respages(e->ce_respages, e->ce_resused);
>  	}
> +	spin_lock(&nfsd_drc_lock);
> +	nfsd_drc_mem_used -= ses->se_fchannel.maxreqs * NFSD_SLOT_CACHE_SIZE;
> +	spin_unlock(&nfsd_drc_lock);
>  	kfree(ses);

This patch has to be combined with the previous one.

--b.

>  }
>  
> -- 
> 1.5.4.3
> 
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
