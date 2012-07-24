Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50390 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753824Ab2GXRW2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Jul 2012 13:22:28 -0400
Date: Tue, 24 Jul 2012 13:22:24 -0400
To: Sachin Prabhu <sprabhu@redhat.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@netapp.com>
Subject: Re: [PATCH] Fix array overflow in __nfs4_get_acl_uncached
Message-ID: <20120724172224.GI8570@fieldses.org>
References: <1343129785-4538-1-git-send-email-sprabhu@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1343129785-4538-1-git-send-email-sprabhu@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 24, 2012 at 12:36:25PM +0100, Sachin Prabhu wrote:
> This fixes a bug introduced by commit
> 5a00689930ab975fdd1b37b034475017e460cf2a
> 
> Bruce Fields pointed out that the changes introduced by the patch will
> cause the array npages to overflow if a size requested is >=
> XATTR_SIZE_MAX.
> 
> The patch also fixes the check for the length of the ACL returned. The
> flag ACL_LEN_REQUEST has been renamed to NFS4_ACL_LEN_ONLY and apart
> from indicating that the user is just interested in the ACL length when
> making a request, it is also used to indicate if the xdr pages buffer
> returned in response holds the complete ACL or just the length.

Looks right to me.

--b.

> 
> Signed-off-by: Sachin Prabhu <sprabhu@redhat.com>
> ---
>  fs/nfs/nfs4proc.c       |   18 +++++++++---------
>  fs/nfs/nfs4xdr.c        |    4 +++-
>  include/linux/nfs_xdr.h |    2 +-
>  3 files changed, 13 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 15fc7e4..e19c322 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3726,16 +3726,16 @@ out:
>  /*
>   * The getxattr API returns the required buffer length when called with a
>   * NULL buf. The NFSv4 acl tool then calls getxattr again after allocating
> - * the required buf.  On a NULL buf, we send a page of data to the server
> - * guessing that the ACL request can be serviced by a page. If so, we cache
> - * up to the page of ACL data, and the 2nd call to getxattr is serviced by
> - * the cache. If not so, we throw away the page, and cache the required
> - * length. The next getxattr call will then produce another round trip to
> - * the server, this time with the input buf of the required size.
> + * the required buf.  On a NULL buf, we allocate 2 pages guessing that the
> + * ACL request can be serviced by those pages. If so, we cache the ACL data,
> + * and the 2nd call to getxattr is serviced by the cache. If not so, we throw
> + * away the pages, and cache the required length. The next getxattr call will
> + * then produce another round trip to the server, this time with the input buf
> + * of the required size.
>   */
>  static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t buflen)
>  {
> -	struct page *pages[NFS4ACL_MAXPAGES] = {NULL, };
> +	struct page *pages[NFS4ACL_MAXPAGES+1] = {NULL, };
>  	struct nfs_getaclargs args = {
>  		.fh = NFS_FH(inode),
>  		.acl_pages = pages,
> @@ -3777,7 +3777,7 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
>  	/* Let decode_getfacl know not to fail if the ACL data is larger than
>  	 * the page we send as a guess */
>  	if (buf == NULL)
> -		res.acl_flags |= NFS4_ACL_LEN_REQUEST;
> +		res.acl_flags |= NFS4_ACL_LEN_ONLY;
>  
>  	dprintk("%s  buf %p buflen %zu npages %d args.acl_len %zu\n",
>  		__func__, buf, buflen, npages, args.acl_len);
> @@ -3787,7 +3787,7 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
>  		goto out_free;
>  
>  	acl_len = res.acl_len - res.acl_data_offset;
> -	if (acl_len > args.acl_len)
> +	if (res.acl_flags & NFS4_ACL_LEN_ONLY)
>  		nfs4_write_cached_acl(inode, NULL, 0, acl_len);
>  	else
>  		nfs4_write_cached_acl(inode, pages, res.acl_data_offset,
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 18fae29..a88fcd0 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -5101,7 +5101,7 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
>  		hdrlen = (u8 *)xdr->p - (u8 *)iov->iov_base;
>  		attrlen += res->acl_data_offset;
>  		if (attrlen > page_len) {
> -			if (res->acl_flags & NFS4_ACL_LEN_REQUEST) {
> +			if (res->acl_flags & NFS4_ACL_LEN_ONLY) {
>  				/* getxattr interface called with a NULL buf */
>  				res->acl_len = attrlen;
>  				goto out;
> @@ -5110,6 +5110,8 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
>  					attrlen, page_len);
>  			return -EINVAL;
>  		}
> +		/* At this stage we have the complete ACL */
> +		res->acl_flags &= ~NFS4_ACL_LEN_ONLY;
>  		xdr_read_pages(xdr, attrlen);
>  		res->acl_len = attrlen;
>  	} else
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 8aadd90..39c8483 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -648,7 +648,7 @@ struct nfs_getaclargs {
>  };
>  
>  /* getxattr ACL interface flags */
> -#define NFS4_ACL_LEN_REQUEST	0x0001	/* zero length getxattr buffer */
> +#define NFS4_ACL_LEN_ONLY	0x0001	/* zero length getxattr buffer */
>  struct nfs_getaclres {
>  	size_t				acl_len;
>  	size_t				acl_data_offset;
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
