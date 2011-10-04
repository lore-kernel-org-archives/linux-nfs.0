Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:52173 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755701Ab1JDKer (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Oct 2011 06:34:47 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>, Brent Welch <welch@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 12/19] ore/exofs: Change ore_check_io API
Date: Tue, 4 Oct 2011 12:34:37 +0200
Message-ID: <1317724477-27672-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4E8ADEDA.4050709@panasas.com>
References: <4E8ADEDA.4050709@panasas.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Current ore_check_io API receives a residual
pointer, to report partial IO. But it is actually
not used, because in a multiple devices IO there
is never a linearity in the IO failure.

On the other hand if every failing device is reported
through a received callback measures can be taken to
handle only failed devices. One at a time.

This will also be needed by the objects-layout-driver
for it's error reporting facility.

Exofs is not currently using the new information and
keeps the old behaviour of failing the complete IO in
case of an error. (No partial completion)

TODO: Use an ore_check_io callback to set_page_error only
the failing pages. And re-dirty write pages.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/inode.c       |   14 ++++----------
 fs/exofs/ore.c         |   29 ++++++++++++++++-------------
 include/scsi/osd_ore.h |    5 ++++-
 3 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/fs/exofs/inode.c b/fs/exofs/inode.c
index 7b1a4ba..69dc236 100644
--- a/fs/exofs/inode.c
+++ b/fs/exofs/inode.c
@@ -194,19 +194,16 @@ static void update_write_page(struct page *page, int ret)
 static int __readpages_done(struct page_collect *pcol)
 {
 	int i;
-	u64 resid;
 	u64 good_bytes;
 	u64 length = 0;
-	int ret = ore_check_io(pcol->ios, &resid);
+	int ret = ore_check_io(pcol->ios, NULL);
 
 	if (likely(!ret)) {
 		good_bytes = pcol->length;
 		ret = PAGE_WAS_NOT_IN_IO;
 	} else {
-		good_bytes = pcol->length - resid;
+		good_bytes = 0;
 	}
-	if (good_bytes > pcol->ios->length)
-		good_bytes = pcol->ios->length;
 
 	EXOFS_DBGMSG2("readpages_done(0x%lx) good_bytes=0x%llx"
 		     " length=0x%lx nr_pages=%u\n",
@@ -519,10 +516,9 @@ static void writepages_done(struct ore_io_state *ios, void *p)
 {
 	struct page_collect *pcol = p;
 	int i;
-	u64 resid;
 	u64  good_bytes;
 	u64  length = 0;
-	int ret = ore_check_io(ios, &resid);
+	int ret = ore_check_io(ios, NULL);
 
 	atomic_dec(&pcol->sbi->s_curr_pending);
 
@@ -530,10 +526,8 @@ static void writepages_done(struct ore_io_state *ios, void *p)
 		good_bytes = pcol->length;
 		ret = PAGE_WAS_NOT_IN_IO;
 	} else {
-		good_bytes = pcol->length - resid;
+		good_bytes = 0;
 	}
-	if (good_bytes > pcol->ios->length)
-		good_bytes = pcol->ios->length;
 
 	EXOFS_DBGMSG2("writepages_done(0x%lx) good_bytes=0x%llx"
 		     " length=0x%lx nr_pages=%u\n",
diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index 14a9100..0dafd50 100644
--- a/fs/exofs/ore.c
+++ b/fs/exofs/ore.c
@@ -317,7 +317,7 @@ static void _clear_bio(struct bio *bio)
 	}
 }
 
-int ore_check_io(struct ore_io_state *ios, u64 *resid)
+int ore_check_io(struct ore_io_state *ios, ore_on_dev_error on_dev_error)
 {
 	enum osd_err_priority acumulated_osd_err = 0;
 	int acumulated_lin_err = 0;
@@ -325,7 +325,8 @@ int ore_check_io(struct ore_io_state *ios, u64 *resid)
 
 	for (i = 0; i < ios->numdevs; i++) {
 		struct osd_sense_info osi;
-		struct osd_request *or = ios->per_dev[i].or;
+		struct ore_per_dev_state *per_dev = &ios->per_dev[i];
+		struct osd_request *or = per_dev->or;
 		int ret;
 
 		if (unlikely(!or))
@@ -337,29 +338,31 @@ int ore_check_io(struct ore_io_state *ios, u64 *resid)
 
 		if (OSD_ERR_PRI_CLEAR_PAGES == osi.osd_err_pri) {
 			/* start read offset passed endof file */
-			_clear_bio(ios->per_dev[i].bio);
+			_clear_bio(per_dev->bio);
 			ORE_DBGMSG("start read offset passed end of file "
 				"offset=0x%llx, length=0x%llx\n",
-				_LLU(ios->per_dev[i].offset),
-				_LLU(ios->per_dev[i].length));
+				_LLU(per_dev->offset),
+				_LLU(per_dev->length));
 
 			continue; /* we recovered */
 		}
 
+		if (on_dev_error) {
+			u64 residual = ios->reading ?
+					or->in.residual : or->out.residual;
+			u64 offset = (ios->offset + ios->length) - residual;
+			struct ore_dev *od = ios->oc->ods[
+					per_dev->dev - ios->oc->first_dev];
+
+			on_dev_error(ios, od, per_dev->dev, osi.osd_err_pri,
+				     offset, residual);
+		}
 		if (osi.osd_err_pri >= acumulated_osd_err) {
 			acumulated_osd_err = osi.osd_err_pri;
 			acumulated_lin_err = ret;
 		}
 	}
 
-	/* TODO: raid specific residual calculations */
-	if (resid) {
-		if (likely(!acumulated_lin_err))
-			*resid = 0;
-		else
-			*resid = ios->length;
-	}
-
 	return acumulated_lin_err;
 }
 EXPORT_SYMBOL(ore_check_io);
diff --git a/include/scsi/osd_ore.h b/include/scsi/osd_ore.h
index 716dbea..af2231a 100644
--- a/include/scsi/osd_ore.h
+++ b/include/scsi/osd_ore.h
@@ -153,7 +153,10 @@ int ore_get_io_state(struct ore_layout *layout, struct ore_components *comps,
 		     struct ore_io_state **ios);
 void ore_put_io_state(struct ore_io_state *ios);
 
-int ore_check_io(struct ore_io_state *ios, u64 *resid);
+typedef void (*ore_on_dev_error)(struct ore_io_state *ios, struct ore_dev *od,
+	unsigned dev_index, enum osd_err_priority oep,
+	u64 dev_offset, u64  dev_len);
+int ore_check_io(struct ore_io_state *ios, ore_on_dev_error rep);
 
 int ore_create(struct ore_io_state *ios);
 int ore_remove(struct ore_io_state *ios);
-- 
1.7.2.3

