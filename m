From: Neil Brown <neilb@suse.de>
Subject: Re: Problems with mmap consistency
Date: Fri, 24 Feb 2006 17:15:25 +1100
Message-ID: <17406.42109.177974.703541@cse.unsw.edu.au>
References: <20060217105756.GE25707@suse.de>
	<1140189330.3612.3.camel@lade.trondhjem.org>
	<20060224040142.GW5866@g5.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FCWFJ-00068c-QI
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 22:16:05 -0800
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FCWFI-0004SY-RA
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 22:16:05 -0800
To: Andrea Arcangeli <andrea@suse.de>
In-Reply-To: message from Andrea Arcangeli on Friday February 24
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Friday February 24, andrea@suse.de wrote:
> Hello, 
> 
> On Fri, Feb 17, 2006 at 10:15:30AM -0500, Trond Myklebust wrote:
> > On Fri, 2006-02-17 at 11:57 +0100, Olaf Kirch wrote:
> > > It seems the problem is that there is still a fairly big race window
> > > in this code - after unmap_mapping_range returns, we're waiting for
> > > all dirty pages to be flushed to the server. A lot can happen while
> > > we wait - for instance, some other process may modify a page that
> > > has already been written. This modification will be lost during
> > > the subsequent invalidate_inode_pages2 call.

This seems very closely related to a problem I have been chasing.  In
my case invalidate_inode_page2 discard pages that are in the process
of writeback, and writeback oops because it expects that page to still
be in the inodes radix_tree, but it isn't.

The core problem is a race between invalidate_inode_pages2 trying to
invalidate pages, and other code making those pages dirty.

> > > 
> > > Is there a simple VM mechanism that could be used to prevent this,
> > > or does it need some extra logic to block a process in nfs_readpage
> > > while we're revalidating?
> > 
> > No. I believe I have discussed this with Andrea and others before.
> 
> Yep.
> 
> > We need to add a VM helper that will invalidate the page cache and flush
> > dirty pages atomically (such a thing does not yet exist).

While this would be nice, I don't think it can be done reliably (as
Andrea indicates) because protecting against a page being dirtied is
not possible.

What is *needed* is that we invalidate any part of a page that isn't
dirty.  Dirty parts need to be left for write-back, but the non-dirty
parts should be marked as invalid so they will be refreshed from the
server before responding to a read.
The 'discard the page from the page_cache' that
invalidate_inode_pages2 does through invalidate_complete_page isn't
needed.  We just need to mark the page as not containing valid data.

I suspect this could be done through a ->releasepage callback.

> 
> Such thing will hardly exist if page faults can mark pages dirty at any
> time mostly lockless. Things may change for the better if we start
> taking the page lock in do_no_page but I doubt we'll serialize
> atomically against the whole disk-bound fdatawriteandwait.
> 
> I think it's enough to make invalidate_inode_pages2 non destructive.
> Then we can wonder if we should join
> unmap_mapping*+fdatasyncandwait+invalidate_inode_pages2 in a single
> function (so they look more atomic even if they're not internally), or
> something like that, but currently there are reasons why they're split
> (notably O_DIRECT needs the invalidate only for writes, for o_direct
> reads not).

I'm not sure exactly what you mean by 'non destructive'.
Do you mean that pages are not removed but are just marked 'invalid',
or do you mean that if a page is dirty it doesn't get removed.

The later, by itself, is dangerous I think.  As a page can be partly
dirty and partly not (for 'write' requests, nfs knows which parts are
dirty.  For mmap, it has to assume that it is all dirty), the part that
is not dirty really needs to be invalidated somehow.


A ->readpage already calls nfs_wb_page before starting a read, so if
we define an invalidate_page callback (see patch below from Trond,
modified by me) which calls ClearPageUptodate appropriately, we might
get the desired result.  However I'm not entirely sure what the code should
look like as I don't know exactly when a page is marked dirty and when
marked clean as it flows through nfs....

> 
> Basically this way dirty pages gets higher prio, and they can't be
> dropped anymore. They can only be flushed safely to disk. That's enough
> for O_DIRECT coherency protocol and it should fix nfs.
> 
> I seem to remember I asked explanations on the "was_dirty" code in my
> first email on the subject (before noticing you also worked on the nfs
> part about at the same time ;), but I didn't get any answer.
> 
> I didn't check if this fixes the testcase, patch still untested
> sorry.

That patch makes sense to me ... at least in this context.  I haven't
looked at other users of the code.

NeilBrown

----------------------------

NFS: Avoid races between writebacks and truncation

Author: Trond Myklebust <Trond.Myklebust@netapp.com>

Currently, there is no serialisation between NFS asynchronous writebacks
and truncation at the page level due to the fact that nfs_sync_inode()
cannot lock the pages that it is about to write out.

This means that it is possible to be flushing out data (and calling something
like set_page_writeback()) while the page cache is busy evicting the page.
Oops...

Use the hooks provided in try_to_release_page() to ensure that dirty pages
are always written back to storage before we evict them.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Neil Brown <neilb@suse.de>

Index: linux-2.6.15/fs/nfs/file.c
===================================================================
--- linux-2.6.15.orig/fs/nfs/file.c	2006-02-24 14:56:42.000000000 +1100
+++ linux-2.6.15/fs/nfs/file.c	2006-02-24 14:57:08.000000000 +1100
@@ -316,6 +316,19 @@
 	return status;
 }
 
+static int nfs_invalidate_page(struct page *page, unsigned long offset)
+{
+	/* FIXME: we really should cancel any unstarted writes on this page */
+	BUG_ON(PagePrivate(page));
+	return 1;
+}
+
+static int nfs_release_page(struct page *page, gfp_t gfp)
+{
+	nfs_wb_page(page->mapping->host, page);
+	return !PagePrivate(page);
+}
+
 struct address_space_operations nfs_file_aops = {
 	.readpage = nfs_readpage,
 	.readpages = nfs_readpages,
@@ -324,6 +337,8 @@
 	.writepages = nfs_writepages,
 	.prepare_write = nfs_prepare_write,
 	.commit_write = nfs_commit_write,
+	.invalidatepage = nfs_invalidate_page,
+	.releasepage = nfs_release_page,
 #ifdef CONFIG_NFS_DIRECTIO
 	.direct_IO = nfs_direct_IO,
 #endif
Index: linux-2.6.15/fs/nfs/pagelist.c
===================================================================
--- linux-2.6.15.orig/fs/nfs/pagelist.c	2006-02-24 14:56:42.000000000 +1100
+++ linux-2.6.15/fs/nfs/pagelist.c	2006-02-24 14:57:08.000000000 +1100
@@ -85,6 +85,7 @@
 	atomic_set(&req->wb_complete, 0);
 	req->wb_index	= page->index;
 	page_cache_get(page);
+	SetPagePrivate(page);
 	req->wb_offset  = offset;
 	req->wb_pgbase	= offset;
 	req->wb_bytes   = count;
@@ -147,8 +148,10 @@
  */
 void nfs_clear_request(struct nfs_page *req)
 {
-	if (req->wb_page) {
-		page_cache_release(req->wb_page);
+	struct page *page = req->wb_page;
+	if (page != NULL) {
+		ClearPagePrivate(page);
+		page_cache_release(page);
 		req->wb_page = NULL;
 	}
 }


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
