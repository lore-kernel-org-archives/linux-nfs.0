Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:52122 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755646Ab1JDKcK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Oct 2011 06:32:10 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>, Brent Welch <welch@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 08/19] exofs: Support for short read/writes
Date: Tue, 4 Oct 2011 12:32:00 +0200
Message-ID: <1317724320-27544-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4E8ADEDA.4050709@panasas.com>
References: <4E8ADEDA.4050709@panasas.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

If at read/write_done the actual IO was shorter then requested,
reported in returned ios->length. It is not an error. The reminder
of the pages should just be unlocked but not marked uptodate or
end_page_writeback. They will be re issued later by the VFS.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/inode.c |   35 ++++++++++++++++++++++++++---------
 1 files changed, 26 insertions(+), 9 deletions(-)

diff --git a/fs/exofs/inode.c b/fs/exofs/inode.c
index 14e408b..0afe761 100644
--- a/fs/exofs/inode.c
+++ b/fs/exofs/inode.c
@@ -149,14 +149,17 @@ static int pcol_add_page(struct page_collect *pcol, struct page *page,
 	return 0;
 }
 
+enum {PAGE_WAS_NOT_IN_IO = 17};
 static int update_read_page(struct page *page, int ret)
 {
-	if (ret == 0) {
+	switch (ret) {
+	case 0:
 		/* Everything is OK */
 		SetPageUptodate(page);
 		if (PageError(page))
 			ClearPageError(page);
-	} else if (ret == -EFAULT) {
+		break;
+	case -EFAULT:
 		/* In this case we were trying to read something that wasn't on
 		 * disk yet - return a page full of zeroes.  This should be OK,
 		 * because the object should be empty (if there was a write
@@ -167,16 +170,22 @@ static int update_read_page(struct page *page, int ret)
 		SetPageUptodate(page);
 		if (PageError(page))
 			ClearPageError(page);
-		ret = 0; /* recovered error */
 		EXOFS_DBGMSG("recovered read error\n");
-	} else /* Error */
+		/* fall through */
+	case PAGE_WAS_NOT_IN_IO:
+		ret = 0; /* recovered error */
+		break;
+	default:
 		SetPageError(page);
-
+	}
 	return ret;
 }
 
 static void update_write_page(struct page *page, int ret)
 {
+	if (unlikely(ret == PAGE_WAS_NOT_IN_IO))
+		return; /* don't pass start don't collect $200 */
+
 	if (ret) {
 		mapping_set_error(page->mapping, ret);
 		SetPageError(page);
@@ -195,10 +204,14 @@ static int __readpages_done(struct page_collect *pcol)
 	u64 length = 0;
 	int ret = ore_check_io(pcol->ios, &resid);
 
-	if (likely(!ret))
+	if (likely(!ret)) {
 		good_bytes = pcol->length;
-	else
+		ret = PAGE_WAS_NOT_IN_IO;
+	} else {
 		good_bytes = pcol->length - resid;
+	}
+	if (good_bytes > pcol->ios->length)
+		good_bytes = pcol->ios->length;
 
 	EXOFS_DBGMSG2("readpages_done(0x%lx) good_bytes=0x%llx"
 		     " length=0x%lx nr_pages=%u\n",
@@ -518,10 +531,14 @@ static void writepages_done(struct ore_io_state *ios, void *p)
 
 	atomic_dec(&pcol->sbi->s_curr_pending);
 
-	if (likely(!ret))
+	if (likely(!ret)) {
 		good_bytes = pcol->length;
-	else
+		ret = PAGE_WAS_NOT_IN_IO;
+	} else {
 		good_bytes = pcol->length - resid;
+	}
+	if (good_bytes > pcol->ios->length)
+		good_bytes = pcol->ios->length;
 
 	EXOFS_DBGMSG2("writepages_done(0x%lx) good_bytes=0x%llx"
 		     " length=0x%lx nr_pages=%u\n",
-- 
1.7.2.3

