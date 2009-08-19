From: Jan Kara <jack@suse.cz>
Subject: [PATCH 16/17] nfs: Remove reference to generic_osync_inode from a comment
Date: Wed, 19 Aug 2009 18:04:43 +0200
Message-ID: <1250697884-22288-17-git-send-email-jack@suse.cz>
References: <1250697884-22288-1-git-send-email-jack@suse.cz>
Cc: hch@infradead.org, Jan Kara <jack@suse.cz>,
	linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:55958 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751953AbZHSQEs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 12:04:48 -0400
In-Reply-To: <1250697884-22288-1-git-send-email-jack@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

generic_file_direct_write() no longer calls generic_osync_inode() so remove the
comment.

CC: linux-nfs@vger.kernel.org
CC: Neil Brown <neilb@suse.de>
CC: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/nfs/direct.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 489fc01..fd5fcc9 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -934,9 +934,6 @@ out:
  * back into its cache.  We let the server do generic write
  * parameter checking and report problems.
  *
- * We also avoid an unnecessary invocation of generic_osync_inode(),
- * as it is fairly meaningless to sync the metadata of an NFS file.
- *
  * We eliminate local atime updates, see direct read above.
  *
  * We avoid unnecessary page cache invalidations for normal cached
-- 
1.6.0.2

