Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59293 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758785AbbGHVaP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Jul 2015 17:30:15 -0400
Date: Wed, 8 Jul 2015 17:30:15 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/5] nfsd: Fix a file leak of ls_file if
 nfsd4_layout_setlease fail
Message-ID: <20150708213015.GG19084@fieldses.org>
References: <559672B7.4010802@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <559672B7.4010802@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 03, 2015 at 07:32:07PM +0800, Kinglong Mee wrote:
> If nfsd4_layout_setlease fail, nfsd will not put ls->ls_file.
> 
> Fix commit c5c707f96f "nfsd: implement pNFS layout recalls".
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4layouts.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
> index 6904213..367a65a 100644
> --- a/fs/nfsd/nfs4layouts.c
> +++ b/fs/nfsd/nfs4layouts.c
> @@ -212,8 +212,7 @@ nfsd4_alloc_layout_stateid(struct nfsd4_compound_state *cstate,
>  	BUG_ON(!ls->ls_file);
>  
>  	if (nfsd4_layout_setlease(ls)) {
> -		put_nfs4_file(fp);
> -		kmem_cache_free(nfs4_layout_stateid_cache, ls);
> +		nfs4_put_stid(stp);

Hm, is the stateid really completely enough set up that this is safe?

Looking at nfsd4_free_layout_stateid.... OK, the unnecessary lease
unlock and tracepoint are a bit ugly bug I guess we can live with those.

--b.

>  		return NULL;
>  	}
>  
> -- 
> 2.4.3
