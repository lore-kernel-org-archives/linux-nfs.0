Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:2577 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753872Ab0IMUI0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 16:08:26 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: bharrosh@panasas.com
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>,
        Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH] SQUASHME: pnfs-obj: fix REQ flags usage
Date: Mon, 13 Sep 2010 22:08:22 +0200
Message-Id: <1284408502-21898-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

fixes "pnfs-obj use REQ flags rather than BIO flags"

Cc: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 223980b..75d5df4 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -910,7 +910,7 @@ static int _write_mirrors(struct objio_state *ios, unsigned cur_comp)
 		} else {
 			bio = master_dev->bio;
 			/* FIXME: bio_set_dir() */
-			bio->bi_rw |= (1 << REQ_WRITE);
+			bio->bi_rw |= REQ_WRITE;
 		}
 
 		osd_req_write(or, &obj, per_dev->offset, bio, per_dev->length);
-- 
1.7.2.2

