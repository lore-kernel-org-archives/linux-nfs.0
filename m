Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:35335 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934660AbbGVP6P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jul 2015 11:58:15 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH v5 39/39] nfs: Add support for the v4.1 dacl attribute
To: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>,
        <linux-kernel@vger.kernel.org>
References: <1437570209-29832-1-git-send-email-andreas.gruenbacher@gmail.com>
 <1437570209-29832-40-git-send-email-andreas.gruenbacher@gmail.com>
CC: <linux-fsdevel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <linux-api@vger.kernel.org>, <samba-technical@lists.samba.org>,
        <linux-security-module@vger.kernel.org>,
        Andreas Gruenbacher <agruenba@redhat.com>
Message-ID: <55AFBD84.5040904@Netapp.com>
Date: Wed, 22 Jul 2015 11:57:56 -0400
MIME-Version: 1.0
In-Reply-To: <1437570209-29832-40-git-send-email-andreas.gruenbacher@gmail.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Andreas,

On 07/22/2015 09:03 AM, Andreas Gruenbacher wrote:
> From: Andreas Gruenbacher <agruenba@redhat.com>
> 
> The dacl attribute includes Automatic Inheritance flags not supported by the
> acl attribute.  it is only supported in NFS version 4.1 and higher.  On systems
> where NFS version 4.0 is still the default, an additional mount option is
> needed:
> 
>     mount -t nfs4 -o minorversion=1 [...]

Discussions around deprecating or removing the minorversion= argument have come up recently.  The preferred way of mounting NFS v4.1 these days is with: "-o vers=4.1".  Can you update your patch description so we don't confuse people? :)

Thanks,
Anna

> 
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> ---
>  fs/nfs/nfs4proc.c       |  2 +-
>  fs/nfs/nfs4xdr.c        | 55 ++++++++++++++++++++++++++++++++++++++++++-------
>  include/linux/nfs_xdr.h |  2 +-
>  3 files changed, 50 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 5ba49c3..39f5548 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -4469,7 +4469,7 @@ static struct richacl *__nfs4_get_acl_uncached(struct inode *inode)
>  	struct nfs_server *server = NFS_SERVER(inode);
>  	struct page *pages[DIV_ROUND_UP(NFS4ACL_SIZE_MAX, PAGE_SIZE)] = {};
>  	struct nfs_getaclargs args = {
> -		.fh = NFS_FH(inode),
> +		.inode = inode,
>  		.acl_pages = pages,
>  		.acl_len = ARRAY_SIZE(pages) * PAGE_SIZE,
>  	};
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 85270df..06f5759 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -1649,9 +1649,16 @@ encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg, struct compoun
>  	encode_nfs4_stateid(xdr, &zero_stateid);
>  
>  	/* Encode attribute bitmap. */
> -	p = reserve_space(xdr, 2*4);
> -	*p++ = cpu_to_be32(1);
> -	*p = cpu_to_be32(FATTR4_WORD0_ACL);
> +	if (arg->server->attr_bitmask[1] & FATTR4_WORD1_DACL) {
> +		p = reserve_space(xdr, 3*4);
> +		*p++ = cpu_to_be32(2);
> +		*p++ = 0;
> +		*p = cpu_to_be32(FATTR4_WORD1_DACL);
> +	} else {
> +		p = reserve_space(xdr, 2*4);
> +		*p++ = cpu_to_be32(1);
> +		*p = cpu_to_be32(FATTR4_WORD0_ACL);
> +	}
>  
>  	attrlen_offset = xdr->buf->len;
>  	xdr_reserve_space(xdr, 4);  /* to be backfilled later */
> @@ -2486,9 +2493,12 @@ static void nfs4_xdr_enc_getacl(struct rpc_rqst *req, struct xdr_stream *xdr,
>  
>  	encode_compound_hdr(xdr, req, &hdr);
>  	encode_sequence(xdr, &args->seq_args, &hdr);
> -	encode_putfh(xdr, args->fh, &hdr);
> +	encode_putfh(xdr, NFS_FH(args->inode), &hdr);
>  	replen = hdr.replen + op_decode_hdr_maxsz + 1;
> -	encode_getattr_two(xdr, FATTR4_WORD0_ACL, FATTR4_WORD1_MODE, &hdr);
> +	if (NFS_SERVER(args->inode)->attr_bitmask[1] & FATTR4_WORD1_DACL)
> +		encode_getattr_two(xdr, 0, FATTR4_WORD1_MODE | FATTR4_WORD1_DACL, &hdr);
> +	else
> +		encode_getattr_two(xdr, FATTR4_WORD0_ACL, FATTR4_WORD1_MODE, &hdr);
>  
>  	xdr_inline_pages(&req->rq_rcv_buf, replen << 2,
>  		args->acl_pages, 0, args->acl_len);
> @@ -5376,14 +5386,28 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
>  
>  	if (unlikely(bitmap[0] & (FATTR4_WORD0_ACL - 1U)))
>  		return -EIO;
> -	if (likely(bitmap[0] & FATTR4_WORD0_ACL)) {
> +
> +	if (bitmap[0] & FATTR4_WORD0_ACL) {
> +		struct richace *ace;
> +
> +		if (bitmap[1] & FATTR4_WORD1_DACL)
> +			return -EIO;
> +
>  		acl = decode_acl_entries(xdr, res->server);
>  		status = PTR_ERR(acl);
>  		if (IS_ERR(acl))
>  			goto out;
> +
> +		status = -EIO;
> +		richacl_for_each_entry(ace, acl) {
> +			if (ace->e_flags & RICHACE_INHERITED_ACE)
> +				goto out;
> +		}
>  		bitmap[0] &= ~FATTR4_WORD0_ACL;
> -	} else
> +	} else if (!(bitmap[1] & FATTR4_WORD1_DACL)) {
>  		status = -EOPNOTSUPP;
> +		goto out;
> +	}
>  
>  	status = -EIO;
>  	if (unlikely(bitmap[0]))
> @@ -5391,6 +5415,23 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
>  
>  	if ((status = decode_attr_mode(xdr, bitmap, &res->mode)) < 0)
>  		goto out;
> +	if (bitmap[1] & FATTR4_WORD1_DACL) {
> +		unsigned int flags;
> +		__be32 *p;
> +
> +		p = xdr_inline_decode(xdr, 4);
> +                status = -EIO;
> +                if (unlikely(!p))
> +                        goto out;
> +                flags = be32_to_cpup(p);
> +
> +		acl = decode_acl_entries(xdr, res->server);
> +		status = PTR_ERR(acl);
> +		if (IS_ERR(acl))
> +			goto out;
> +		acl->a_flags = flags;
> +		bitmap[1] &= ~FATTR4_WORD1_DACL;
> +	}
>  	status = 0;
>  
>  out:
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index f1c8f93..abe0b66 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -695,7 +695,7 @@ struct nfs_setaclres {
>  
>  struct nfs_getaclargs {
>  	struct nfs4_sequence_args 	seq_args;
> -	struct nfs_fh *			fh;
> +	struct inode *			inode;
>  	size_t				acl_len;
>  	struct page **			acl_pages;
>  };
> 

