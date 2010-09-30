Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:22774 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755010Ab0I3TUm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Sep 2010 15:20:42 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] SQUASHME: pnfsd: FATTR4_WORD2_LAYOUT_BLKSIZE is supported only under CONFIG_PNFSD
Date: Thu, 30 Sep 2010 21:20:37 +0200
Message-Id: <1285874437-21483-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <1285872478-21045-1-git-send-email-bhalevy@panasas.com>
References: <1285872478-21045-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfsd.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index d89d30c..cef6770 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -294,9 +294,14 @@ extern time_t nfsd4_grace;
 	NFSD4_SUPPORTED_ATTRS_WORD1
 #endif /* CONFIG_PNFSD */
 
+#if defined(CONFIG_PNFSD)
 #define NFSD4_1_SUPPORTED_ATTRS_WORD2 \
 	(NFSD4_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SUPPATTR_EXCLCREAT | \
 	 FATTR4_WORD2_LAYOUT_BLKSIZE)
+#else /* CONFIG_PNFSD */
+#define NFSD4_1_SUPPORTED_ATTRS_WORD2 \
+	(NFSD4_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SUPPATTR_EXCLCREAT)
+#endif /* CONFIG_PNFSD */
 
 static inline u32 nfsd_suppattrs0(u32 minorversion)
 {
-- 
1.7.2.3

