Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:48135 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073Ab1FNCcs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 22:32:48 -0400
Message-Id: <41abe6e718f2626cd4622c534bb9a0d7e9abfe93.1308017749.git.rees@umich.edu>
In-Reply-To: <cover.1308017749.git.rees@umich.edu>
References: <cover.1308017749.git.rees@umich.edu>
Subject: [PATCH 18/33] pnfsblock: allow use of PG_owner_priv_1 flag
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Mon, 13 Jun 2011 22:32:46 -0400
From: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

There is currently no good way for pnfs to communicate problems.  For
example - the linux read code first tries to do readahead through
nfs_readpages. Failure there is ignored, and it will later call
nfs_readpage.  Failure there is also ignored, except that the lack of
PG_uptodate is communicated back via -EIO.

With pnfs, it would be useful to be able to communicate to
nfs_readpage that direct disk IO failed on readahead, and that it
should failover to using the MDS.

Making the page flag PG_owner_priv_1 available as PG_pnfserr is one
way to do so. (An alternative would be to embed this in the layout,
but then pg_test can't easily access the info.)

This may be better as generic pnfs code, in which case it should be
put in pnfs.h, or even page-flags.h

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index a596e75..0a54feb 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -35,6 +35,11 @@
 #include <linux/nfs_fs.h>
 #include "../pnfs.h"
 
+#define PG_pnfserr PG_owner_priv_1
+#define PagePnfsErr(page)	test_bit(PG_pnfserr, &(page)->flags)
+#define SetPagePnfsErr(page)	set_bit(PG_pnfserr, &(page)->flags)
+#define ClearPagePnfsErr(page)	clear_bit(PG_pnfserr, &(page)->flags)
+
 struct block_mount_id {
 	spinlock_t			bm_lock;    /* protects list */
 	struct list_head		bm_devlist; /* holds pnfs_block_dev */
-- 
1.7.4.1

