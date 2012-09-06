Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:12923 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756494Ab2IFOqG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Sep 2012 10:46:06 -0400
Message-ID: <1346942761.2562.7.camel@localhost>
Subject: Re: [PATCH] Avoid array overflow in __nfs4_get_acl_uncached
From: Sachin Prabhu <sprabhu@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Date: Thu, 06 Sep 2012 15:46:01 +0100
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA908F81C4A@SACEXCMBX04-PRD.hq.netapp.com>
References: <1345817768-23511-1-git-send-email-sprabhu@redhat.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA908F4AF1E@SACEXCMBX01-PRD.hq.netapp.com>
	 <1345843866.2279.6.camel@localhost>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA908F5842F@SACEXCMBX01-PRD.hq.netapp.com>
	 <1345845062.32200.1.camel@localhost>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA908F5859F@SACEXCMBX01-PRD.hq.netapp.com>
	 <1345937503.4943.17.camel@localhost>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA908F69340@SACEXCMBX04-PRD.hq.netapp.com>
	 <1346162966.2554.3.camel@localhost>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA908F81C4A@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2012-09-03 at 19:11 +0000, Myklebust, Trond wrote:
> > I encountered 2 problems. 
> > 1) The if condition should be srclen >= pgbase + acl_len
> > 2) There is a second _copy_from_pages which copies to the the acl to the
> > passed buffer in __nfs4_get_acl_uncached().
> 
> The second copy from pages should already be covered by the checks in
> decode_getacl. Alright, since this is not obvious, then clearly we need
> to make it so. How about the following?

I could reproduce the crash with the second _copy_from_pages using the
patch to PyNFS from
http://www.spinics.net/lists/linux-nfs/msg32359.html

The patch below works fine for both cases apart from a small bug which
I've pointed to below.

> 8<------------------------------------------------------------------
> From 5040240245a046bd58c383806b3f161ee8b5823b Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Sun, 26 Aug 2012 11:44:43 -0700
> Subject: [PATCH] NFSv4: Fix buffer overflow checking in
>  __nfs4_get_acl_uncached
> 
> Pass the checks made by decode_getacl back to __nfs4_get_acl_uncached
> so that it knows if the acl has been truncated.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/nfs4proc.c       | 31 ++++++++++++-------------------
>  fs/nfs/nfs4xdr.c        | 12 ++++--------
>  include/linux/nfs_xdr.h |  2 +-
>  3 files changed, 17 insertions(+), 28 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 654dc38..74f5c26 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3739,7 +3739,7 @@ static void nfs4_write_cached_acl(struct inode *inode, struct page **pages, size
>  	struct nfs4_cached_acl *acl;
>  	size_t buflen = sizeof(*acl) + acl_len;
>  
> -	if (pages && buflen <= PAGE_SIZE) {
> +	if (buflen <= PAGE_SIZE) {
>  		acl = kmalloc(buflen, GFP_KERNEL);
>  		if (acl == NULL)
>  			goto out;
> @@ -3784,7 +3784,6 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
>  	};
>  	unsigned int npages = DIV_ROUND_UP(buflen, PAGE_SIZE);
>  	int ret = -ENOMEM, i;
> -	size_t acl_len = 0;
>  
>  	/* As long as we're doing a round trip to the server anyway,
>  	 * let's be prepared for a page of acl data. */
> @@ -3807,11 +3806,6 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
>  	args.acl_len = npages * PAGE_SIZE;
>  	args.acl_pgbase = 0;
>  
> -	/* Let decode_getfacl know not to fail if the ACL data is larger than
> -	 * the page we send as a guess */
> -	if (buf == NULL)
> -		res.acl_flags |= NFS4_ACL_LEN_REQUEST;
> -
>  	dprintk("%s  buf %p buflen %zu npages %d args.acl_len %zu\n",
>  		__func__, buf, buflen, npages, args.acl_len);
>  	ret = nfs4_call_sync(NFS_SERVER(inode)->client, NFS_SERVER(inode),
> @@ -3819,20 +3813,19 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
>  	if (ret)
>  		goto out_free;
>  
> -	acl_len = res.acl_len;
> -	if (acl_len > args.acl_len)
> -		nfs4_write_cached_acl(inode, NULL, 0, acl_len);
> -	else
> -		nfs4_write_cached_acl(inode, pages, res.acl_data_offset,
> -				      acl_len);
> -	if (buf) {
> +	/* Handle the case where the passed-in buffer is too short */
> +	if (res.acl_flags & NFS4_ACL_TRUNC) {
> +		/* Did the user only issue a request for the acl length? */
> +		if (buf == NULL)
> +			goto out_ok;
>  		ret = -ERANGE;
> -		if (acl_len > buflen)
> -			goto out_free;
> -		_copy_from_pages(buf, pages, res.acl_data_offset,
> -				acl_len);
> +		goto out_free;
>  	}
> -	ret = acl_len;
> +	nfs4_write_cached_acl(inode, pages, res.acl_data_offset, res.acl_len);
> +	if (buf)
> +		_copy_from_pages(buf, pages, res.acl_data_offset, res.acl_len);
> +out_ok:
> +	ret = res.acl_len;
>  out_free:
>  	for (i = 0; i < npages; i++)
>  		if (pages[i])
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 1bfbd67..3ebe025 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -5073,17 +5073,13 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
>  		 * variable length bitmaps.*/
>  		res->acl_data_offset = xdr_stream_pos(xdr) - pg_offset;
>  
> -		/* We ignore &savep and don't do consistency checks on
> -		 * the attr length.  Let userspace figure it out.... */
>  		res->acl_len = attrlen;
> -		if (attrlen > (xdr->nwords << 2)) {
> -			if (res->acl_flags & NFS4_ACL_LEN_REQUEST) {
> -				/* getxattr interface called with a NULL buf */
> -				goto out;
> -			}
> +		/* Check for receive buffer overflow */
> +		if (attrlen > (xdr->nwords << 2) ||
> +		    attrlen + pg_offset > xdr->buf->page_len) {

Here we need to use res->acl_data_offset which points to the start of
the ACL data instead of pg_offset which points to the start of the pages
section of the xdr_buf.

Once I changed this if condition, I was able to successfully test with
my reproducer.

Sachin Prabhu

> +			res->acl_flags |= NFS4_ACL_TRUNC;
>  			dprintk("NFS: acl reply: attrlen %u > page_len %u\n",
>  					attrlen, xdr->nwords << 2);
> -			return -EINVAL;
>  		}
>  	} else
>  		status = -EOPNOTSUPP;
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index ac7c8ae..be9cf3c 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -652,7 +652,7 @@ struct nfs_getaclargs {
>  };
>  
>  /* getxattr ACL interface flags */
> -#define NFS4_ACL_LEN_REQUEST	0x0001	/* zero length getxattr buffer */
> +#define NFS4_ACL_TRUNC		0x0001	/* ACL was truncated */
>  struct nfs_getaclres {
>  	size_t				acl_len;
>  	size_t				acl_data_offset;
> -- 
> 1.7.11.4
> 
> 



