Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52622 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753943AbaKJRy1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Nov 2014 12:54:27 -0500
Date: Mon, 10 Nov 2014 12:54:24 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd: implement chage_attr_type attribute
Message-ID: <20141110175424.GC32702@fieldses.org>
References: <1415448664-25815-1-git-send-email-hch@lst.de>
 <1415448664-25815-3-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1415448664-25815-3-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Nov 08, 2014 at 01:11:04PM +0100, Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfsd/nfs4xdr.c    | 16 ++++++++++++++++
>  fs/nfsd/nfsd.h       |  2 +-
>  include/linux/nfs4.h |  9 +++++++++
>  3 files changed, 26 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index eeea7a9..3205b55 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1730,6 +1730,15 @@ static __be32 *encode_change(__be32 *p, struct kstat *stat, struct inode *inode)
>  	return p;
>  }
>  
> +static __be32 *encode_change_attr_type(__be32 *p, struct inode *inode)
> +{
> +	if (IS_I_VERSION(inode))
> +		*p++ = cpu_to_be32(NFS4_CHANGE_TYPE_IS_VERSION_COUNTER);

Shouldn't that be NFS4_CHANGE_TYPE_IS_MONOTONIC_INCR?

The draft says that e.g. "If the client sees
NFS4_CHANGE_TYPE_IS_VERSION_COUNTER, it has the ability to predict what
the resulting change attribute value should be after a COMPOUND
containing a SETATTR, WRITE, or CREATE."

Admittedly, I'm not completely sure what that means.  (Is a SETATTR of
multiple attributes a single atomic change?  Can we predict the change
attribute on a newly created file, or only on the parent directory?)  I
also don't know where the filesystems do the i_version increment (can we
guarantee it happens once per nfs WRITE?).

--b.

> +	else
> +		*p++ = cpu_to_be32(NFS4_CHANGE_TYPE_IS_TIME_METADATA);
> +	return p;
> +}
> +
>  static __be32 *encode_cinfo(__be32 *p, struct nfsd4_change_info *c)
>  {
>  	*p++ = cpu_to_be32(c->atomic);
> @@ -2535,6 +2544,13 @@ out_acl:
>  		*p++ = cpu_to_be32(NFSD_SUPPATTR_EXCLCREAT_WORD2);
>  	}
>  
> +	if (bmval2 & FATTR4_WORD2_CHANGE_ATTR_TYPE) {
> +		p = xdr_reserve_space(xdr, 4);
> +		if (!p)
> +			goto out_resource;
> +		p = encode_change_attr_type(p, dentry->d_inode);
> +	}
> +
>  	attrlen = htonl(xdr->buf->len - attrlen_offset - 4);
>  	write_bytes_to_xdr_buf(xdr->buf, attrlen_offset, &attrlen, 4);
>  	status = nfs_ok;
> diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
> index 43b6a36..59a734f 100644
> --- a/fs/nfsd/nfsd.h
> +++ b/fs/nfsd/nfsd.h
> @@ -342,7 +342,7 @@ void		nfsd_lockd_shutdown(void);
>  
>  #define NFSD4_2_SUPPORTED_ATTRS_WORD2 \
>  	(NFSD4_1_SUPPORTED_ATTRS_WORD2 | \
> -	NFSD4_2_SECURITY_ATTRS)
> +	FATTR4_WORD2_CHANGE_ATTR_TYPE | NFSD4_2_SECURITY_ATTRS)
>  
>  static inline u32 nfsd_suppattrs0(u32 minorversion)
>  {
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index 356acc2..85ccd06 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -413,6 +413,7 @@ enum lock_type4 {
>  #define FATTR4_WORD1_FS_LAYOUT_TYPES    (1UL << 30)
>  #define FATTR4_WORD2_LAYOUT_BLKSIZE     (1UL << 1)
>  #define FATTR4_WORD2_MDSTHRESHOLD       (1UL << 4)
> +#define FATTR4_WORD2_CHANGE_ATTR_TYPE   (1UL << 15)
>  #define FATTR4_WORD2_SECURITY_LABEL     (1UL << 16)
>  
>  /* MDS threshold bitmap bits */
> @@ -558,4 +559,12 @@ enum data_content4 {
>  	NFS4_CONTENT_HOLE		= 1,
>  };
>  
> +enum change_attr_type4 {
> +	NFS4_CHANGE_TYPE_IS_MONOTONIC_INCR	= 0,
> +	NFS4_CHANGE_TYPE_IS_VERSION_COUNTER	= 1,
> +	NFS4_CHANGE_TYPE_IS_VERSION_COUNTER_NOPNFS = 2,
> +	NFS4_CHANGE_TYPE_IS_TIME_METADATA	= 3,
> +	NFS4_CHANGE_TYPE_IS_UNDEFINED		= 4
> +};
> +
>  #endif
> -- 
> 1.9.1
> 
