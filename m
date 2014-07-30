Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f48.google.com ([209.85.215.48]:46514 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609AbaG3LXg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 07:23:36 -0400
Received: by mail-la0-f48.google.com with SMTP id gl10so772558lab.35
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 04:23:35 -0700 (PDT)
From: Natanael Copa <natanael.copa@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Natanael Copa <ncopa@alpinelinux.org>
Subject: [PATCH 09/11] Only work around glibc bugs on glibc
Date: Wed, 30 Jul 2014 13:23:17 +0200
Message-Id: <1406719399-1735-10-git-send-email-ncopa@alpinelinux.org>
In-Reply-To: <1406719399-1735-1-git-send-email-ncopa@alpinelinux.org>
References: <1406719399-1735-1-git-send-email-ncopa@alpinelinux.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Natanael Copa <ncopa@alpinelinux.org>
---
 utils/mountd/svc_run.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/mountd/svc_run.c b/utils/mountd/svc_run.c
index 1938a67..a572441 100644
--- a/utils/mountd/svc_run.c
+++ b/utils/mountd/svc_run.c
@@ -60,7 +60,7 @@
 void cache_set_fds(fd_set *fdset);
 int cache_process_req(fd_set *readfds);
 
-#if LONG_MAX != INT_MAX	
+#if defined(__GLIBC__) && LONG_MAX != INT_MAX
 /* bug in glibc 2.3.6 and earlier, we need
  * our own svc_getreqset
  */
-- 
2.0.3

