From: Greg Banks <gnb@sgi.com>
Subject: [PATCH] Fix a build warning about leaking CONFIG_NFSD to userspace.
Date: Fri, 27 Mar 2009 02:32:47 +1100
Message-ID: <49CBA01F.6050809@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:41838 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756319AbZCZPdE (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Thu, 26 Mar 2009 11:33:04 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix a build warning about leaking CONFIG_NFSD to userspace.

The nfsd_stats data structure does not need to be available to
userspace; no kernel interface uses it.  So move it inside #ifdef
__KERNEL__ and the warning goes away.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 include/linux/nfsd/stats.h |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

Index: bfields/include/linux/nfsd/stats.h
===================================================================
--- bfields.orig/include/linux/nfsd/stats.h
+++ bfields/include/linux/nfsd/stats.h
@@ -11,6 +11,11 @@
 
 #include <linux/nfs4.h>
 
+/* thread usage wraps very million seconds (approx one fortnight) */
+#define	NFSD_USAGE_WRAP	(HZ*1000000)
+
+#ifdef __KERNEL__
+
 struct nfsd_stats {
 	unsigned int	rchits;		/* repcache hits */
 	unsigned int	rcmisses;	/* repcache hits */
@@ -35,10 +40,6 @@ struct nfsd_stats {
 
 };
 
-/* thread usage wraps very million seconds (approx one fortnight) */
-#define	NFSD_USAGE_WRAP	(HZ*1000000)
-
-#ifdef __KERNEL__
 
 extern struct nfsd_stats	nfsdstats;
 extern struct svc_stat		nfsd_svcstats;


-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

