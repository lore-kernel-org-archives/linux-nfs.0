Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59215 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755439AbbGHSob (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Jul 2015 14:44:31 -0400
Date: Wed, 8 Jul 2015 14:44:31 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/3] nfsd: Set lc_size_chg before ops->proc_layoutcommit
Message-ID: <20150708184431.GB19084@fieldses.org>
References: <559B3573.4090307@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <559B3573.4090307@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 07, 2015 at 10:12:03AM +0800, Kinglong Mee wrote:
> After proc_layoutcommit success, i_size_read(inode) always >= new_size.
> Just set lc_size_chg before proc_layoutcommit, if proc_layoutcommit
> failed, nfsd will skip the lc_size_chg, so it's no harm.

Looks right to me, though could probably use an ACK from Christoph.

(But looking at the spec I'm confused about how the client is supposed
to use this information.)

--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4proc.c | 6 +-----
>  1 file changed, 1 insertion(+), 5 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 90cfda7..d112c8a 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1364,10 +1364,6 @@ nfsd4_layoutcommit(struct svc_rqst *rqstp,
>  		goto out;
>  	}
>  
> -	nfserr = ops->proc_layoutcommit(inode, lcp);
> -	if (nfserr)
> -		goto out_put_stid;
> -
>  	if (new_size > i_size_read(inode)) {
>  		lcp->lc_size_chg = 1;
>  		lcp->lc_newsize = new_size;
> @@ -1375,7 +1371,7 @@ nfsd4_layoutcommit(struct svc_rqst *rqstp,
>  		lcp->lc_size_chg = 0;
>  	}
>  
> -out_put_stid:
> +	nfserr = ops->proc_layoutcommit(inode, lcp);
>  	nfs4_put_stid(&ls->ls_stid);
>  out:
>  	return nfserr;
> -- 
> 2.4.3
