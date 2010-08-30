Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:22068 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755981Ab0H3QoO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Aug 2010 12:44:14 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@panasas.com>, Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH 4/4] SQUASHME: pnfs-obj use REQ flags rather than BIO flags
Date: Mon, 30 Aug 2010 19:44:11 +0300
Message-Id: <1283186651-17118-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4C7BDD8C.40509@panasas.com>
References: <4C7BDD8C.40509@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

As they were converged starting 2.6.36

Cc: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 316f9c5..223980b 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -910,7 +910,7 @@ static int _write_mirrors(struct objio_state *ios, unsigned cur_comp)
 		} else {
 			bio = master_dev->bio;
 			/* FIXME: bio_set_dir() */
-			bio->bi_rw |= (1 << BIO_RW);
+			bio->bi_rw |= (1 << REQ_WRITE);
 		}
 
 		osd_req_write(or, &obj, per_dev->offset, bio, per_dev->length);
-- 
1.7.2.2

