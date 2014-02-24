Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58764 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752896AbaBXWIv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Feb 2014 17:08:51 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>, stable@vger.kernel.org
Subject: [PATCH 2/5] nfsd4: leave reply buffer space for failed setattr
Date: Mon, 24 Feb 2014 17:08:44 -0500
Message-Id: <1393279727-29437-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1393279727-29437-1-git-send-email-bfields@redhat.com>
References: <1393279727-29437-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This fixes an ommission from 18032ca062e621e15683cb61c066ef3dc5414a7b
"NFSD: Server implementation of MAC Labeling", which increased the size
of the setattr error reply without increasing COMPOUND_ERR_SLACK_SPACE.

Cc: stable@vger.kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfsd.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 30f34ab..479eb68 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -282,7 +282,7 @@ void		nfsd_lockd_shutdown(void);
  * reason.
  */
 #define	COMPOUND_SLACK_SPACE		140    /* OP_GETFH */
-#define COMPOUND_ERR_SLACK_SPACE	12     /* OP_SETATTR */
+#define COMPOUND_ERR_SLACK_SPACE	16     /* OP_SETATTR */
 
 #define NFSD_LAUNDROMAT_MINTIMEOUT      1   /* seconds */
 
-- 
1.7.9.5

