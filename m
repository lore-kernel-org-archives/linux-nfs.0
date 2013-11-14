Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58459 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753146Ab3KNOSG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Nov 2013 09:18:06 -0500
Date: Thu, 14 Nov 2013 09:18:03 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: export proper maximum file size to the client
Message-ID: <20131114141802.GA20733@fieldses.org>
References: <20131114135010.GA2869@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131114135010.GA2869@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 14, 2013 at 05:50:10AM -0800, Christoph Hellwig wrote:
> I noticed that we export a way to high value for the maxfilesize
> attribute when debugging a client issue.  The issue didn't turn
> out to be related to it, but I think we should export it, so that
> clients can limit what write sizes they accept before hitting
> the server.

Thanks, applying.--b.

>     
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 9423522..a3c9347 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -2488,7 +2488,7 @@ out_acl:
>  	if (bmval0 & FATTR4_WORD0_MAXFILESIZE) {
>  		if ((buflen -= 8) < 0)
>  			goto out_resource;
> -		WRITE64(~(u64)0);
> +		WRITE64(exp->ex_path.mnt->mnt_sb->s_maxbytes);
>  	}
>  	if (bmval0 & FATTR4_WORD0_MAXLINK) {
>  		if ((buflen -= 4) < 0)
