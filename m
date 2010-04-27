From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: Possible problem with commit a6305ddb080 : NFS: Fix a race
 with the new commit code
Date: Tue, 27 Apr 2010 18:21:13 -0400
Message-ID: <1272406873.14667.6.camel@localhost.localdomain>
References: <20100427143542.001f8dbe@notabene.brown>
	 <1272369635.16814.52.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33827 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757308Ab0D0WVa convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Apr 2010 18:21:30 -0400
In-Reply-To: <1272369635.16814.52.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2010-04-27 at 08:00 -0400, Trond Myklebust wrote: 
> On Tue, 2010-04-27 at 14:35 +1000, Neil Brown wrote: 
> > Hi Trond,
> >  I think the above mentioned commit might have added a new race to replace
> > the old ....
> > 
> >  I have report of a BUG in nfs_page_async_flush.
> > 
> > It isn't a vanilla upstream kernel - there are a bunch of SUSE patches
> > in there - so quoting the line-number won't help you, but it is the
> >     BUG_ON(ret != 0);
> > after the call to nfs_set_page_writeback.
> > (https://bugzilla.novell.com/show_bug.cgi?id=599628)
> > 
> > This implies that nfs_find_and_lock_request got a new lock on the page,
> > and then we found that it was already flagged for writeback.
> 
> That's odd. Callers such as write_cache_pages() should normally be doing
> a wait_on_page_writeback() after taking the page lock but prior to
> calling the filesystem.

The following patch ought to fix it. I suspect the same race exists in
the ->readpage() path, so it makes sense to fix nfs_wb_page() rather
than putting the wait_on_page_writeback call in
nfs_try_to_update_request().

Cheers
  Trond
------------------------------------------------------------------------------------------------ 
NFS: Ensure that nfs_wb_page() waits for Pg_writeback to clear

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Neil Brown reports that he is seeing the BUG_ON(ret == 0) trigger in
nfs_page_async_flush.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)


diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index ccde2ae..c700698 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1472,6 +1472,7 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 
 	BUG_ON(!PageLocked(page));
 	for (;;) {
+		wait_on_page_writeback(page);
 		req = nfs_page_find_request(page);
 		if (req == NULL)
 			break;
@@ -1511,10 +1512,12 @@ int nfs_wb_page(struct inode *inode, struct page *page)
 	int ret;
 
 	while(PagePrivate(page)) {
+		wait_on_page_writeback(page);
 		if (clear_page_dirty_for_io(page)) {
 			ret = nfs_writepage_locked(page, &wbc);
 			if (ret < 0)
 				goto out_error;
+			continue;
 		}
 		req = nfs_find_and_lock_request(page);
 		if (!req)

