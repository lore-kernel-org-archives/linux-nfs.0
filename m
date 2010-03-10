From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 10/12] NFS: Simplify nfs_wb_page()
Date: Wed, 10 Mar 2010 15:18:20 -0500
Message-ID: <1268252300.3096.81.camel@localhost.localdomain>
References: <20100125221544.16750.70574.stgit@localhost.localdomain>
	 <20100125221545.16750.19154.stgit@localhost.localdomain>
	 <16839.1268247109@jrobl>  <1268249482.3096.76.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>,
	Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	Jens Axboe <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, linux-fsdevel@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>,
	Al Viro <viro@ZenIV.linux.org.uk>
To: "J. R. Okajima" <hooanon05-/E1597aS9LR3+QwDJ9on6Q@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50103 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751107Ab0CJUTl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Mar 2010 15:19:41 -0500
In-Reply-To: <1268249482.3096.76.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2010-03-10 at 14:31 -0500, Trond Myklebust wrote: 
> >From your trace it looks as if the problem is that the nfs_wb_page() is
> triggering a dentry release, which deadlocks with in
> truncate_inode_pages() because the _caller_ of nfs_release_page() holds
> a page lock.
> 
> As far as I can see, your iput() call above can deadlock in exactly the
> same way.
> 
> Note that shrink_page_list() is the only function that does this sort of
> thing without holding a reference to the inode.

OK. Does the following patch fix the deadlock for you?

Cheers
  Trond
----------------------------------------------------------------------------------------------------------- 
NFS: Avoid a deadlock in nfs_release_page

From: Trond Myklebust <Trond.Myklebust@netapp.com>

J.R. Okajima reports the following deadlock:

INFO: task kswapd0:305 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
kswapd0       D 0000000000000001     0   305      2 0x00000000
 ffff88001f21d4f0 0000000000000046 ffff88001fdea680 ffff88001f21c000
 ffff88001f21dfd8 ffff88001f21c000 ffff88001f21dfd8 ffff88001f21dfd8
 ffff88001fdea040 0000000000014c00 0000000000000001 ffff88001fdea040
Call Trace:
 [<ffffffff8146155d>] io_schedule+0x4d/0x70
 [<ffffffff810d2be5>] sync_page+0x65/0xa0
 [<ffffffff81461b12>] __wait_on_bit_lock+0x52/0xb0
 [<ffffffff810d2b80>] ? sync_page+0x0/0xa0
 [<ffffffff810d2b64>] __lock_page+0x64/0x70
 [<ffffffff81070ce0>] ? wake_bit_function+0x0/0x40
 [<ffffffff810df1d4>] truncate_inode_pages_range+0x344/0x4a0
 [<ffffffff810df340>] truncate_inode_pages+0x10/0x20
 [<ffffffff8112cbfe>] generic_delete_inode+0x15e/0x190
 [<ffffffff8112cc8d>] generic_drop_inode+0x5d/0x80
 [<ffffffff8112bb88>] iput+0x78/0x80
 [<ffffffff811bc908>] nfs_dentry_iput+0x38/0x50
 [<ffffffff811285f4>] dentry_iput+0x84/0x110
 [<ffffffff811286ae>] d_kill+0x2e/0x60
 [<ffffffff8112912a>] dput+0x7a/0x170
 [<ffffffff8111e925>] path_put+0x15/0x40
 [<ffffffff811c3a44>] __put_nfs_open_context+0xa4/0xb0
 [<ffffffff811cb5d0>] ? nfs_free_request+0x0/0x50
 [<ffffffff811c3b0b>] put_nfs_open_context+0xb/0x10
 [<ffffffff811cb5f9>] nfs_free_request+0x29/0x50
 [<ffffffff81234b7e>] kref_put+0x8e/0xe0
 [<ffffffff811cb594>] nfs_release_request+0x14/0x20
 [<ffffffff811cf769>] nfs_find_and_lock_request+0x89/0xa0
 [<ffffffff811d1180>] nfs_wb_page+0x80/0x110
 [<ffffffff811c0770>] nfs_release_page+0x70/0x90
 [<ffffffff810d18ee>] try_to_release_page+0x5e/0x80
 [<ffffffff810e1178>] shrink_page_list+0x638/0x860
 [<ffffffff810e19de>] shrink_zone+0x63e/0xc40

We can fix this by making the call to put_nfs_open_context() happen when we
actually remove the write request from the inode (which is done by the
nfsiod thread in this case).

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/pagelist.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)


diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index a12c45b..81fb4a5 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -148,10 +148,16 @@ void nfs_clear_page_tag_locked(struct nfs_page *req)
 void nfs_clear_request(struct nfs_page *req)
 {
 	struct page *page = req->wb_page;
+	struct nfs_open_context *ctx = req->wb_context;
+
 	if (page != NULL) {
 		page_cache_release(page);
 		req->wb_page = NULL;
 	}
+	if (ctx != NULL) {
+		put_nfs_open_context(ctx);
+		req->wb_context = NULL;
+	}
 }
 

@@ -165,9 +171,8 @@ static void nfs_free_request(struct kref *kref)
 {
 	struct nfs_page *req = container_of(kref, struct nfs_page, wb_kref);
 
-	/* Release struct file or cached credential */
+	/* Release struct file and open context */
 	nfs_clear_request(req);
-	put_nfs_open_context(req->wb_context);
 	nfs_page_free(req);
 }
 



