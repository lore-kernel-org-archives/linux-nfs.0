From: Adrian Bunk <bunk@kernel.org>
Subject: [RFC: 2.6 patch] don't export linux/nfsd/stats.h to userspace
Date: Mon, 23 Jun 2008 20:48:54 +0300
Message-ID: <20080623174854.GI4756@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: bfields@fieldses.org, neilb@suse.de
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:48405 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761497AbYFWRuu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jun 2008 13:50:50 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The main contents is struct nfsd_stats which changes depending on a 
CONFIG_ variable.

This would not work in userspace.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 include/linux/nfsd/Kbuild  |    1 -
 include/linux/nfsd/stats.h |    3 ---
 2 files changed, 4 deletions(-)

9b6014db4d4182cf4cb342b97f9018c5d1090afa diff --git a/include/linux/nfsd/Kbuild b/include/linux/nfsd/Kbuild
index fc97204..698e9ec 100644
--- a/include/linux/nfsd/Kbuild
+++ b/include/linux/nfsd/Kbuild
@@ -2,5 +2,4 @@ unifdef-y += const.h
 unifdef-y += debug.h
 unifdef-y += export.h
 unifdef-y += nfsfh.h
-unifdef-y += stats.h
 unifdef-y += syscall.h
diff --git a/include/linux/nfsd/stats.h b/include/linux/nfsd/stats.h
index 7678cfb..d949590 100644
--- a/include/linux/nfsd/stats.h
+++ b/include/linux/nfsd/stats.h
@@ -38,13 +38,10 @@ struct nfsd_stats {
 /* thread usage wraps very million seconds (approx one fortnight) */
 #define	NFSD_USAGE_WRAP	(HZ*1000000)
 
-#ifdef __KERNEL__
-
 extern struct nfsd_stats	nfsdstats;
 extern struct svc_stat		nfsd_svcstats;
 
 void	nfsd_stat_init(void);
 void	nfsd_stat_shutdown(void);
 
-#endif /* __KERNEL__ */
 #endif /* LINUX_NFSD_STATS_H */

