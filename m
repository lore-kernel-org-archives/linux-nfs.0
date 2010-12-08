Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39325 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753467Ab0LHDRZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Dec 2010 22:17:25 -0500
Subject: Re: oops in nfs_flush_incompatible (and possible fix?)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20101207213540.441330db@corrin.poochiereds.net>
References: <20101206145743.4464c79d@tlielax.poochiereds.net>
	 <1291758082.3049.42.camel@heimdal.trondhjem.org>
	 <20101207165354.32c863f2@tlielax.poochiereds.net>
	 <1291768200.3049.51.camel@heimdal.trondhjem.org>
	 <20101207200344.68ff29e3@corrin.poochiereds.net>
	 <20101207213540.441330db@corrin.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 07 Dec 2010 22:17:07 -0500
Message-ID: <1291778228.20468.6.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-12-07 at 21:35 -0500, Jeff Layton wrote:
> On Tue, 7 Dec 2010 20:03:44 -0500
> Jeff Layton <jlayton@redhat.com> wrote:
> 
> > On Tue, 07 Dec 2010 19:30:00 -0500
> > Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> > 
> > > On Tue, 2010-12-07 at 16:53 -0500, Jeff Layton wrote:
> > > > On Tue, 07 Dec 2010 16:41:22 -0500
> > > > Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> > > > > I've been racking my brain for days now trying to remember why we clear
> > > > > the request in these cases. I think it was only about ensuring that we
> > > > > could throw the page out of the cache using invalidate_inode_pages()
> > > > > (and there is a comment about that in early 2.4.x kernels).
> > > > > 
> > > > > As far as I can see, there no longer appear to be any side effects to
> > > > > deferring releasing the page or open_contexts but I'm still a bit
> > > > > nervous about doing so.
> > > > > Can we therefore please give it a good week of pounding upon before I
> > > > > pass it on to Linus?
> > > > > 
> > > > > Cheers
> > > > >   Trond
> > > > > 
> > > > 
> > > > Sounds good. I have the reporter of this problem testing a 2.6.18-based
> > > > kernel with this patch now to see whether it fixes it. We might as well
> > > > hold off until we have results from that. Their test takes several days
> > > > to run though so it may be a little while before we know whether this
> > > > helps. I'll reply once I hear from them.
> > > 
> > > Looks like I was right to be sceptical. My setup hangs hard on the
> > > Connectathon test5 (read and write) when this patch is applied.
> > > 
> > 
> > Yep, I see this too. I don't however, see this on the RHEL5 kernel
> > where I was testing this so I'm a little confused. Any idea why it
> > would cause this behavior?
> 
> The patch below does not cause the hang for me though. Any idea why not
> putting the page in that spot would cause a hang?
> 
> -------------------------[snip]---------------------------
> 
> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
> index e4b62c6..aedcaa7 100644
> --- a/fs/nfs/read.c
> +++ b/fs/nfs/read.c
> @@ -152,7 +152,6 @@ static void nfs_readpage_release(struct nfs_page *req)
>  			(long long)NFS_FILEID(req->wb_context->path.dentry->d_inode),
>  			req->wb_bytes,
>  			(long long)req_offset(req));
> -	nfs_clear_request(req);
>  	nfs_release_request(req);
>  }
>  
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 4c14c17..04857c0 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -407,14 +407,16 @@ out:
>   */
>  static void nfs_inode_remove_request(struct nfs_page *req)
>  {
> +	struct page *page;
>  	struct inode *inode = req->wb_context->path.dentry->d_inode;
>  	struct nfs_inode *nfsi = NFS_I(inode);
>  
>  	BUG_ON (!NFS_WBACK_BUSY(req));
>  
>  	spin_lock(&inode->i_lock);
> -	set_page_private(req->wb_page, 0);
> -	ClearPagePrivate(req->wb_page);
> +	page = xchg(&req->wb_page, NULL);
> +	set_page_private(page, 0);
> +	ClearPagePrivate(page);
>  	radix_tree_delete(&nfsi->nfs_page_tree, req->wb_index);
>  	nfsi->npages--;
>  	if (!nfsi->npages) {
> @@ -422,7 +424,8 @@ static void nfs_inode_remove_request(struct nfs_page *req)
>  		iput(inode);
>  	} else
>  		spin_unlock(&inode->i_lock);
> -	nfs_clear_request(req);
> +	if (page != NULL)
> +		page_cache_release(page);
>  	nfs_release_request(req);
>  }

OK... I think I see why the hang:

I believe that it is basically due to nfs_clear_page_tag_locked() making
the assumption that if req->wb_page != NULL, then the corresponding
nfsi->nfs_page_tree lock tag needs to be cleared.

Maybe we can do that differently by just setting a flag to indicate
whether or not this request is mapped into the radix tree...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

