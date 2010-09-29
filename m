Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:20254 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753277Ab0I2LMb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 07:12:31 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 16/17] SQUASHME: pnfs-obj: fix REQ flags usage
Date: Wed, 29 Sep 2010 13:12:29 +0200
Message-Id: <1285758749-27305-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4CA31DC3.8070300@panasas.com>
References: <4CA31DC3.8070300@panasas.com>
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
1.7.2.3

