From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 4/4] NFS: Fix nfs_direct_dirty_pages()
Date: Wed, 23 May 2007 18:53:18 -0400
Message-ID: <1179960798.6707.60.camel@heimdal.trondhjem.org>
References: <20070522142908.22559.91696.stgit@heimdal.trondhjem.org>
	<20070522142923.22559.49677.stgit@heimdal.trondhjem.org>
	<1179874805.6189.12.camel@heimdal.trondhjem.org>
	<4654B873.10805@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hqzi1-0005YE-Qq
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 15:53:33 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hqzi4-0002VI-MF
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 15:53:36 -0700
In-Reply-To: <4654B873.10805@oracle.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, 2007-05-23 at 17:56 -0400, Chuck Lever wrote:
> Trond Myklebust wrote:
> > On Tue, 2007-05-22 at 10:29 -0400, Trond Myklebust wrote:
> >> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> >>
> >> We only need to dirty the pages that were actually read in.
> >>
> >> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> >> ---
> >>
> >>  fs/nfs/direct.c |   20 ++++++++++++++------
> >>  1 files changed, 14 insertions(+), 6 deletions(-)
> >>
> >> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> >> index ef0ce2c..4060e6f 100644
> >> --- a/fs/nfs/direct.c
> >> +++ b/fs/nfs/direct.c
> >> @@ -122,9 +122,15 @@ ssize_t nfs_direct_IO(int rw, struct kiocb *iocb, const struct iovec *iov, loff_
> >>  	return -EINVAL;
> >>  }
> >>  
> >> -static void nfs_direct_dirty_pages(struct page **pages, unsigned int npages)
> >> +static void nfs_direct_dirty_pages(struct page **pages, unsigned int pgbase, size_t count)
> >>  {
> >> +	unsigned int npages;
> >>  	unsigned int i;
> >> +
> >> +	if (count == 0)
> >> +		return;
> >> +	pages += (pgbase >> PAGE_SHIFT);
> >> +	npages = (count + (pgbase & ~PAGE_MASK) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> >>  	for (i = 0; i < npages; i++) {
> >>  		struct page *page = pages[i];
> >>  		if (!PageCompound(page))
> >> @@ -224,18 +230,20 @@ static void nfs_direct_read_result(struct rpc_task *task, void *calldata)
> >>  	if (nfs_readpage_result(task, data) != 0)
> >>  		return;
> >>  
> >> -	nfs_direct_dirty_pages(data->pagevec, data->npages);
> >> -	nfs_direct_release_pages(data->pagevec, data->npages);
> >> -
> >>  	spin_lock(&dreq->lock);
> >>  
> >> -	if (likely(task->tk_status >= 0))
> >> +	if (likely(task->tk_status >= 0)) {
> >>  		dreq->count += data->res.count;
> >> -	else
> >> +		nfs_direct_dirty_pages(data->pagevec,
> >> +				data->args.pgbase,
> >> +				data->res.count);
> >> +	} else
> >>  		dreq->error = task->tk_status;
> >>  
> >>  	spin_unlock(&dreq->lock);
> >>  
> >> +	nfs_direct_release_pages(data->pagevec, data->npages);
> >> +
> >>  	if (put_dreq(dreq))
> >>  		nfs_direct_complete(dreq);
> >>  }
> > 
> > Having looked at this one more closely I'd say we have a second bug here
> > since nfs_direct_dirty_pages() is actually calling
> > set_page_dirty_lock(). Firstly it is quite unacceptable for an
> > asynchronous RPC callback to be calling lock_page(). Secondly, AFAICS
> > you have no guarantees that the pages that were mapped using the call to
> > get_user_pages() aren't already locked...
> > 
> > Chuck?
> 
> OK, well...
> 
> It looks like the generic dio code preemptively dirties pages in the 
> "read buffer" while still in the issuing process's context.  When the 
> read operation completes, it checks whether the pages are still dirty, 
> and if not, it asks a worker thread to redirty them via set_page_dirty_lock.
> 
> There's still some question about whether this needs to be done for both 
> the synchronous and asynchronous read case... I'd say for NFS, both are 
> needed since all read results arrive via soft IRQ.
> 
> I think then that removing set_page_dirty_lock from the read_result path 
> makes your question about get_user_pages moot.
> 
> What do you think?

I've simply replaced the call to set_page_dirty_lock() with a standard
call to set_page_dirty().

Cheers
  Trond

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
