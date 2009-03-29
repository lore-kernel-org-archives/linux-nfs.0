Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:22701 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756055AbZC2CdD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Mar 2009 22:33:03 -0400
Date: Sun, 29 Mar 2009 10:32:38 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
To: Jos Houtman <jos@hyves.nl>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "jens.axboe@oracle.com" <jens.axboe@oracle.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "hch@infradead.org" <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Page Cache writeback too slow,   SSD/noop scheduler/ext2
Message-ID: <20090329023238.GA7825@localhost>
References: <20090325052637.GA5912@localhost> <C5F2C492.D4A8%jos@hyves.nl>
Content-Type: multipart/mixed; boundary="17pEHd4RhPHOinZp"
In-Reply-To: <C5F2C492.D4A8%jos@hyves.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Mar 28, 2009 at 12:59:43AM +0800, Jos Houtman wrote:
> Hi,
> 
> >> 
> >> kupdate surely should just continue to keep trying to write back pages
> >> so long as there are more old pages to clean, and the queue isn't
> >> congested. That seems to be the intention anyway: MAX_WRITEBACK_PAGES
> >> is just the number to write back in a single call, but you see
> >> nr_to_write is set to the number of dirty pages in the system.
> 
> And when it's congested it should just wait a little bit before continuing.
>  
> >> On your system, what must be happening is more_io is not being set.
> >> The logic in fs/fs-writeback.c might be busted.
> 
> I don't know about more_io, but I agree that the logic seems busted.
> 
> > 
> > Hi Jos,
> > 
> > I prepared a debugging patch for 2.6.28. (I cannot observe writeback
> > problems on my local ext2 mount.)
> 
> Thanx for the patch, but for the next time: How should I apply it?
> it seems to be context aware (@@) and broke on all kernel versions I tried
> 2.6.28/2.6.28.7/2.6.29

Do you mean that the patch applies after removing " @@.*$"?

To be safe, I created the patch with quilt as well as git, for 2.6.29.

> Because I saw the patch only a few hour ago and didn't want to block on your
> reply I decided to patch it manually and in the process ported it to 2.6.29.
> 
> As for the information the patch provided: It is most helpful.
> 
> Attached you will find a list of files containing dirty pages and the count
> of there dirty pages, there is also a dmesg output where I trace the
> writeback for 40 seconds.

They helped, thank you!

> I did some testing on my own using printk's and what I saw is that for the
> inodes located on sdb1 (the database) a lot of times they would pass
> http://lxr.linux.no/linux+v2.6.29/fs/fs-writeback.c#L335
> And then redirty_tail would be called, I haven't had the time to dig deeper,
> but that is my primary suspect for the moment.

You are right. In your case, there are several big dirty files in sdb1,
and the sdb write queue is constantly (almost-)congested. The SSD write
speed is so slow, that in each round of sdb1 writeback, it begins with
an uncongested queue, but quickly fills up after writing some pages.
Hence all the inodes will get redirtied because of (nr_to_write > 0).

The following quick fix should solve the slow-writeback-on-congested-SSD
problem. However the writeback sequence is suboptimal: it sync-and-requeue
each file until congested (in your case about 3~600 pages) instead of
until MAX_WRITEBACK_PAGES=1024 pages.

A more complete fix would be turning MAX_WRITEBACK_PAGES into an exact
per-file limit. It has been sitting in my todo list for quite a while...

Thanks,
Fengguang

---
 fs/fs-writeback.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- mm.orig/fs/fs-writeback.c
+++ mm/fs/fs-writeback.c
@@ -325,7 +325,8 @@ __sync_single_inode(struct inode *inode,
 				 * soon as the queue becomes uncongested.
 				 */
 				inode->i_state |= I_DIRTY_PAGES;
-				if (wbc->nr_to_write <= 0) {
+				if (wbc->nr_to_write <= 0 ||
+				    wbc->encountered_congestion) {
 					/*
 					 * slice used up: queue for next turn
 					 */

--17pEHd4RhPHOinZp
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="writeback-requeue-congestion-quickfix.patch"

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index e3fe991..da5f88d 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -325,7 +325,8 @@ __sync_single_inode(struct inode *inode, struct writeback_control *wbc)
 				 * soon as the queue becomes uncongested.
 				 */
 				inode->i_state |= I_DIRTY_PAGES;
-				if (wbc->nr_to_write <= 0) {
+				if (wbc->nr_to_write <= 0 ||
+				    wbc->encountered_congestion) {
 					/*
 					 * slice used up: queue for next turn
 					 */

--17pEHd4RhPHOinZp--
