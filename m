Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:39888 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553Ab3IZSl4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:41:56 -0400
Received: by mail-qc0-f169.google.com with SMTP id c9so1044387qcz.14
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:41:56 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 30/49] pnfsd: make pnfs server return layout_blksize when the client asks for it
Date: Thu, 26 Sep 2013 14:41:53 -0400
Message-Id: <1380220913-14054-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tao Guo <glorioustao@gmail.com>

Signed-off-by: Tao Guo <glorioustao@gmail.com>
[pnfsd: FATTR4_WORD2_LAYOUT_BLKSIZE is supported only under CONFIG_PNFSD]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4xdr.c | 6 ++++++
 fs/nfsd/nfsd.h    | 6 ++++++
 2 files changed, 12 insertions(+)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 83f7147..6781a33 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2583,6 +2583,12 @@ static int get_parent_attributes(struct svc_export *exp, struct kstat *stat)
 		} else
 			WRITE32(0);  /* length */
 	}
+
+	if (bmval2 & FATTR4_WORD2_LAYOUT_BLKSIZE) {
+		if ((buflen -= 4) < 0)
+			goto out_resource;
+		WRITE32(stat.blksize);
+	}
 #endif /* CONFIG_PNFSD */
 	if (bmval2 & FATTR4_WORD2_SECURITY_LABEL) {
 		status = nfsd4_encode_security_label(rqstp, context,
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index f49fb0b..d81db6e 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -329,8 +329,14 @@ static inline void nfs4_reset_lease(time_t leasetime) { }
 	NFSD4_SUPPORTED_ATTRS_WORD1
 #endif /* CONFIG_PNFSD */
 
+#if defined(CONFIG_PNFSD)
+#define NFSD4_1_SUPPORTED_ATTRS_WORD2 \
+	(NFSD4_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SUPPATTR_EXCLCREAT | \
+	 FATTR4_WORD2_LAYOUT_BLKSIZE)
+#else /* CONFIG_PNFSD */
 #define NFSD4_1_SUPPORTED_ATTRS_WORD2 \
 	(NFSD4_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SUPPATTR_EXCLCREAT)
+#endif /* CONFIG_PNFSD */
 
 #ifdef CONFIG_NFSD_V4_SECURITY_LABEL
 #define NFSD4_2_SUPPORTED_ATTRS_WORD2 \
-- 
1.8.3.1

