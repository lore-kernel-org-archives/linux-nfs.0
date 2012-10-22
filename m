Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:60605 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755157Ab2JVQF5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2012 12:05:57 -0400
Received: by mail-ie0-f174.google.com with SMTP id k13so3828544iea.19
        for <linux-nfs@vger.kernel.org>; Mon, 22 Oct 2012 09:05:57 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/10] mountd: Avoid unnecessary type conversions
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 22 Oct 2012 12:05:55 -0400
Message-ID: <20121022160555.4552.44389.stgit@lebasque.1015granger.net>
In-Reply-To: <20121022160140.4552.34477.stgit@lebasque.1015granger.net>
References: <20121022160140.4552.34477.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up compiler warnings:

cache.c: In function ‘auth_unix_ip’:
cache.c:121:29: warning: conversion to ‘unsigned int’ from ‘time_t’
  may alter its value [-Wconversion]

cache.c: In function ‘auth_unix_gid’:
cache.c:186:29: warning: conversion to ‘unsigned int’ from ‘time_t’
  may alter its value [-Wconversion]

cache.c: In function ‘dump_to_cache’:
cache.c:733:30: warning: conversion to ‘unsigned int’ from ‘time_t’
  may alter its value [-Wconversion]
cache.c:753:30: warning: conversion to ‘unsigned int’ from ‘time_t’
  may alter its value [-Wconversion]

cache.c: In function ‘cache_export’:
cache.c:1324:29: warning: conversion to ‘unsigned int’ from ‘time_t’
  may alter its value [-Wconversion]

Seen with gcc version 4.6.3 20120306 (Red Hat 4.6.3-2) (GCC)

We can take the opportunity to eliminate some code duplication.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/nfslib.h |    1 +
 support/nfs/cacheio.c    |    5 +++++
 utils/mountd/cache.c     |   10 +++++-----
 3 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index 73f3c20..f210a06 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -164,6 +164,7 @@ void qword_adduint(char **bpp, int *lp, unsigned int n);
 void qword_addeol(char **bpp, int *lp);
 int qword_get_uint(char **bpp, unsigned int *anint);
 void qword_printuint(FILE *f, unsigned int num);
+void qword_printtimefrom(FILE *f, unsigned int num);
 
 void closeall(int min);
 
diff --git a/support/nfs/cacheio.c b/support/nfs/cacheio.c
index 9bad8e6..e641c45 100644
--- a/support/nfs/cacheio.c
+++ b/support/nfs/cacheio.c
@@ -153,6 +153,11 @@ void qword_printuint(FILE *f, unsigned int num)
 	fprintf(f, "%u ", num);
 }
 
+void qword_printtimefrom(FILE *f, unsigned int num)
+{
+	fprintf(f, "%lu ", time(0) + num);
+}
+
 int qword_eol(FILE *f)
 {
 	int err;
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 8280234..6de05f1 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -118,7 +118,7 @@ static void auth_unix_ip(FILE *f)
 	}
 	qword_print(f, "nfsd");
 	qword_print(f, ipaddr);
-	qword_printuint(f, time(0) + DEFAULT_TTL);
+	qword_printtimefrom(f, DEFAULT_TTL);
 	if (use_ipaddr)
 		qword_print(f, ipaddr);
 	else if (client)
@@ -183,7 +183,7 @@ static void auth_unix_gid(FILE *f)
 		}
 	}
 	qword_printuint(f, uid);
-	qword_printuint(f, time(0) + DEFAULT_TTL);
+	qword_printtimefrom(f, DEFAULT_TTL);
 	if (rv >= 0) {
 		qword_printuint(f, ngroups);
 		for (i=0; i<ngroups; i++)
@@ -730,7 +730,7 @@ static int dump_to_cache(FILE *f, char *domain, char *path, struct exportent *ex
 		int different_fs = strcmp(path, exp->e_path) != 0;
 		int flag_mask = different_fs ? ~NFSEXP_FSID : ~0;
 
-		qword_printuint(f, time(0) + exp->e_ttl);
+		qword_printtimefrom(f, exp->e_ttl);
 		qword_printint(f, exp->e_flags & flag_mask);
 		qword_printint(f, exp->e_anonuid);
 		qword_printint(f, exp->e_anongid);
@@ -750,7 +750,7 @@ static int dump_to_cache(FILE *f, char *domain, char *path, struct exportent *ex
  			qword_printhex(f, u, 16);
  		}
 	} else
-		qword_printuint(f, time(0) + DEFAULT_TTL);
+		qword_printtimefrom(f, DEFAULT_TTL);
 	return qword_eol(f);
 }
 
@@ -1339,7 +1339,7 @@ int cache_export(nfs_export *exp, char *path)
 	qword_print(f, "nfsd");
 	qword_print(f,
 		host_ntop(get_addrlist(exp->m_client, 0), buf, sizeof(buf)));
-	qword_printuint(f, time(0) + exp->m_export.e_ttl);
+	qword_printtimefrom(f, exp->m_export.e_ttl);
 	qword_print(f, exp->m_client->m_hostname);
 	err = qword_eol(f);
 	

