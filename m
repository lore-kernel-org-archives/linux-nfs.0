From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] vfs: check inode size on no_cached_page
Date: Wed, 15 Apr 2009 09:36:34 +0800
Message-ID: <20090415013634.GB6143@localhost>
References: <20090412071605.GA14058@localhost> <20090414171114.04a47932.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=gb2312
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"xcf-pcTkQGq1WEvM1kAEIRd3EQ@public.gmane.org" <xcf-pcTkQGq1WEvM1kAEIRd3EQ@public.gmane.org>, linux-nfs@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:14161 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757600AbZDOBgu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Apr 2009 21:36:50 -0400
In-Reply-To: <20090414171114.04a47932.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 15, 2009 at 08:11:14AM +0800, Andrew Morton wrote:
> On Sun, 12 Apr 2009 15:16:05 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > [This patch may not necessarily be merged, but at least we should
> >  be aware of the problem.]
> > 
> > When user space requests past-EOF data, do_generic_file_read() will
> > issue a bonus readpage call, which may be unfavorable.
> > 
> > do_generic_file_read:
> >         -> find_page:
> >         -> find_get_page()             = NULL
> >         -> page_cache_sync_readahead()
> >         -> find_get_page()             = NULL
> >         -> no_cached_page:
> >         -> readpage:

> >                 -> nfs_readpage()      = error
> >         -> readpage_error:

Sorry nfs_readpage() will actually return 0 now. See below.

> > 
> > Reported-by: Xu Chenfeng <xcf-pcTkQGq1WEvM1kAEIRd3EQ@public.gmane.org>
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  mm/filemap.c |    5 +++++
> >  1 file changed, 5 insertions(+)
> > 
> > --- mm.orig/mm/filemap.c
> > +++ mm/mm/filemap.c
> > @@ -1269,6 +1269,11 @@ readpage_error:
> >  		goto out;
> >  
> >  no_cached_page:
> > +		isize = i_size_read(inode);
> > +		end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
> > +		if (unlikely(!isize || index > end_index))
> > +			goto out;
> > +
> >  		/*
> >  		 * Ok, it wasn't cached, so we need to create a new
> >  		 * page..
> 
> Is this a problem which needs to be solved?  userspace does something
> silly and the kernel behaves a bit suboptimally?
>
> If thats the only problem here then it's not worth adding fastpath
> cycles to fix it?

Yeah just some inefficiency in theory, so no fixing is necessary.

The underlying fs code shall be able to do the right thing - just
as if a concurrent truncate happened.

The NFS case goes like this:

        nfs_readpage()
        {
                # some bonus accountings:
                nfs_inc_stats(inode, NFSIOS_VFSREADPAGE);
                nfs_add_stats(inode, NFSIOS_READPAGES, 1);

                nfs_readpage_async(page)
                  nfs_return_empty_page(page)
                    zero_user(page) # will zero the page

                return 0;
        }

After it returns 0, do_generic_file_read() will goto page_ok and check
i_size there, and free the past-EOF page.

I wonder if NFS could be improved to:
- move the NFSIOS_READPAGES accounting _after_ a successful read
- return AOP_TRUNCATED_PAGE instead of zeroing the past-EOF page
The following untested patch demonstrates the ideas.

Thanks,
Fengguang
---

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 96c4ebf..6688b46 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -76,15 +76,6 @@ void nfs_readdata_release(void *data)
 	nfs_readdata_free(rdata);
 }
 
-static
-int nfs_return_empty_page(struct page *page)
-{
-	zero_user(page, 0, PAGE_CACHE_SIZE);
-	SetPageUptodate(page);
-	unlock_page(page);
-	return 0;
-}
-
 static void nfs_readpage_truncate_uninitialised_page(struct nfs_read_data *data)
 {
 	unsigned int remainder = data->args.count - data->res.count;
@@ -123,7 +114,8 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 
 	len = nfs_page_length(page);
 	if (len == 0)
-		return nfs_return_empty_page(page);
+		return AOP_TRUNCATED_PAGE;
+
 	new = nfs_create_request(ctx, inode, page, 0, len);
 	if (IS_ERR(new)) {
 		unlock_page(page);
@@ -516,7 +508,6 @@ int nfs_readpage(struct file *file, struct page *page)
 	dprintk("NFS: nfs_readpage (%p %ld@%lu)\n",
 		page, PAGE_CACHE_SIZE, page->index);
 	nfs_inc_stats(inode, NFSIOS_VFSREADPAGE);
-	nfs_add_stats(inode, NFSIOS_READPAGES, 1);
 
 	/*
 	 * Try to flush any pending writes to the file..
@@ -550,6 +541,8 @@ int nfs_readpage(struct file *file, struct page *page)
 	}
 
 	error = nfs_readpage_async(ctx, inode, page);
+	if (!error)
+		nfs_add_stats(inode, NFSIOS_READPAGES, 1);
 
 out:
 	put_nfs_open_context(ctx);
@@ -575,7 +568,7 @@ readpage_async_filler(void *data, struct page *page)
 
 	len = nfs_page_length(page);
 	if (len == 0)
-		return nfs_return_empty_page(page);
+		return AOP_TRUNCATED_PAGE;
 
 	new = nfs_create_request(desc->ctx, inode, page, 0, len);
 	if (IS_ERR(new))
