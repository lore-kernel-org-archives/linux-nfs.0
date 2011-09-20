Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:40749 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753759Ab1ITDXs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Sep 2011 23:23:48 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@tonian.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 1/3] pnfsblock: fix NULL pointer dereference
Date: Mon, 19 Sep 2011 23:23:43 -0400
Message-Id: <1316489025-24991-2-git-send-email-rees@umich.edu>
In-Reply-To: <1316489025-24991-1-git-send-email-rees@umich.edu>
References: <1316489025-24991-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Peng Tao <bergwolf@gmail.com>

bl_add_page_to_bio returns error pointer. bio should be reset to
NULL in failure cases as the out path always calls bl_submit_bio.

Signed-off-by: Peng Tao <peng_tao@emc.com>
Signed-off-by: Jim Rees <rees@umich.edu>
---
 fs/nfs/blocklayout/blocklayout.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 1038b8c..8d06d5c 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -292,6 +292,7 @@ bl_read_pagelist(struct nfs_read_data *rdata)
 						 bl_end_io_read, par);
 			if (IS_ERR(bio)) {
 				rdata->pnfs_error = PTR_ERR(bio);
+				bio = NULL;
 				goto out;
 			}
 		}
@@ -581,6 +582,7 @@ fill_invalid_ext:
 						 bl_end_io_write_zero, par);
 			if (IS_ERR(bio)) {
 				wdata->pnfs_error = PTR_ERR(bio);
+				bio = NULL;
 				goto out;
 			}
 			/* FIXME: This should be done in bi_end_io */
@@ -629,6 +631,7 @@ next_page:
 					 bl_end_io_write, par);
 		if (IS_ERR(bio)) {
 			wdata->pnfs_error = PTR_ERR(bio);
+			bio = NULL;
 			goto out;
 		}
 		isect += PAGE_CACHE_SECTORS;
-- 
1.7.4.1

