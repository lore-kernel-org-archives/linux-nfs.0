Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f174.google.com ([209.85.160.174]:36329 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262AbbIQM2r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Sep 2015 08:28:47 -0400
Received: by ykdt18 with SMTP id t18so14795304ykd.3
        for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2015 05:28:47 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Andreas Dilger <andreas.dilger@intel.com>
Subject: [PATCH 1/2] nfsd: move svc_fh->fh_maxsize to just after fh_handle
Date: Thu, 17 Sep 2015 08:28:38 -0400
Message-Id: <1442492919-31842-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This moves the hole in the struct down below the flags fields, which
allows us to potentially add a new flag without growing the struct.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfsfh.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
index 1e90dad4926b..b1edd6bf40e1 100644
--- a/fs/nfsd/nfsfh.h
+++ b/fs/nfsd/nfsfh.h
@@ -26,9 +26,9 @@ static inline ino_t u32_to_ino_t(__u32 uino)
  */
 typedef struct svc_fh {
 	struct knfsd_fh		fh_handle;	/* FH data */
+	int			fh_maxsize;	/* max size for fh_handle */
 	struct dentry *		fh_dentry;	/* validated dentry */
 	struct svc_export *	fh_export;	/* export pointer */
-	int			fh_maxsize;	/* max size for fh_handle */
 
 	unsigned char		fh_locked;	/* inode locked by us */
 	unsigned char		fh_want_write;	/* remount protection taken */
-- 
2.4.3

