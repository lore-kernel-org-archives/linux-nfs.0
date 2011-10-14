Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:33270 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753960Ab1JNR0z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Oct 2011 13:26:55 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Brent Welch <welch@panasas.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH] SQUASHME: into: ore: Only IO one group at a time (API change)
Date: Fri, 14 Oct 2011 19:26:40 +0200
Message-ID: <1318613200-3547-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4E98703E.7040605@panasas.com>
References: <4E98703E.7040605@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To re submit a page that went through write_cache_pages()
(Recived on writepage_t) We need to take it out of
write_back and into set_page_dirty(). Then it will be
resubmitted again just fine. Checked!

And one more fix for the ios->numdevs.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
git diff --stat -p -M origin/linux-next 201e3d7b
 fs/exofs/inode.c |   15 ++++++++++-----
 fs/exofs/ore.c   |    6 +-----
 2 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/fs/exofs/inode.c b/fs/exofs/inode.c
index 69dc236..0c522c6 100644
--- a/fs/exofs/inode.c
+++ b/fs/exofs/inode.c
@@ -295,7 +295,7 @@ static int _maybe_not_all_in_one_io(struct ore_io_state *ios,
 		for (i = 0; i < pages_less; ++i)
 			pcol->pages[i] = *src_page++;
 
-		EXOFS_DBGMSG("Length was adjusted nr_pages=0x%x pages_less=%d "
+		EXOFS_DBGMSG("Length was adjusted nr_pages=0x%x pages_less=0x%x "
 			"expected_pages=0x%x next_offset=0x%llx "
 			"next_len=0x%lx\n",
 			pcol_src->nr_pages, pages_less, pcol->expected_pages,
@@ -758,14 +758,19 @@ static int exofs_writepages(struct address_space *mapping,
 
 	if (wbc->sync_mode == WB_SYNC_ALL) {
 		return write_exec(&pcol); /* pump the last reminder */
-	} else {/* not SYNC let the reminder join the next writeout */
+	} else if (pcol.nr_pages) {
+		/* not SYNC let the reminder join the next writeout */
 		unsigned i;
 
-		for (i = 0; i < pcol.nr_pages; i++)
-			unlock_page(pcol.pages[i]);
+		for (i = 0; i < pcol.nr_pages; i++) {
+			struct page *page = pcol.pages[i];
 
-		return 0;
+			end_page_writeback(page);
+			set_page_dirty(page);
+			unlock_page(page);
+		}
 	}
+	return 0;
 }
 
 static int exofs_writepage(struct page *page, struct writeback_control *wbc)
diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index 0dafd50..3b1cc3a 100644
--- a/fs/exofs/ore.c
+++ b/fs/exofs/ore.c
@@ -506,7 +506,6 @@ static int _prepare_for_striping(struct ore_io_state *ios)
 	unsigned devs_in_group = ios->layout->group_width * mirrors_p1;
 	unsigned dev = si->dev;
 	unsigned first_dev = dev - (dev % devs_in_group);
-	unsigned max_comp = ios->numdevs ? ios->numdevs - mirrors_p1 : 0;
 	unsigned cur_pg = ios->pages_consumed;
 	u64 length = ios->length;
 	int ret = 0;
@@ -538,9 +537,6 @@ static int _prepare_for_striping(struct ore_io_state *ios)
 				per_dev->offset = si->obj_offset - si->unit_off;
 				cur_len = stripe_unit;
 			}
-
-			if (max_comp < comp)
-				max_comp = comp;
 		} else {
 			cur_len = stripe_unit;
 		}
@@ -558,7 +554,7 @@ static int _prepare_for_striping(struct ore_io_state *ios)
 		length -= cur_len;
 	}
 out:
-	ios->numdevs = max_comp + mirrors_p1;
+	ios->numdevs = devs_in_group;
 	ios->pages_consumed = cur_pg;
 	if (unlikely(ret)) {
 		if (length == ios->length)
