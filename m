From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 2/3] Explicit UUID handling doesn't require blkid; factor
	out get_uuid_blkdev()
Date: Mon, 18 Aug 2008 13:17:39 +0100
Message-ID: <1219061859.3184.380.camel@pmac.infradead.org>
References: <48A5449F.7050205@nokia.com>
	 <1218808776.3184.89.camel@pmac.infradead.org>
	 <1218809892.7037.3.camel@localhost>
	 <1219058258.3184.358.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Artem.Bityutskiy@nokia.com, linux-fsdevel@vger.kernel.org,
	steved@redhat.com, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:50231 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753600AbYHRMRo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Aug 2008 08:17:44 -0400
In-Reply-To: <1219058258.3184.358.camel-ZP4jZrcIevRpWr+L1FloEB2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 utils/mountd/cache.c |   74 +++++++++++++++++++++++++++-----------------------
 1 files changed, 40 insertions(+), 34 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index cd377ce..0136eca 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -14,6 +14,7 @@
 #include <sys/types.h>
 #include <sys/select.h>
 #include <sys/stat.h>
+#include <sys/vfs.h>
 #include <time.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>
@@ -165,6 +166,41 @@ void auth_unix_gid(FILE *f)
 }
 
 #if USE_BLKID
+static const char *get_uuid_blkdev(char *path)
+{
+	static blkid_cache cache = NULL;
+	struct stat stb;
+	char *devname;
+	blkid_tag_iterate iter;
+	blkid_dev dev;
+	const char *type;
+	const char *val = NULL;
+
+	if (cache == NULL)
+		blkid_get_cache(&cache, NULL);
+
+	if (stat(path, &stb) != 0)
+		return NULL;
+	devname = blkid_devno_to_devname(stb.st_dev);
+	if (!devname)
+		return NULL;
+	dev = blkid_get_dev(cache, devname, BLKID_DEV_NORMAL);
+	free(devname);
+	if (!dev)
+		return NULL;
+	iter = blkid_tag_iterate_begin(dev);
+	if (!iter)
+		return NULL;
+	while (blkid_tag_next(iter, &type, &val) == 0)
+		if (strcmp(type, "UUID") == 0)
+			break;
+	blkid_tag_iterate_end(iter);
+	return val;
+}
+#else
+#define get_uuid_blkdev(path) (NULL)
+#endif
+
 int get_uuid(char *path, char *uuid, int uuidlen, char *u)
 {
 	/* extract hex digits from uuidstr and compose a uuid
@@ -172,35 +208,12 @@ int get_uuid(char *path, char *uuid, int uuidlen, char *u)
 	 * a smaller uuid.  Then compare with uuid
 	 */
 	int i = 0;
-	const char *val;
+	const char *val = NULL;
+	char fsid_val[17];
 
 	if (path) {
-		static blkid_cache cache = NULL;
-		struct stat stb;
-		char *devname;
-		blkid_tag_iterate iter;
-		blkid_dev dev;
-		const char *type;
-		if (cache == NULL)
-			blkid_get_cache(&cache, NULL);
-
-		if (stat(path, &stb) != 0)
-			return 0;
-		devname = blkid_devno_to_devname(stb.st_dev);
-		if (!devname)
-			return 0;
-		dev = blkid_get_dev(cache, devname, BLKID_DEV_NORMAL);
-		free(devname);
-		if (!dev)
-			return 0;
-		iter = blkid_tag_iterate_begin(dev);
-		if (!iter)
-			return 0;
-		while (blkid_tag_next(iter, &type, &val) == 0)
-			if (strcmp(type, "UUID") == 0)
-				break;
-		blkid_tag_iterate_end(iter);
-		if (!type)
+		val = get_uuid_blkdev(path);
+		if (!val)
 			return 0;
 	} else {
 		val = uuid;
@@ -227,7 +240,6 @@ int get_uuid(char *path, char *uuid, int uuidlen, char *u)
 	}
 	return 1;
 }
-#endif
 
 /* Iterate through /etc/mtab, finding mountpoints
  * at or below a given path
@@ -437,7 +449,6 @@ void nfsd_fh(FILE *f)
 				if (!is_mountpoint(path))
 					continue;
 			check_uuid:
-#if USE_BLKID
 				if (exp->m_export.e_uuid)
 					get_uuid(NULL, exp->m_export.e_uuid,
 						 uuidlen, u);
@@ -448,9 +459,6 @@ void nfsd_fh(FILE *f)
 				if (memcmp(u, fhuuid, uuidlen) != 0)
 					continue;
 				break;
-#else
-				continue;
-#endif
 			}
 			if (use_ipaddr) {
 				if (he == NULL) {
@@ -582,7 +590,6 @@ static int dump_to_cache(FILE *f, char *domain, char *path, struct exportent *ex
 		qword_printint(f, exp->e_fsid);
 		write_fsloc(f, exp, path);
 		write_secinfo(f, exp);
-#if USE_BLKID
  		if (exp->e_uuid == NULL || different_fs) {
  			char u[16];
  			if (get_uuid(path, NULL, 16, u)) {
@@ -595,7 +602,6 @@ static int dump_to_cache(FILE *f, char *domain, char *path, struct exportent *ex
  			qword_print(f, "uuid");
  			qword_printhex(f, u, 16);
  		}
-#endif
 	}
 	return qword_eol(f);
 }
-- 
1.5.5.1


-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation



