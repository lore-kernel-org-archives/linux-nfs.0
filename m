From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 10/12] NFS: Simplify nfs_wb_page()
Date: Wed, 17 Mar 2010 14:08:02 -0400
Message-ID: <20100317140802.4dd5d2df@tlielax.poochiereds.net>
References: <20100125221544.16750.70574.stgit@localhost.localdomain>
	<20100125221545.16750.19154.stgit@localhost.localdomain>
	<16839.1268247109@jrobl>
	<1268249482.3096.76.camel@localhost.localdomain>
	<1268252300.3096.81.camel@localhost.localdomain>
	<22120.1268282756@jrobl>
	<1268317582.3354.9.camel@localhost.localdomain>
	<20100317164938.GA31415@infradead.org>
	<1268846819.8335.3.camel@localhost.localdomain>
	<20100317135205.58731824@tlielax.poochiereds.net>
	<1268848682.8335.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Christoph Hellwig <hch@infradead.org>,
	"J. R. Okajima" <hooanon05-/E1597aS9LR3+QwDJ9on6Q@public.gmane.org>, linux-nfs@vger.kernel.org,
	Wu Fengguang <fengguang.wu@intel.com>,
	Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	Jens Axboe <jens.axboe@oracle.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, linux-fsdevel@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>,
	Al Viro <viro@ZenIV.linux.org.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35733 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753634Ab0CQSIj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Mar 2010 14:08:39 -0400
In-Reply-To: <1268848682.8335.5.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 17 Mar 2010 13:58:02 -0400
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Wed, 2010-03-17 at 13:52 -0400, Jeff Layton wrote: 
> > On Wed, 17 Mar 2010 13:26:59 -0400
> > Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> > 
> > > On Wed, 2010-03-17 at 12:49 -0400, Christoph Hellwig wrote: 
> > > > On Thu, Mar 11, 2010 at 09:26:22AM -0500, Trond Myklebust wrote:
> > > > > @@ -112,12 +112,10 @@ void nfs_unlock_request(struct nfs_page *req)
> > > > >   */
> > > > >  int nfs_set_page_tag_locked(struct nfs_page *req)
> > > > >  {
> > > > > -	struct nfs_inode *nfsi = NFS_I(req->wb_context->path.dentry->d_inode);
> > > > > -
> > > > >  	if (!nfs_lock_request_dontget(req))
> > > > >  		return 0;
> > > > >  	if (req->wb_page != NULL)
> > > > > -		radix_tree_tag_set(&nfsi->nfs_page_tree, req->wb_index, NFS_PAGE_TAG_LOCKED);
> > > > > +		radix_tree_tag_set(&NFS_I(req->wb_context->path.dentry->d_inode)->nfs_page_tree, req->wb_index, NFS_PAGE_TAG_LOCKED);
> > > > >  	return 1;
> > > > >  }
> > > > >  
> > > > 
> > > > This hunk is not only entirely unrealted to the fix, but also osbfucates
> > > > the code.
> > > > 
> > > > > @@ -126,10 +124,10 @@ int nfs_set_page_tag_locked(struct nfs_page *req)
> > > > >   */
> > > > >  void nfs_clear_page_tag_locked(struct nfs_page *req)
> > > > >  {
> > > > > -	struct inode *inode = req->wb_context->path.dentry->d_inode;
> > > > > -	struct nfs_inode *nfsi = NFS_I(inode);
> > > > > -
> > > > >  	if (req->wb_page != NULL) {
> > > > > +		struct inode *inode = req->wb_context->path.dentry->d_inode;
> > > > > +		struct nfs_inode *nfsi = NFS_I(inode);
> > > > > +
> > > > >  		spin_lock(&inode->i_lock);
> > > > >  		radix_tree_tag_clear(&nfsi->nfs_page_tree, req->wb_index, NFS_PAGE_TAG_LOCKED);
> > > > >  		nfs_unlock_request(req);
> > > > 
> > > > Another one unrelated to the fix.
> > > > 
> > > 
> > > No. They are needed because we don't want to dereference req->wb_context
> > > after it (and req->wb_page) have been cleared. Without these 2 hunks,
> > > the resulting kernel Oopses.
> > > 
> > 
> > It seems like that just tightens up the race window without actually
> > closing it.
> > 
> > Just because wb_page was non-NULL when you checked it gives no
> > guarantee that wb_context won't be NULL when you go to dereference it,
> > right?
> > 
> 
> The above 2 functions are the ones that lock and unlock the request.
> Once locked by means of the call to nfs_lock_request_dontget(req), no
> other threads can change the contents of wb_page and wb_context.
> 
> IOW: yes, there is definitely such a guarantee...
> 

Ok, I think I see now.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
