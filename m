Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:36333 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751852AbbCYK2i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Mar 2015 06:28:38 -0400
Received: by ykcn8 with SMTP id n8so10086383ykc.3
        for <linux-nfs@vger.kernel.org>; Wed, 25 Mar 2015 03:28:37 -0700 (PDT)
Date: Wed, 25 Mar 2015 06:28:33 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, trond.myklebust@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] nfsd: return correct openowner when there is a race
 to put one in the hash
Message-ID: <20150325062833.1f5ad592@tlielax.poochiereds.net>
In-Reply-To: <20150325084516.GC25682@infradead.org>
References: <1427122424-8078-1-git-send-email-jeff.layton@primarydata.com>
	<1427122424-8078-2-git-send-email-jeff.layton@primarydata.com>
	<20150325084516.GC25682@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 25 Mar 2015 01:45:16 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> Good catch!
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> 
> But maybe it's better to write the code so that the intent is obvious:
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index f6b2a09..3c4c3d2 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3215,11 +3215,13 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
>  	INIT_LIST_HEAD(&oo->oo_close_lru);
>  	spin_lock(&clp->cl_lock);
>  	ret = find_openstateowner_str_locked(strhashval, open, clp);
> -	if (ret == NULL) {
> -		hash_openowner(oo, clp, strhashval);
> -		ret = oo;
> -	} else
> +	if (ret) {
>  		nfs4_free_openowner(&oo->oo_owner);
> +		spin_unlock(&clp->cl_lock);
> +		return ret;
> +	}
> +
> +	hash_openowner(oo, clp, strhashval);
>  	spin_unlock(&clp->cl_lock);
>  	return oo;
>  }

Sure, that'd be fine too. Care to write up a changelog entry and send
it to Bruce? I think that would likely apply just fine to stable
kernels. 

-- 
Jeff Layton <jlayton@poochiereds.net>
