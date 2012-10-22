Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:60605 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755440Ab2JVQGh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2012 12:06:37 -0400
Received: by mail-ie0-f174.google.com with SMTP id k13so3828544iea.19
        for <linux-nfs@vger.kernel.org>; Mon, 22 Oct 2012 09:06:37 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/10] mountd: Avoid unnecessary type conversions
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 22 Oct 2012 12:06:33 -0400
Message-ID: <20121022160633.4552.55174.stgit@lebasque.1015granger.net>
In-Reply-To: <20121022160140.4552.34477.stgit@lebasque.1015granger.net>
References: <20121022160140.4552.34477.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up compiler warnings:

cache.c: In function ‘is_subdirectory’:
cache.c:760:16: warning: conversion to ‘int’ from ‘size_t’ may
  alter its value [-Wconversion]
cache.c:763:3: warning: conversion to ‘size_t’ from ‘int’ may
  change the sign of the result [-Wsign-conversion]

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/cache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 64ca5ba..fbaa28e 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -758,7 +758,7 @@ static int dump_to_cache(FILE *f, char *domain, char *path, struct exportent *ex
 
 static int is_subdirectory(char *child, char *parent)
 {
-	int l = strlen(parent);
+	size_t l = strlen(parent);
 
 	return strcmp(child, parent) == 0
 		|| (strncmp(child, parent, l) == 0 && child[l] == '/');

