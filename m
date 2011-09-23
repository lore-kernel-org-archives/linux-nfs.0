Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:37196 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754742Ab1IWBub (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2011 21:50:31 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 09/10] pnfsblock: fix NULL pointer dereference
Date: Thu, 22 Sep 2011 21:50:16 -0400
Message-Id: <1316742617-14766-10-git-send-email-rees@umich.edu>
In-Reply-To: <1316742617-14766-1-git-send-email-rees@umich.edu>
References: <1316742617-14766-1-git-send-email-rees@umich.edu>
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
index f5a7fa6..cc63717 100644
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

