Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f172.google.com ([209.85.212.172]:45866 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753727Ab2E1QJw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 May 2012 12:09:52 -0400
Received: by wibhj8 with SMTP id hj8so1841266wib.1
        for <linux-nfs@vger.kernel.org>; Mon, 28 May 2012 09:09:51 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] pnfsd-lexp: return_on_close config option
Date: Mon, 28 May 2012 19:09:47 +0300
Message-Id: <1338221387-22621-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <4FC3A235.8090908@tonian.com>
References: <4FC3A235.8090908@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/Kconfig      |    7 +++++++
 fs/nfsd/pnfsd_lexp.c |    5 +++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index 9d4d79b..f9b3426 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -132,3 +132,10 @@ config PNFSD_LEXP_LAYOUT_SEGMENT_SIZE
 	  Set simulated layout segment size.
 
 	  If unsure, say N.
+
+config PNFSD_LEXP_RETURN_ON_CLOSE
+	bool "Reply to LAYOUTGET with return_on_close set to true"
+	depends on PNFSD_LOCAL_EXPORT
+	default false
+	help
+	  Set return_on_close response flag.
diff --git a/fs/nfsd/pnfsd_lexp.c b/fs/nfsd/pnfsd_lexp.c
index 30d9757..33a724c 100644
--- a/fs/nfsd/pnfsd_lexp.c
+++ b/fs/nfsd/pnfsd_lexp.c
@@ -153,6 +153,11 @@ static int get_stripe_unit(int blocksize)
 	res->lg_seg.offset = 0;
 	res->lg_seg.length = NFS4_MAX_UINT64;
 #endif  /* CONFIG_PNFSD_LEXP_LAYOUT_SEGMENTS */
+#ifdef     CONFIG_PNFSD_LEXP_RETURN_ON_CLOSE
+	res->lg_return_on_close = true;
+#else   /* CONFIG_PNFSD_LEXP_RETURN_ON_CLOSE */
+	res->lg_return_on_close = false;
+#endif  /* CONFIG_PNFSD_LEXP_RETURN_ON_CLOSE */
 
 	layout = kzalloc(sizeof(*layout), GFP_KERNEL);
 	if (layout == NULL) {
-- 
1.7.6.5

