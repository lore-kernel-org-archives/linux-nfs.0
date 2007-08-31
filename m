From: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
Subject: Re: [BUG] problem with nfs_invalidate_page
Date: Fri, 31 Aug 2007 13:35:44 +0900
Message-ID: <200708310435.AA00256@paprika.lab.ntt.co.jp>
References: <1188402562.6580.74.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQyFr-0008Ht-Sq
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 21:37:12 -0700
Received: from tama55.ecl.ntt.co.jp ([129.60.39.103])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQyFv-0002pD-T2
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 21:37:16 -0700
In-Reply-To: <1188402562.6580.74.camel@heimdal.trondhjem.org>
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

On Wed, 29 Aug 2007 11:49:22 -0400, Trond Myklebust wrote:
>OK. I see your point... Basically, you are saying that the new
>->invalidatepage() semantics do not allow us to rely on the dirty status
>of the page in order to figure out if we need to clean up.

Exactly.

>Andrew, that was a fairly significant change in semantics...
>
>Anyhow, well done debugging it! Does the following patch fix the Oops?
>
>Trond

Yes, the patch did fix the Oops crash.
I've tested it in serveral ways, and it's working well enough so far.
Thanks!

Ryusuke Konishi


>On Tue, 2007-08-28 at 17:32 +0900, Ryusuke Konishi wrote:
>> On Mon, 27 Aug 2007 09:30:12 -0400, Trond Myklebust wrote:
>> >It looks as if ecryptfs is dropping the page lock between the calls to
>> >prepare_write() and commit_write(). That would be a bug.
>> 
>> No, ecryptfs is holding the page lock between the calls to 
>> nfs_prepare_write() and nfs_commit_write().
>> This is a regression since kernel 2.6.20;  kernel 2.6.19 does not 
>> yield the BUG.
>> 
>> Please look at truncate_complete_page() and nfs_wb_page_priority() 
>> which is called from nfs_invalidate_page().
>> 
>> The recent truncate_complete_page() clears the dirty flag from a page
>> before calling a_ops->invalidatepage(),
>> ^^^^^^
>> static void
>> truncate_complete_page(struct address_space *mapping, struct page *page)
>> {
>>         ...
>> 	cancel_dirty_page(page, PAGE_CACHE_SIZE);  <--- Inserted here at kernel 2.6.20
>> 
>> 	if (PagePrivate(page))
>> 		do_invalidatepage(page, 0);   ---> will call a_ops->invalidatepage()
>>         ...
>> }
>> 
>> and this is disturbing nfs_wb_page_priority() from calling 
>> nfs_writepage_locked() that is expected to handle the pending
>> request (=nfs_page) associated with the page.
>> 
>> int nfs_wb_page_priority(struct inode *inode, struct page *page, int how)
>> {
>> 	...
>> 	if (clear_page_dirty_for_io(page)) {
>> 		ret = nfs_writepage_locked(page, &wbc);
>> 		if (ret < 0)
>> 			goto out;
>> 	}
>>  	...
>> }
>> 
>> Since truncate_complete_page() will get rid of the page after
>> a_ops->invalidatepage() returns, the request (=nfs_page) associated
>> with the page becomes a garbage in nfs_inode->nfs_page_tree.
>> 
>> This causes the collision of nfs_page and yields the BUG.
>> 
>> 
>> Cheers,
>> Ryusuke Konishi
>
>OK. I see your point... Basically, you are saying that the new
>->invalidatepage() semantics do not allow us to rely on the dirty status
>of the page in order to figure out if we need to clean up.
>
>Andrew, that was a fairly significant change in semantics...
>
>Anyhow, well done debugging it! Does the following patch fix the Oops?
>
>Trond
>
>______________________________________________________________________
>From: Trond Myklebust <Trond.Myklebust@netapp.com>
>Date: Tue, 28 Aug 2007 10:29:36 -0400
>NFS: Fix a write request leak in nfs_invalidate_page()
>Subject: No Subject
>Message-Id: <1188402562.6580.75.camel@heimdal.trondhjem.org>
>Mime-Version: 1.0
>Content-Transfer-Encoding: 7bit
>
>Ryusuke Konishi says:
>
>The recent truncate_complete_page() clears the dirty flag from a page
>before calling a_ops->invalidatepage(),
>^^^^^^
>static void
>truncate_complete_page(struct address_space *mapping, struct page *page)
>{
>        ...
>        cancel_dirty_page(page, PAGE_CACHE_SIZE);  <--- Inserted here at
>kernel 2.6.20
>
>        if (PagePrivate(page))
>                do_invalidatepage(page, 0);   ---> will call
>a_ops->invalidatepage()
>        ...
>}
>
>and this is disturbing nfs_wb_page_priority() from calling 
>nfs_writepage_locked() that is expected to handle the pending
>request (=nfs_page) associated with the page.
>
>int nfs_wb_page_priority(struct inode *inode, struct page *page, int how)
>{
>        ...
>        if (clear_page_dirty_for_io(page)) {
>                ret = nfs_writepage_locked(page, &wbc);
>                if (ret < 0)
>                        goto out;
>        }
>        ...
>}
>
>Since truncate_complete_page() will get rid of the page after
>a_ops->invalidatepage() returns, the request (=nfs_page) associated
>with the page becomes a garbage in nfs_inode->nfs_page_tree.
>------------------------
>
>Fix this by ensuring that nfs_wb_page_priority() recognises that it may
>also need to clear out non-dirty pages that have an nfs_page associated
>with them.
>
>Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>---
>
> fs/nfs/file.c          |    2 +-
> fs/nfs/write.c         |   44 ++++++++++++++++++++++++++++++++++++++++++++
> include/linux/nfs_fs.h |    1 +
> 3 files changed, 46 insertions(+), 1 deletions(-)
>
>diff --git a/fs/nfs/file.c b/fs/nfs/file.c
>index c87dc71..579cf8a 100644
>--- a/fs/nfs/file.c
>+++ b/fs/nfs/file.c
>@@ -316,7 +316,7 @@ static void nfs_invalidate_page(struct page *page, unsigned long offset)
> 	if (offset != 0)
> 		return;
> 	/* Cancel any unstarted writes on this page */
>-	nfs_wb_page_priority(page->mapping->host, page, FLUSH_INVALIDATE);
>+	nfs_wb_page_cancel(page->mapping->host, page);
> }
> 
> static int nfs_release_page(struct page *page, gfp_t gfp)
>diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>index ef97e0c..0d7a77c 100644
>--- a/fs/nfs/write.c
>+++ b/fs/nfs/write.c
>@@ -1396,6 +1396,50 @@ out:
> 	return ret;
> }
> 
>+int nfs_wb_page_cancel(struct inode *inode, struct page *page)
>+{
>+	struct nfs_page *req;
>+	loff_t range_start = page_offset(page);
>+	loff_t range_end = range_start + (loff_t)(PAGE_CACHE_SIZE - 1);
>+	struct writeback_control wbc = {
>+		.bdi = page->mapping->backing_dev_info,
>+		.sync_mode = WB_SYNC_ALL,
>+		.nr_to_write = LONG_MAX,
>+		.range_start = range_start,
>+		.range_end = range_end,
>+	};
>+	int ret = 0;
>+
>+	BUG_ON(!PageLocked(page));
>+	for (;;) {
>+		req = nfs_page_find_request(page);
>+		if (req == NULL)
>+			goto out;
>+		if (test_bit(PG_NEED_COMMIT, &req->wb_flags)) {
>+			nfs_release_request(req);
>+			break;
>+		}
>+		if (nfs_lock_request_dontget(req)) {
>+			nfs_inode_remove_request(req);
>+			/*
>+			 * In case nfs_inode_remove_request has marked the
>+			 * page as being dirty
>+			 */
>+			cancel_dirty_page(page, PAGE_CACHE_SIZE);
>+			nfs_unlock_request(req);
>+			break;
>+		}
>+		ret = nfs_wait_on_request(req);
>+		if (ret < 0)
>+			goto out;
>+	}
>+	if (!PagePrivate(page))
>+		return 0;
>+	ret = nfs_sync_mapping_wait(page->mapping, &wbc, FLUSH_INVALIDATE);
>+out:
>+	return ret;
>+}
>+
> int nfs_wb_page_priority(struct inode *inode, struct page *page, int how)
> {
> 	loff_t range_start = page_offset(page);
>diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
>index 157dcb0..7250eea 100644
>--- a/include/linux/nfs_fs.h
>+++ b/include/linux/nfs_fs.h
>@@ -431,6 +431,7 @@ extern int nfs_sync_mapping_range(struct address_space *, loff_t, loff_t, int);
> extern int nfs_wb_all(struct inode *inode);
> extern int nfs_wb_page(struct inode *inode, struct page* page);
> extern int nfs_wb_page_priority(struct inode *inode, struct page* page, int how);
>+extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
> #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
> extern int  nfs_commit_inode(struct inode *, int);
> extern struct nfs_write_data *nfs_commit_alloc(void);

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
