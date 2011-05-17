Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21702 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755127Ab1EQOpg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 May 2011 10:45:36 -0400
Date: Tue, 17 May 2011 10:45:32 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond.Myklebust@netapp.com
Cc: Badari Pulavarty <pbadari@us.ibm.com>, linux-nfs@vger.kernel.org
Subject: NFS DIO overhaul
Message-ID: <20110517104532.72b7f588@tlielax.poochiereds.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Trond,

You recently mentioned on the list that you were working on an overhaul
of the DIO code that would merge large parts of it with the buffered IO
routines.

I also started some work on an overhaul of the DIO code to make it work
better with arbitrary sized arrays of iovecs. I've only really started
it, but I have the following routine so far. The idea here is to always
try to max out the size of a direct I/O READ or WRITE regardless of the
layout of the iovec array. Once we have the count, we can then just
marshal up a single read or write and send it, advance the iov_iter and
repeat until we're done.

Obviously, it's rather complicated logic, but I think this is doable...

My question is -- is this something you would consider taking if I were
to finish it up in the near future? Or should I not bother since you're
working on an overhaul of this code?

My main concern is that we have some existing shipping code where we
need to fix this, and  the changes you're planning to make may be too
invasive to backport. If that's the case, then I may need to do
something along these lines anyway (or just take Badari's latest patch).

Thanks...My "starter" patch follows:

------------------------[snip]------------------------

[PATCH] nfs: add a direct I/O count routine

...to count the number of bytes that we can stick in a single r/w req.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/direct.c |   90 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 90 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index c8add8d..15658fe 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -227,6 +227,96 @@ static void nfs_direct_complete(struct nfs_direct_req *dreq)
 }
 
 /*
+ * Walk an iovec array, and count bytes until it hits "maxsize" or until it
+ * hits a "discontinuity" in the array.
+ */
+unsigned int
+nfs_direct_count(const struct iov_iter *i_orig, unsigned int maxsize)
+{
+	struct iov_iter i;
+	unsigned int count = 0, end_of_page, end_of_iov, end_of_seg;
+	unsigned long base;
+
+	/* copy iov_iter so original is preserved */
+	memcpy(&i, i_orig, sizeof(i));
+
+	/*
+	 * Determine how many bytes to end of page. Advance to end of page or
+	 * end of current iovec, or "size" bytes, whichever is closer.
+	 *
+	 * If end of a page, then continue to next page and repeat.
+	 *
+	 * If end of iovec, then see whether current iov ends on
+	 * page boundary and next one starts on one. If so, then
+	 * repeat.
+	 *
+	 * If not, then see if the iov's are "continuous". Are previous
+	 * end and current beginning on same page? If so, then see if
+	 * current end is just before next beginning. If so, repeat.
+	 *
+	 * If none of the conditions above are true, then break and
+	 * return current count of bytes.
+	 */
+	for (;;) {
+		base = (unsigned long)i.iov->iov_base + i.iov_offset;
+
+		/* bytes to end of page */
+		end_of_page = PAGE_SIZE - (base & (PAGE_SIZE - 1));
+
+		/* bytes to end of iov */
+		end_of_iov = i.iov->iov_len - i.iov_offset;
+
+		/* find min of end of page, end of iov, and r/wsize */
+		end_of_seg = min(end_of_page, end_of_iov);
+		end_of_seg = min(end_of_seg, maxsize);
+
+		iov_iter_advance(&i, end_of_seg);
+		maxsize -= end_of_seg;
+		count += end_of_seg;
+
+		/* Did we hit the end of array or maxsize? */
+		if (maxsize - end_of_seg == 0 || i.count == 0)
+			break;
+
+		/*
+		 * Else end_of_seg either == end_of_page or end_of_iov,
+		 * and iov has more data in it.
+		 */
+
+		/* Did we hit a page boundary, but next segement is in same
+		 * iov? If so, then carry on.
+		 */
+		if (end_of_page != end_of_iov && end_of_seg == end_of_page)
+			goto advance_ii;
+
+		/* Did iov end on a page boundary? Ensure next starts on one. */
+		if (end_of_page == end_of_iov &&
+		    (unsigned long)i.iov[1].iov_base & (PAGE_SIZE - 1))
+			break;
+
+		/* Make sure next iovec starts on same page as first */
+		if ((base & PAGE_MASK) !=
+		    ((unsigned long)i.iov[1].iov_base & PAGE_MASK))
+			break;
+
+		/* and the offsets match up */
+		if (end_of_iov + 1 != (unsigned long)i.iov[1].iov_base)
+			break;
+
+advance_ii:
+		/* Everything checks out. Advance into next iov and continue */
+		iov_iter_advance(&i, 1);
+		--maxsize;
+		++count;
+		/* Did we hit the end of array or maxsize? */
+		if (maxsize == 0 || i.count == 0)
+			break;
+	}
+
+	return count;
+}
+
+/*
  * We must hold a reference to all the pages in this direct read request
  * until the RPCs complete.  This could be long *after* we are woken up in
  * nfs_direct_wait (for instance, if someone hits ^C on a slow server).
-- 
1.7.1



-- 
Jeff Layton <jlayton@redhat.com>
