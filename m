Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:52137 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755827Ab1JDKcu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Oct 2011 06:32:50 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>, Brent Welch <welch@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 09/19] ore: Support for short read/writes
Date: Tue, 4 Oct 2011 12:32:41 +0200
Message-ID: <1317724361-27575-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4E8ADEDA.4050709@panasas.com>
References: <4E8ADEDA.4050709@panasas.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Memory conditions and max_bio constraints might cause us to
not comply to the full length of the requested IO. Instead of
failing the complete IO we can issue a shorter read/write and
report how much was actually executed in the ios->length
member.

All users must check ios->length at IO_done or upon return of
ore_read/write and re-issue the reminder of the bytes. Because
other wise there is no error returned like before.

This is part of the effort to support the pnfs-obj layout driver.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/ore.c |   30 +++++++++++++++++++++++-------
 1 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index 2f39f23..0b992e1 100644
--- a/fs/exofs/ore.c
+++ b/fs/exofs/ore.c
@@ -377,8 +377,8 @@ static int _add_stripe_unit(struct ore_io_state *ios,  unsigned *cur_pg,
 	unsigned pg = *cur_pg;
 	struct request_queue *q =
 			osd_request_queue(_ios_od(ios, per_dev->dev));
-
-	per_dev->length += cur_len;
+	unsigned len = cur_len;
+	int ret;
 
 	if (per_dev->bio == NULL) {
 		unsigned pages_in_stripe = ios->layout->group_width *
@@ -390,7 +390,8 @@ static int _add_stripe_unit(struct ore_io_state *ios,  unsigned *cur_pg,
 		if (unlikely(!per_dev->bio)) {
 			ORE_DBGMSG("Failed to allocate BIO size=%u\n",
 				     bio_size);
-			return -ENOMEM;
+			ret = -ENOMEM;
+			goto out;
 		}
 	}
 
@@ -403,15 +404,24 @@ static int _add_stripe_unit(struct ore_io_state *ios,  unsigned *cur_pg,
 
 		added_len = bio_add_pc_page(q, per_dev->bio, ios->pages[pg],
 					    pglen, pgbase);
-		if (unlikely(pglen != added_len))
-			return -ENOMEM;
+		if (unlikely(pglen != added_len)) {
+			ret = -ENOMEM;
+			goto out;
+		}
 		pgbase = 0;
 		++pg;
 	}
 	BUG_ON(cur_len);
 
+	per_dev->length += len;
 	*cur_pg = pg;
-	return 0;
+	ret = 0;
+out:	/* we fail the complete unit on an error eg don't advance
+	 * per_dev->length and cur_pg. This means that we might have a bigger
+	 * bio than the CDB requested length (per_dev->length). That's fine
+	 * only the oposite is fatal.
+	 */
+	return ret;
 }
 
 static int _prepare_for_striping(struct ore_io_state *ios)
@@ -476,7 +486,13 @@ static int _prepare_for_striping(struct ore_io_state *ios)
 out:
 	ios->numdevs = max_comp + mirrors_p1;
 	ios->pages_consumed = cur_pg;
-	return ret;
+	if (unlikely(ret)) {
+		if (length == ios->length)
+			return ret;
+		else
+			ios->length -= length;
+	}
+	return 0;
 }
 
 int ore_create(struct ore_io_state *ios)
-- 
1.7.2.3

