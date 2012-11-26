Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f174.google.com ([209.85.215.174]:52987 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754489Ab2KZJ0T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Nov 2012 04:26:19 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so4312730eaa.19
        for <linux-nfs@vger.kernel.org>; Mon, 26 Nov 2012 01:26:18 -0800 (PST)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] pnfsd-lexp: CONFIG_PNFSD_LEXP_COMMIT_THRU_MDS
Date: Mon, 26 Nov 2012 11:26:14 +0200
Message-Id: <1353921974-19637-1-git-send-email-bhalevy@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/Kconfig      | 7 +++++++
 fs/nfsd/pnfsd_lexp.c | 4 ++++
 2 files changed, 11 insertions(+)

diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index d5ceec0..54b828e 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -139,3 +139,10 @@ config PNFSD_LEXP_RETURN_ON_CLOSE
 	default y
 	help
 	  Set return_on_close response flag.
+
+config PNFSD_LEXP_COMMIT_THRU_MDS
+	bool "Reply to LAYOUTGET with commit_thru_mds set to true"
+	depends on PNFSD_LOCAL_EXPORT
+	default n
+	help
+	  Set commit_thru_mds nfl_util response flag.
diff --git a/fs/nfsd/pnfsd_lexp.c b/fs/nfsd/pnfsd_lexp.c
index 33a724c..bcdb80f 100644
--- a/fs/nfsd/pnfsd_lexp.c
+++ b/fs/nfsd/pnfsd_lexp.c
@@ -168,7 +168,11 @@ static int get_stripe_unit(int blocksize)
 	/* Set file layout response args */
 	layout->lg_layout_type = LAYOUT_NFSV4_1_FILES;
 	layout->lg_stripe_type = STRIPE_SPARSE;
+#ifdef CONFIG_PNFSD_LEXP_COMMIT_THRU_MDS
 	layout->lg_commit_through_mds = true;
+#else
+	layout->lg_commit_through_mds = false;
+#endif
 	layout->lg_stripe_unit = get_stripe_unit(inode->i_sb->s_blocksize);
 	layout->lg_fh_length = 1;
 	layout->device_id.sbid = arg->lg_sbid;
-- 
1.7.11.7

