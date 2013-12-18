Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47634 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750940Ab3LRUGa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Dec 2013 15:06:30 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id rBIK6Uw8018594
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 18 Dec 2013 15:06:30 -0500
Received: from tasleson.csb (vpn-229-185.phx2.redhat.com [10.3.229.185])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id rBIK6Tdn014493
	for <linux-nfs@vger.kernel.org>; Wed, 18 Dec 2013 15:06:29 -0500
From: Tony Asleson <tasleson@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] exportfs.c: Remove trailing whitespace
Date: Wed, 18 Dec 2013 14:06:28 -0600
Message-Id: <1387397189-9591-2-git-send-email-tasleson@redhat.com>
In-Reply-To: <1387397189-9591-1-git-send-email-tasleson@redhat.com>
References: <1387397189-9591-1-git-send-email-tasleson@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 utils/exportfs/exportfs.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 3ca45c1..019961b 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -65,19 +65,19 @@ static int _lockfd = -1;
  *	writes A+B		writes A+C
  *
  * The locking in support/export/xtab.c will prevent mountd from
- * seeing a partially written version of etab, and will prevent 
+ * seeing a partially written version of etab, and will prevent
  * the two writers above from writing simultaneously and
  * corrupting etab, but to prevent problems like the above we
  * need these additional lockfile() routines.
  */
-static void 
+static void
 grab_lockfile()
 {
 	_lockfd = open(lockfile, O_CREAT|O_RDWR, 0666);
-	if (_lockfd != -1) 
+	if (_lockfd != -1)
 		lockf(_lockfd, F_LOCK, 0);
 }
-static void 
+static void
 release_lockfile()
 {
 	if (_lockfd != -1)
@@ -271,7 +271,7 @@ exports_update(int verbose)
 		exports_update_one(exp, verbose);
 	}
 }
-			
+
 /*
  * export_all finds all entries and
  *    marks them xtabent and mayexport so that they get exported
@@ -286,7 +286,7 @@ export_all(int verbose)
 		for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
 			if (verbose)
 				printf("exporting %s:%s\n",
-				       exp->m_client->m_hostname, 
+				       exp->m_client->m_hostname,
 				       exp->m_export.e_path);
 			exp->m_xtabent = 1;
 			exp->m_mayexport = 1;
@@ -333,7 +333,7 @@ exportfs(char *arg, char *options, int verbose)
 		goto out;
 
 	if (verbose)
-		printf("exporting %s:%s\n", exp->m_client->m_hostname, 
+		printf("exporting %s:%s\n", exp->m_client->m_hostname,
 			exp->m_export.e_path);
 	exp->m_xtabent = 1;
 	exp->m_mayexport = 1;
@@ -391,7 +391,7 @@ unexportfs(char *arg, int verbose)
 			else
 #endif
 				printf("unexporting %s:%s\n",
-					exp->m_client->m_hostname, 
+					exp->m_client->m_hostname,
 					exp->m_export.e_path);
 		}
 #if 0
@@ -402,7 +402,7 @@ unexportfs(char *arg, int verbose)
 		exp->m_mayexport = 0;
 		success = 1;
 	}
-	if (!success) 
+	if (!success)
 		xlog(L_ERROR, "Could not find '%s:%s' to unexport.", arg, path);
 
 	freeaddrinfo(ai);
@@ -421,7 +421,7 @@ static int can_test(void)
 	/*
 	 * We introduce tolerance of 1 day to ensure that we use a
 	 * LONG_MAX for the expiry timestamp before it is actually
-	 * needed. To use LONG_MAX, the kernel code must have 
+	 * needed. To use LONG_MAX, the kernel code must have
 	 * commit 2f74f972  (sunrpc: prepare NFS for 2038).
 	 */
 	if (time(NULL) > INT_TO_LONG_THRESHOLD_SECS)
@@ -620,7 +620,7 @@ export_d_read(const char *dname)
 		int fname_len;
 
 
-		if (d->d_type != DT_UNKNOWN 
+		if (d->d_type != DT_UNKNOWN
 		    && d->d_type != DT_REG
 		    && d->d_type != DT_LNK)
 			continue;
@@ -629,7 +629,7 @@ export_d_read(const char *dname)
 
 #define _EXT_EXPORT_SIZ   (sizeof(_EXT_EXPORT) - 1)
 		namesz = strlen(d->d_name);
-		if (!namesz 
+		if (!namesz
 		    || namesz < _EXT_EXPORT_SIZ + 1
 		    || strcmp(d->d_name + (namesz - _EXT_EXPORT_SIZ),
 			      _EXT_EXPORT))
@@ -643,7 +643,7 @@ export_d_read(const char *dname)
 
 		export_read(fname);
 	}
-		
+
 	for (i = 0; i < n; i++)
 		free(namelist[i]);
 	free(namelist);
@@ -721,8 +721,8 @@ dump(int verbose, int export_format)
 			if (ep->e_uuid)
 				c = dumpopt(c, "fsid=%s", ep->e_uuid);
 			if (ep->e_mountpoint)
-				c = dumpopt(c, "mountpoint%s%s", 
-					    ep->e_mountpoint[0]?"=":"", 
+				c = dumpopt(c, "mountpoint%s%s",
+					    ep->e_mountpoint[0]?"=":"",
 					    ep->e_mountpoint);
 			if (ep->e_anonuid != 65534)
 				c = dumpopt(c, "anonuid=%d", ep->e_anonuid);
-- 
1.8.2.1

