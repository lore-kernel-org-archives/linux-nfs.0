Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f172.google.com ([209.85.217.172]:48900 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753307AbaHFGZV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Aug 2014 02:25:21 -0400
Received: by mail-lb0-f172.google.com with SMTP id z11so1573308lbi.3
        for <linux-nfs@vger.kernel.org>; Tue, 05 Aug 2014 23:25:20 -0700 (PDT)
From: Natanael Copa <natanael.copa@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Natanael Copa <ncopa@alpinelinux.org>
Subject: [PATCH v2 08/11] Only work around glibc bugs on glibc
Date: Wed,  6 Aug 2014 08:25:03 +0200
Message-Id: <1407306306-29796-9-git-send-email-ncopa@alpinelinux.org>
In-Reply-To: <1407306306-29796-1-git-send-email-ncopa@alpinelinux.org>
References: <1407306306-29796-1-git-send-email-ncopa@alpinelinux.org>
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
2.0.4

