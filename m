From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: Kernel 2.6.23.17 crash (Was: Kernel (2.6.24) crash on nfsd  (BUG: soft lockup))
Date: Sat, 1 Mar 2008 18:03:23 +0100
Message-ID: <20080301170322.GY6704@kernel.dk>
References: <47C434D2.80601@byte.nl> <47C50754.5030107@byte.nl> <47C50ABB.8050700@byte.nl> <Pine.LNX.4.62.0802281153040.31013@office2.c1.internal> <20080301163944.GC19927@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Allard Hoeve <allard-DW70C6hi67U@public.gmane.org>, linux-nfs@vger.kernel.org,
	"Nilssen, Rune" <rune.nilssen-FJFKJQU35qU@public.gmane.org>,
	Gertjan Oude Lohuis <gertjan-DW70C6hi67U@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from brick.kernel.dk ([87.55.233.238]:19440 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752104AbYCARD2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 1 Mar 2008 12:03:28 -0500
In-Reply-To: <20080301163944.GC19927@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 01 2008, J. Bruce Fields wrote:
> On Thu, Feb 28, 2008 at 11:56:51AM +0100, Allard Hoeve wrote:
> > After trying 2.6.23.17, the same happened. The stacktrace is a bit  
> > different, but they are comparable.
> >
> > Is this an NFS problem in the first place? Where could we go for help 
> > with this problem?
> 
> Thanks for the reports!
> 
> So, the summary: several people are reporting soft lockup warnings with
> _generic_file_splice_read as the latest or next-to-latest function on
> the stack.  Sounds like 2.6.18 is good, various kernels around 2.6.23
> and 2.6.24 are reported bad.  Is it possible this was a regression
> introduced by the splice changes?

I posted this two days ago, but didn't get a reply back regarding if
anyone who can reproduce tested it?

diff --git a/fs/splice.c b/fs/splice.c
index 9b559ee..0254ec6 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -370,8 +370,10 @@ __generic_file_splice_read(struct file *in, loff_t *ppos,
 			 * for an in-flight io page
 			 */
 			if (flags & SPLICE_F_NONBLOCK) {
-				if (TestSetPageLocked(page))
+				if (TestSetPageLocked(page)) {
+					error = -EAGAIN;
 					break;
+				}
 			} else
 				lock_page(page);
 
@@ -479,9 +481,8 @@ ssize_t generic_file_splice_read(struct file *in, loff_t *ppos,
 				 struct pipe_inode_info *pipe, size_t len,
 				 unsigned int flags)
 {
-	ssize_t spliced;
-	int ret;
 	loff_t isize, left;
+	int ret;
 
 	isize = i_size_read(in->f_mapping->host);
 	if (unlikely(*ppos >= isize))
@@ -491,29 +492,9 @@ ssize_t generic_file_splice_read(struct file *in, loff_t *ppos,
 	if (unlikely(left < len))
 		len = left;
 
-	ret = 0;
-	spliced = 0;
-	while (len && !spliced) {
-		ret = __generic_file_splice_read(in, ppos, pipe, len, flags);
-
-		if (ret < 0)
-			break;
-		else if (!ret) {
-			if (spliced)
-				break;
-			if (flags & SPLICE_F_NONBLOCK) {
-				ret = -EAGAIN;
-				break;
-			}
-		}
-
+	ret = __generic_file_splice_read(in, ppos, pipe, len, flags);
+	if (ret > 0)
 		*ppos += ret;
-		len -= ret;
-		spliced += ret;
-	}
-
-	if (spliced)
-		return spliced;
 
 	return ret;
 }

-- 
Jens Axboe

