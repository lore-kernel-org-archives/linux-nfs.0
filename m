Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:43872 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753634AbaKHMK7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 8 Nov 2014 07:10:59 -0500
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] nfsd: correctly define v4.2 support attributes
Date: Sat,  8 Nov 2014 13:11:03 +0100
Message-Id: <1415448664-25815-2-git-send-email-hch@lst.de>
In-Reply-To: <1415448664-25815-1-git-send-email-hch@lst.de>
References: <1415448664-25815-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Even when security labels are disabled we support at least the same
attributes as v4.1.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfsd.h | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 747f3b95..43b6a36 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -335,12 +335,15 @@ void		nfsd_lockd_shutdown(void);
 	(NFSD4_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SUPPATTR_EXCLCREAT)
 
 #ifdef CONFIG_NFSD_V4_SECURITY_LABEL
-#define NFSD4_2_SUPPORTED_ATTRS_WORD2 \
-	(NFSD4_1_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SECURITY_LABEL)
+#define NFSD4_2_SECURITY_ATTRS		FATTR4_WORD2_SECURITY_LABEL
 #else
-#define NFSD4_2_SUPPORTED_ATTRS_WORD2 0
+#define NFSD4_2_SECURITY_ATTRS		9
 #endif
 
+#define NFSD4_2_SUPPORTED_ATTRS_WORD2 \
+	(NFSD4_1_SUPPORTED_ATTRS_WORD2 | \
+	NFSD4_2_SECURITY_ATTRS)
+
 static inline u32 nfsd_suppattrs0(u32 minorversion)
 {
 	return minorversion ? NFSD4_1_SUPPORTED_ATTRS_WORD0
-- 
1.9.1

