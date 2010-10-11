Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:38170 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543Ab0JKAFE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Oct 2010 20:05:04 -0400
Received: by mail-iw0-f174.google.com with SMTP id 6so2668490iwn.19
        for <linux-nfs@vger.kernel.org>; Sun, 10 Oct 2010 17:05:04 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/15] mount.nfs: Eliminate compiler warnings in
	utils/mount/version.h
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Sun, 10 Oct 2010 20:05:01 -0400
Message-ID: <20101011000501.6667.87285.stgit@ellison.1015granger.net>
In-Reply-To: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
References: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

In file included from mount.c:50:
version.h: In function ‘linux_version_code’:
version.h:48: warning: conversion to ‘unsigned int’ from ‘int’ may change the sign of the result
version.h:48: warning: conversion to ‘unsigned int’ from ‘int’ may change the sign of the result
version.h:48: warning: conversion to ‘unsigned int’ from ‘int’ may change the sign of the result

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/version.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/utils/mount/version.h b/utils/mount/version.h
index 46552a1..af61a6f 100644
--- a/utils/mount/version.h
+++ b/utils/mount/version.h
@@ -42,9 +42,9 @@ static inline unsigned int linux_version_code(void)
 	if (uname(&my_utsname))
 		return 0;
 
-	p = atoi(strtok(my_utsname.release, "."));
-	q = atoi(strtok(NULL, "."));
-	r = atoi(strtok(NULL, "."));
+	p = (unsigned int)atoi(strtok(my_utsname.release, "."));
+	q = (unsigned int)atoi(strtok(NULL, "."));
+	r = (unsigned int)atoi(strtok(NULL, "."));
 	return MAKE_VERSION(p, q, r);
 }
 

