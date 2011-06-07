Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:53566 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755510Ab1FGR3B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:29:01 -0400
Date: Tue, 7 Jun 2011 13:28:59 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 26/88] pnfsblock: allow use of PG_owner_priv_1 flag
Message-ID: <000c46737b1da856c36c79afdd515f1a2e13f6ad.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
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
index 8b06c93..493d4d3 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -37,6 +37,11 @@
 #include <linux/nfs4_pnfs.h>
 #include <linux/dm-ioctl.h> /* Needed for struct dm_ioctl*/
 
+#define PG_pnfserr PG_owner_priv_1
+#define PagePnfsErr(page)	test_bit(PG_pnfserr, &(page)->flags)
+#define SetPagePnfsErr(page)	set_bit(PG_pnfserr, &(page)->flags)
+#define ClearPagePnfsErr(page)	clear_bit(PG_pnfserr, &(page)->flags)
+
 extern struct class shost_class; /* exported from drivers/scsi/hosts.c */
 extern int dm_dev_create(struct dm_ioctl *param); /* from dm-ioctl.c */
 extern int dm_dev_remove(struct dm_ioctl *param); /* from dm-ioctl.c */
-- 
1.7.4.1

