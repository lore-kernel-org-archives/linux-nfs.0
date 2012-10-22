Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:60605 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755157Ab2JVQGI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2012 12:06:08 -0400
Received: by mail-ie0-f174.google.com with SMTP id k13so3828544iea.19
        for <linux-nfs@vger.kernel.org>; Mon, 22 Oct 2012 09:06:07 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/10] mountd: Eliminate unnecessary type conversions
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 22 Oct 2012 12:06:04 -0400
Message-ID: <20121022160604.4552.21104.stgit@lebasque.1015granger.net>
In-Reply-To: <20121022160140.4552.34477.stgit@lebasque.1015granger.net>
References: <20121022160140.4552.34477.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up compiler warnings:

cache.c:332:16: warning: conversion to ‘int’ from ‘size_t’ may alter
  its value [-Wconversion]
cache.c:339:9: warning: conversion to ‘size_t’ from ‘int’ may change
  the sign of the result [-Wsign-conversion]
cache.c: In function ‘subexport’:
cache.c:354:17: warning: conversion to ‘int’ from ‘size_t’ may alter
  its value [-Wconversion]
cache.c:357:9: warning: conversion to ‘size_t’ from ‘int’ may change
  the sign of the result [-Wsign-conversion]

Seen with gcc version 4.6.3 20120306 (Red Hat 4.6.3-2) (GCC) .

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/cache.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 6de05f1..70e1aa4 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -329,7 +329,7 @@ static char *next_mnt(void **v, char *p)
 {
 	FILE *f;
 	struct mntent *me;
-	int l = strlen(p);
+	size_t l = strlen(p);
 	if (*v == NULL) {
 		f = setmntent("/etc/mtab", "r");
 		*v = f;
@@ -351,7 +351,7 @@ static char *next_mnt(void **v, char *p)
 static bool subexport(struct exportent *e1, struct exportent *e2)
 {
 	char *p1 = e1->e_path, *p2 = e2->e_path;
-	int l2 = strlen(p2);
+	size_t l2 = strlen(p2);
 
 	return e2->e_flags & NFSEXP_CROSSMOUNT
 	       && strncmp(p1, p2, l2) == 0

