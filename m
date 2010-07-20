From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 10/24] Removed warnings from cache.c
Date: Tue, 20 Jul 2010 19:37:23 -0400
Message-ID: <1279669057-17509-11-git-send-email-steved@redhat.com>
References: <1279669057-17509-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:60382 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1761324Ab0GUAnT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 20:43:19 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1ObMNY-0004K5-5A
	for linux-nfs@vger.kernel.org; Tue, 20 Jul 2010 19:37:40 -0400
In-Reply-To: <1279669057-17509-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

cache.c:812: warning: missing initializer
cache.c:812: warning: (near initialization for 'cachelist[0].f')
cache.c:813: warning: missing initializer
cache.c:813: warning: (near initialization for 'cachelist[1].f')
cache.c:814: warning: missing initializer
cache.c:814: warning: (near initialization for 'cachelist[2].f')
cache.c:815: warning: missing initializer
cache.c:815: warning: (near initialization for 'cachelist[3].f')
cache.c:816: warning: missing initializer
cache.c:816: warning: (near initialization for 'cachelist[4].f')
cache.c: In function 'cache_export_ent':
cache.c:887: warning: comparison between signed and unsigned integer expressions
cache.c:907: warning: comparison between signed and unsigned integer expressions

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/include/nfslib.h |    2 +-
 utils/mountd/cache.c     |   18 +++++++++---------
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index b8e7c40..f57f2e2 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -83,7 +83,7 @@ struct exportent {
 	int		e_nsquids;
 	int *		e_sqgids;
 	int		e_nsqgids;
-	int		e_fsid;
+	unsigned int	e_fsid;
 	char *		e_mountpoint;
 	int             e_fslocmethod;
 	char *          e_fslocdata;
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 5488056..2909ad3 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -593,7 +593,7 @@ void nfsd_fh(FILE *f)
 	return;		
 }
 
-static void write_fsloc(FILE *f, struct exportent *ep, char *path)
+static void write_fsloc(FILE *f, struct exportent *ep)
 {
 	struct servers *servers;
 
@@ -648,7 +648,7 @@ static int dump_to_cache(FILE *f, char *domain, char *path, struct exportent *ex
 		qword_printint(f, exp->e_anonuid);
 		qword_printint(f, exp->e_anongid);
 		qword_printint(f, exp->e_fsid);
-		write_fsloc(f, exp, path);
+		write_fsloc(f, exp);
 		write_secinfo(f, exp, flag_mask);
  		if (exp->e_uuid == NULL || different_fs) {
  			char u[16];
@@ -809,11 +809,11 @@ struct {
 	void (*cache_handle)(FILE *f);
 	FILE *f;
 } cachelist[] = {
-	{ "auth.unix.ip", auth_unix_ip},
-	{ "auth.unix.gid", auth_unix_gid},
-	{ "nfsd.export", nfsd_export},
-	{ "nfsd.fh", nfsd_fh},
-	{ NULL, NULL }
+	{ "auth.unix.ip", auth_unix_ip, NULL},
+	{ "auth.unix.gid", auth_unix_gid, NULL},
+	{ "nfsd.export", nfsd_export, NULL},
+	{ "nfsd.fh", nfsd_fh, NULL},
+	{ NULL, NULL, NULL }
 };
 
 extern int manage_gids;
@@ -881,8 +881,8 @@ int cache_export_ent(char *domain, struct exportent *exp, char *path)
 		 * and export them with the same options
 		 */
 		struct stat stb;
-		int l = strlen(exp->e_path);
-		int dev;
+		size_t l = strlen(exp->e_path);
+		__dev_t dev;
 
 		if (strlen(path) <= l || path[l] != '/' ||
 		    strncmp(exp->e_path, path, l) != 0)
-- 
1.7.0.1

