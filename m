Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46871 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933905AbaFQU5k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jun 2014 16:57:40 -0400
Date: Tue, 17 Jun 2014 16:57:39 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: fix bug for readdir of pseudofs
Message-ID: <20140617205739.GB6168@fieldses.org>
References: <539AC53A.9070600@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <539AC53A.9070600@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 13, 2014 at 05:32:42PM +0800, Kinglong Mee wrote:
> Commit 561f0ed498ca (nfsd4: allow large readdirs) introduces a bug
> about readdir the root of pseudofs.
> 
> Call xdr_truncate_encode() revert encoded name when skipping.

Thanks for the fix!  Applying for 3.16.

--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4xdr.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 53ca43c..30913c8 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -2687,6 +2687,7 @@ nfsd4_encode_dirent(void *ccdv, const char *name, int namlen,
>  		nfserr = nfserr_toosmall;
>  		goto fail;
>  	case nfserr_noent:
> +		xdr_truncate_encode(xdr, start_offset);
>  		goto skip_entry;
>  	default:
>  		/*
> -- 
> 1.9.3
> 
