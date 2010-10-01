Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33675 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757197Ab0JAOtD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Oct 2010 10:49:03 -0400
Date: Fri, 1 Oct 2010 10:48:48 -0400
From: " J. Bruce Fields" <bfields@fieldses.org>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd41: mask out unsupported pnfs attributes
Message-ID: <20101001144847.GC17310@fieldses.org>
References: <1285872478-21045-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1285872478-21045-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 30, 2010 at 08:47:58PM +0200, Benny Halevy wrote:
> These attributes are valid in NFSv4.1, the just doesn't support them yet.

The existing code handles unsupported attributes in the operations
themselves.  Perhaps it makes sense to move those checks here, but if
so, explain why, and let's do this for all unsupported attributes, not
just these two.

Looking back at the spec....  I guess it's only on operations that set
attributes that we return NFS4ERR_ATTRNOTSUPP, and otherwise we silently
ignore them?

--b.

> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4xdr.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index f48d891..bd4ce68 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1761,6 +1761,10 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
>  		.dentry	= dentry,
>  	};
>  
> +	/* mask out unsupported pNFS attributes */
> +	bmval1 &= ~FATTR4_WORD1_FS_LAYOUT_TYPES;
> +	bmval2 &= ~FATTR4_WORD2_LAYOUT_BLKSIZE;
> +
>  	BUG_ON(bmval1 & NFSD_WRITEONLY_ATTRS_WORD1);
>  	BUG_ON(bmval0 & ~nfsd_suppattrs0(minorversion));
>  	BUG_ON(bmval1 & ~nfsd_suppattrs1(minorversion));
> -- 
> 1.7.2.3
> 
