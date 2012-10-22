Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f174.google.com ([209.85.210.174]:59378 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755440Ab2JVQGp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2012 12:06:45 -0400
Received: by mail-ia0-f174.google.com with SMTP id y32so2175418iag.19
        for <linux-nfs@vger.kernel.org>; Mon, 22 Oct 2012 09:06:45 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/10] mountd: Avoid unnecessary type conversions
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 22 Oct 2012 12:06:44 -0400
Message-ID: <20121022160644.4552.477.stgit@lebasque.1015granger.net>
In-Reply-To: <20121022160140.4552.34477.stgit@lebasque.1015granger.net>
References: <20121022160140.4552.34477.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up compiler warnings:

cache.c: In function ‘get_uuid’:
cache.c:256:17: warning: conversion to ‘char’ from ‘int’ may
  alter its value [-Wconversion]
cache.c:258:17: warning: conversion to ‘char’ from ‘int’ may
  alter its value [-Wconversion]
cache.c:260:16: warning: conversion to ‘char’ from ‘int’ may
  alter its value [-Wconversion]
cache.c:262:6: warning: conversion to ‘char’ from ‘int’ may
  alter its value [-Wconversion]

Seen with gcc version 4.6.3 20120306 (Red Hat 4.6.3-2) (GCC)

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/cache.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index fbaa28e..e950ec6 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -248,7 +248,7 @@ static int get_uuid(const char *val, size_t uuidlen, char *u)
 	
 	memset(u, 0, uuidlen);
 	for ( ; *val ; val++) {
-		char c = *val;
+		int c = *val;
 		if (!isxdigit(c))
 			continue;
 		if (isalpha(c)) {
@@ -260,7 +260,7 @@ static int get_uuid(const char *val, size_t uuidlen, char *u)
 			c = c - '0' + 0;
 		if ((i&1) == 0)
 			c <<= 4;
-		u[i/2] ^= c;
+		u[i/2] ^= (char)c;
 		i++;
 		if (i == uuidlen*2)
 			i = 0;

