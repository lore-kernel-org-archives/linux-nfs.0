From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/2] NFS: Clean up nfs_update_request()
Date: Tue, 17 Jun 2008 17:35:30 -0400
Message-ID: <B9BACB96-E0DB-4C6D-B55D-A50CC6F94474@oracle.com>
References: <20080616192348.20513.72423.stgit@localhost.localdomain> <20080616192348.20513.3284.stgit@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v924)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:42039 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756906AbYFQVfx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jun 2008 17:35:53 -0400
In-Reply-To: <20080616192348.20513.3284.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

On Jun 16, 2008, at 3:23 PM, Trond Myklebust wrote:
> Simplify the loop in nfs_update_request by moving into a separate  
> function
> the code that attempts to update an existing cached NFS write.
>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>
> fs/nfs/write.c |  105 +++++++++++++++++++++++++++ 
> +----------------------------
> 1 files changed, 53 insertions(+), 52 deletions(-)
>
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 8f12157..a675dc9 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -34,9 +34,8 @@
> /*
>  * Local function declarations
>  */
> -static struct nfs_page * nfs_update_request(struct nfs_open_context*,
> -					    struct page *,
> -					    unsigned int, unsigned int);
> +static struct nfs_page * nfs_setup_write_request(struct  
> nfs_open_context *ctx,
> +		struct page *page, unsigned int offset, unsigned int bytes);
> static void nfs_pageio_init_write(struct nfs_pageio_descriptor *desc,
> 				  struct inode *inode, int ioflags);
> static void nfs_redirty_request(struct nfs_page *req);
> @@ -178,7 +177,7 @@ static int nfs_writepage_setup(struct  
> nfs_open_context *ctx, struct page *page,
> 	int ret;
>
> 	for (;;) {
> -		req = nfs_update_request(ctx, page, offset, count);
> +		req = nfs_setup_write_request(ctx, page, offset, count);
> 		if (!IS_ERR(req))
> 			break;
> 		ret = PTR_ERR(req);
> @@ -566,6 +565,41 @@ static inline int nfs_scan_commit(struct inode  
> *inode, struct list_head *dst, pg
> }
> #endif
>
> +static int nfs_try_to_update_request(struct nfs_page *req,
> +		unsigned int offset,
> +		unsigned int end)
> +{
> +	unsigned int rqend;
> +
> +	rqend = req->wb_offset + req->wb_bytes;
> +
> +	/*
> +	 * If the page doesn't match, or the offsets
> +	 * are non-contiguous, tell the caller to
> +	 * wait on the conflicting request.
> +	 */
> +	if (req->wb_page == NULL
> +	    || !nfs_dirty_request(req)
> +	    || offset > rqend
> +	    || end < req->wb_offset)
> +		return -EBUSY;

I don't see how this is equivalent to what it replaces in  
nfs_update_request:

> -	if (req->wb_context != ctx
> -	    || req->wb_page != page


What happened to the context check, for example?

> +
> +	if (!nfs_set_page_tag_locked(req))
> +		return -EAGAIN;

This -EAGAIN (and the resulting logic in nfs_setup_write_request) is  
headache-inducing.  Is there a more straightforward way to break this  
up?  I'm not sure this is a readability win.

Overall I'd like to see this clean up broken into steps.  It's a  
challenge to "prove" that you haven't changed behavior somehow with  
this one patch.

> +
> +	/* Okay, the request matches. Update the region */
> +	if (offset < req->wb_offset) {
> +		req->wb_offset = offset;
> +		req->wb_pgbase = offset;
> +	}
> +	if (end > rqend)
> +		req->wb_bytes = end - req->wb_offset;
> +	else
> +		req->wb_bytes = rqend - req->wb_offset;
> +
> +	return 0;
> +}
> +
> /*
>  * Try to update any existing write request, or create one if there  
> is none.
>  * In order to match, the request's credentials must match those of
> @@ -573,16 +607,15 @@ static inline int nfs_scan_commit(struct inode  
> *inode, struct list_head *dst, pg
>  *
>  * Note: Should always be called with the Page Lock held!
>  */
> -static struct nfs_page * nfs_update_request(struct  
> nfs_open_context* ctx,
> +static struct nfs_page * nfs_setup_write_request(struct  
> nfs_open_context* ctx,
> 		struct page *page, unsigned int offset, unsigned int bytes)
> {
> -	struct address_space *mapping = page->mapping;
> -	struct inode *inode = mapping->host;
> +	struct inode *inode = page->mapping->host;
> 	struct nfs_page		*req, *new = NULL;
> -	pgoff_t		rqend, end;
> +	unsigned int end;
> +	int error;
>
> 	end = offset + bytes;
> -
> 	for (;;) {
> 		/* Loop over all inode entries and see if we find
> 		 * A request for the page we wish to update
> @@ -590,26 +623,16 @@ static struct nfs_page *  
> nfs_update_request(struct nfs_open_context* ctx,
> 		spin_lock(&inode->i_lock);
> 		req = nfs_page_find_request_locked(page);
> 		if (req) {
> -			if (!nfs_set_page_tag_locked(req)) {
> -				int error;
> -
> -				spin_unlock(&inode->i_lock);
> +			error = nfs_try_to_update_request(req, offset, end);
> +			spin_unlock(&inode->i_lock);
> +			if (error == 0)
> +				break;
> +			if (error == -EAGAIN)
> 				error = nfs_wait_on_request(req);
> -				nfs_release_request(req);
> -				if (error < 0) {
> -					if (new) {
> -						radix_tree_preload_end();
> -						nfs_release_request(new);
> -					}
> -					return ERR_PTR(error);
> -				}
> +			nfs_release_request(req);
> +			if (error == 0)
> 				continue;
> -			}
> -			spin_unlock(&inode->i_lock);
> -			if (new) {
> -				radix_tree_preload_end();
> -				nfs_release_request(new);
> -			}
> +			req = ERR_PTR(error);
> 			break;
> 		}
>
> @@ -632,32 +655,10 @@ static struct nfs_page *  
> nfs_update_request(struct nfs_open_context* ctx,
> 		}
> 	}
>
> -	/* We have a request for our page.
> -	 * If the creds don't match, or the
> -	 * page addresses don't match,
> -	 * tell the caller to wait on the conflicting
> -	 * request.
> -	 */
> -	rqend = req->wb_offset + req->wb_bytes;
> -	if (req->wb_context != ctx
> -	    || req->wb_page != page
> -	    || !nfs_dirty_request(req)
> -	    || offset > rqend || end < req->wb_offset) {
> -		nfs_clear_page_tag_locked(req);
> -		return ERR_PTR(-EBUSY);
> +	if (new) {
> +		radix_tree_preload_end();
> +		nfs_release_request(new);
> 	}
> -
> -	/* Okay, the request matches. Update the region */
> -	if (offset < req->wb_offset) {
> -		req->wb_offset = offset;
> -		req->wb_pgbase = offset;
> -		req->wb_bytes = max(end, rqend) - req->wb_offset;
> -		goto out;
> -	}
> -
> -	if (end > rqend)
> -		req->wb_bytes = end - req->wb_offset;
> -
> out:

There's only one "goto out;" left in nfs_setup_write_request().  There  
are other return sites in nfs_setup_write_request() that simply  
"return req;" -- for what purpose is this one goto still here?

>
> 	return req;
> }

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
