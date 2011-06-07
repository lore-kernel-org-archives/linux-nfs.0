Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:51784 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754744Ab1FGRdZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:33:25 -0400
Date: Tue, 7 Jun 2011 13:33:23 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 62/88] SQUASHME: pnfs-block: use new commit api
Message-ID: <c96a97eb48ee26ba7b13675383043d918ba2ead0.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 63d3b5a..e2ee90a 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -99,9 +99,8 @@ dont_like_caller(struct nfs_page *req)
 }
 
 static enum pnfs_try_status
-bl_commit(struct pnfs_layout_type *lo,
-		int sync,
-		struct nfs_write_data *nfs_data)
+bl_commit(struct nfs_write_data *nfs_data,
+	  int sync)
 {
 	dprintk("%s enter\n", __func__);
 	return PNFS_NOT_ATTEMPTED;
-- 
1.7.4.1

