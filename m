From: Tao Guo <glorioustao@gmail.com>
Subject: [pnfs][PATCH 2/2]pnfsd: make pnfs server return layout_blksize when
	the client asks for it
Date: Mon, 29 Jun 2009 10:23:15 +0800
Message-ID: <318b7ac70906281923m7cfdedc2t35bbe705654e9df4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Fredric Isaman <iisaman@citi.umich.edu>, bfields@citi.umich.edu,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:64737 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756088AbZF2CXN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Jun 2009 22:23:13 -0400
Received: by wf-out-1314.google.com with SMTP id 26so915596wfd.4
        for <linux-nfs@vger.kernel.org>; Sun, 28 Jun 2009 19:23:15 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 1f4e06f..a5a2c89 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2376,6 +2376,12 @@ out_acl:
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
 	if (bmval2 & FATTR4_WORD2_SUPPATTR_EXCLCREAT) {
 		WRITE32(3);
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index 75453de..d765487 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -378,7 +378,8 @@ extern struct timeval	nfssvc_boot;
 #endif /* CONFIG_PNFSD */

 #define NFSD4_1_SUPPORTED_ATTRS_WORD2 \
-	(NFSD4_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SUPPATTR_EXCLCREAT)
+	(NFSD4_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SUPPATTR_EXCLCREAT | \
+	 FATTR4_WORD2_LAYOUT_BLKSIZE)

 #if defined(CONFIG_NFSD_V4_1)


-- 
tao.
