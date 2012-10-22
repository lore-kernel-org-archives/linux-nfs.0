Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:60605 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755440Ab2JVQG0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2012 12:06:26 -0400
Received: by mail-ie0-f174.google.com with SMTP id k13so3828544iea.19
        for <linux-nfs@vger.kernel.org>; Mon, 22 Oct 2012 09:06:26 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/10] mountd: Avoid unnecessary type conversions
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 22 Oct 2012 12:06:23 -0400
Message-ID: <20121022160623.4552.56505.stgit@lebasque.1015granger.net>
In-Reply-To: <20121022160140.4552.34477.stgit@lebasque.1015granger.net>
References: <20121022160140.4552.34477.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up compiler warnings:

cache.c: In function ‘get_uuid’:
cache.c:249:2: warning: conversion to ‘size_t’ from ‘int’ may change
  the sign of the result [-Wsign-conversion]

And the like.

Seen with gcc version 4.6.3 20120306 (Red Hat 4.6.3-2) (GCC)

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/cache.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 57a3fed..64ca5ba 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -238,13 +238,13 @@ static const char *get_uuid_blkdev(char *path)
 #define get_uuid_blkdev(path) (NULL)
 #endif
 
-static int get_uuid(const char *val, int uuidlen, char *u)
+static int get_uuid(const char *val, size_t uuidlen, char *u)
 {
 	/* extract hex digits from uuidstr and compose a uuid
 	 * of the given length (max 16), xoring bytes to make
 	 * a smaller uuid.
 	 */
-	int i = 0;
+	size_t i = 0;
 	
 	memset(u, 0, uuidlen);
 	for ( ; *val ; val++) {
@@ -268,7 +268,7 @@ static int get_uuid(const char *val, int uuidlen, char *u)
 	return 1;
 }
 
-static int uuid_by_path(char *path, int type, int uuidlen, char *uuid)
+static int uuid_by_path(char *path, int type, size_t uuidlen, char *uuid)
 {
 	/* get a uuid for the filesystem found at 'path'.
 	 * There are several possible ways of generating the
@@ -366,7 +366,7 @@ struct parsed_fsid {
 	unsigned int minor;
 	unsigned int major;
 	unsigned int fsidnum;
-	int uuidlen;
+	size_t uuidlen;
 	char *fhuuid;
 };
 

