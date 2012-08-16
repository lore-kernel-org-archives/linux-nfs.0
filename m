Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:38635 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751859Ab2HPNaG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Aug 2012 09:30:06 -0400
Message-ID: <1345123774.23681.10.camel@localhost>
Subject: Re: [PATCH 1/3] NFSv4: Fix pointer arithmetic in decode_getacl
From: Sachin Prabhu <sprabhu@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Dros Adamson <Weston.Adamson@netapp.com>,
        Andy Adamson <William.Adamson@netapp.com>, linux-nfs@vger.kernel.org
Date: Thu, 16 Aug 2012 14:29:34 +0100
In-Reply-To: <1344984447-17804-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1344984447-17804-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2012-08-14 at 18:47 -0400, Trond Myklebust wrote:
> Resetting the cursor xdr->p to a previous value is not a safe
> practice: if the xdr_stream has crossed out of the initial iovec,
> then a bunch of other fields would need to be reset too.
> 
> Fix this issue by using xdr_enter_page() so that the buffer gets
> page aligned at the bitmap _before_ we decode it.
> 
> Also fix the confusion of the ACL length with the page buffer length
> by not adding the base offset to the ACL length...
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: stable@vger.kernel.org
> ---
>  fs/nfs/nfs4proc.c |  2 +-
>  fs/nfs/nfs4xdr.c  | 21 +++++++--------------
>  2 files changed, 8 insertions(+), 15 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index c77d296..286ab70 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3819,7 +3819,7 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
>  	if (ret)
>  		goto out_free;
>  
> -	acl_len = res.acl_len - res.acl_data_offset;
> +	acl_len = res.acl_len;
>  	if (acl_len > args.acl_len)
>  		nfs4_write_cached_acl(inode, NULL, 0, acl_len);
>  	else
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index ca13483..54d3f5a 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -5049,18 +5049,14 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
>  	uint32_t attrlen,
>  		 bitmap[3] = {0};
>  	int status;
> -	size_t page_len = xdr->buf->page_len;
>  
>  	res->acl_len = 0;
>  	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
>  		goto out;
>  
> +	xdr_enter_page(xdr, xdr->buf->page_len);
> +
>  	bm_p = xdr->p;
> -	res->acl_data_offset = be32_to_cpup(bm_p) + 2;
> -	res->acl_data_offset <<= 2;
> -	/* Check if the acl data starts beyond the allocated buffer */
> -	if (res->acl_data_offset > page_len)
> -		return -ERANGE;
>  
>  	if ((status = decode_attr_bitmap(xdr, bitmap)) != 0)
>  		goto out;
> @@ -5074,23 +5070,20 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
>  		/* The bitmap (xdr len + bitmaps) and the attr xdr len words
>  		 * are stored with the acl data to handle the problem of
>  		 * variable length bitmaps.*/
> -		xdr->p = bm_p;
> +		res->acl_data_offset = (xdr->p - bm_p) << 2;

The problem here is with an unbounded bitmap. In the case where the
server decides to send a large bitmap and the value of bitmap array + 2
(for the acl length attribute) is greater than the buffer allocated, we
will move to the tail section of the xdr and the pointer arithmetic here
will be wrong. 

Maybe we are better off setting res->acl_data_offset as in the earlier
block. We will not need the variable bm_p in that case.

Sachin Prabhu
>  
>  		/* We ignore &savep and don't do consistency checks on
>  		 * the attr length.  Let userspace figure it out.... */
> -		attrlen += res->acl_data_offset;
> -		if (attrlen > page_len) {
> +		res->acl_len = attrlen;
> +		if (attrlen + res->acl_data_offset > xdr->buf->page_len) {
>  			if (res->acl_flags & NFS4_ACL_LEN_REQUEST) {
>  				/* getxattr interface called with a NULL buf */
> -				res->acl_len = attrlen;
>  				goto out;
>  			}
> -			dprintk("NFS: acl reply: attrlen %u > page_len %zu\n",
> -					attrlen, page_len);
> +			dprintk("NFS: acl reply: attrlen %u > page_len %u\n",
> +					attrlen, xdr->buf->page_len);
>  			return -EINVAL;
>  		}
> -		xdr_read_pages(xdr, attrlen);
> -		res->acl_len = attrlen;
>  	} else
>  		status = -EOPNOTSUPP;
>  



