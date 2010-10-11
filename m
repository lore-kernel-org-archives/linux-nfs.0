Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:38170 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543Ab0JKAFX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Oct 2010 20:05:23 -0400
Received: by mail-iw0-f174.google.com with SMTP id 6so2668490iwn.19
        for <linux-nfs@vger.kernel.org>; Sun, 10 Oct 2010 17:05:23 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/15] mount.nfs: Eliminate compiler warnings in
	utils/mount/mount.c
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Sun, 10 Oct 2010 20:05:21 -0400
Message-ID: <20101011000521.6667.46574.stgit@ellison.1015granger.net>
In-Reply-To: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
References: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

mount.c: In function ‘parse_opt’:
mount.c:354: warning: conversion to ‘size_t’ from ‘int’ may change the sign of the result
mount.c:354: warning: conversion to ‘int’ from ‘size_t’ may change the sign of the result
mount.c:359: warning: conversion to ‘size_t’ from ‘int’ may change the sign of the result
mount.c:359: warning: conversion to ‘int’ from ‘size_t’ may change the sign of the result
mount.c: In function ‘parse_opts’:
mount.c:374: warning: conversion to ‘int’ from ‘size_t’ may change the sign of the result
mount.c:377: warning: conversion to ‘size_t’ from ‘int’ may change the sign of the result

Character string lengths are usually size_t anyway.  We can easily
avoid the implicit type cast here.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 1c6a88f..2909595 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -337,7 +337,7 @@ static void mount_usage(void)
 	printf(_("\tnfsoptions\tRefer to mount.nfs(8) or nfs(5)\n\n"));
 }
 
-static void parse_opt(const char *opt, int *mask, char *extra_opts, int len)
+static void parse_opt(const char *opt, int *mask, char *extra_opts, size_t len)
 {
 	const struct opt_map *om;
 
@@ -371,7 +371,7 @@ static void parse_opts(const char *options, int *flags, char **extra_opts)
 	if (options != NULL) {
 		char *opts = xstrdup(options);
 		char *opt, *p;
-		int len = strlen(opts) + 1;	/* include room for a null */
+		size_t len = strlen(opts) + 1;	/* include room for a null */
 		int open_quote = 0;
 
 		*extra_opts = xmalloc(len);

