Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f175.google.com ([209.85.217.175]:41955 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752645AbaG3LXc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 07:23:32 -0400
Received: by mail-lb0-f175.google.com with SMTP id 10so769800lbg.34
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 04:23:31 -0700 (PDT)
From: Natanael Copa <natanael.copa@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Natanael Copa <ncopa@alpinelinux.org>
Subject: [PATCH 04/11] exportfs: define _GNU_SOURCE for stat64
Date: Wed, 30 Jul 2014 13:23:12 +0200
Message-Id: <1406719399-1735-5-git-send-email-ncopa@alpinelinux.org>
In-Reply-To: <1406719399-1735-1-git-send-email-ncopa@alpinelinux.org>
References: <1406719399-1735-1-git-send-email-ncopa@alpinelinux.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Natanael Copa <ncopa@alpinelinux.org>
---
 utils/exportfs/exportfs.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index bf07555..7ab93d1 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -12,6 +12,10 @@
 #include <config.h>
 #endif
 
+#ifndef _GNU_SOURCE
+#define _GNU_SOURCE
+#endif
+
 #include <sys/types.h>
 #include <sys/stat.h>
 #include <sys/vfs.h>
-- 
2.0.3

