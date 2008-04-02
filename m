From: "Robert P. J. Day" <rpjday-L09J2beyid0N/H6P543EQg@public.gmane.org>
Subject: [PATCH] NFSD:  Strip __KERNEL__ testing from unexported header
 files.
Date: Tue, 1 Apr 2008 21:48:37 -0400 (EDT)
Message-ID: <alpine.LFD.1.00.0804012147030.11039@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from astoria.ccjclearline.com ([64.235.106.9]:50411 "EHLO
	astoria.ccjclearline.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753227AbYDBBsk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Apr 2008 21:48:40 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Also, sort the Kbuild file.

Signed-off-by: Robert P. J. Day <rpjday-L09J2beyid0N/H6P543EQg@public.gmane.org>

---

 include/linux/nfsd/Kbuild  |    4 ++--
 include/linux/nfsd/cache.h |    2 --
 include/linux/nfsd/nfsd.h  |    3 ---
 3 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/include/linux/nfsd/Kbuild b/include/linux/nfsd/Kbuild
index e726fc3..fc97204 100644
--- a/include/linux/nfsd/Kbuild
+++ b/include/linux/nfsd/Kbuild
@@ -1,6 +1,6 @@
 unifdef-y += const.h
+unifdef-y += debug.h
 unifdef-y += export.h
+unifdef-y += nfsfh.h
 unifdef-y += stats.h
 unifdef-y += syscall.h
-unifdef-y += nfsfh.h
-unifdef-y += debug.h
diff --git a/include/linux/nfsd/cache.h b/include/linux/nfsd/cache.h
index 7b5d784..04b355c 100644
--- a/include/linux/nfsd/cache.h
+++ b/include/linux/nfsd/cache.h
@@ -10,7 +10,6 @@
 #ifndef NFSCACHE_H
 #define NFSCACHE_H

-#ifdef __KERNEL__
 #include <linux/in.h>
 #include <linux/uio.h>

@@ -77,5 +76,4 @@ void	nfsd_reply_cache_shutdown(void);
 int	nfsd_cache_lookup(struct svc_rqst *, int);
 void	nfsd_cache_update(struct svc_rqst *, int, __be32 *);

-#endif /* __KERNEL__ */
 #endif /* NFSCACHE_H */
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index 8caf4c4..c17ef86 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -27,7 +27,6 @@
 #define NFSD_VERSION		"0.5"
 #define NFSD_SUPPORTED_MINOR_VERSION	0

-#ifdef __KERNEL__
 /*
  * Special flags for nfsd_permission. These must be different from MAY_READ,
  * MAY_WRITE, and MAY_EXEC.
@@ -326,6 +325,4 @@ extern struct timeval	nfssvc_boot;

 #endif /* CONFIG_NFSD_V4 */

-#endif /* __KERNEL__ */
-
 #endif /* LINUX_NFSD_NFSD_H */

========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry:
    Have classroom, will lecture.

http://crashcourse.ca                          Waterloo, Ontario, CANADA
========================================================================
