Return-Path: <SRS0=QgGt=SL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3179C282CE
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 11:37:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CC15920857
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 11:37:35 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727271AbfDILhe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Apr 2019 07:37:34 -0400
Received: from mx1.redhat.com ([209.132.183.28]:37810 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726387AbfDILhe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 9 Apr 2019 07:37:34 -0400
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 309DE307EA83;
        Tue,  9 Apr 2019 11:37:34 +0000 (UTC)
Received: from rhel3.localdomain (ovpn-12-27.pek2.redhat.com [10.72.12.27])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 8D3731001F52;
        Tue,  9 Apr 2019 11:37:32 +0000 (UTC)
From:   xiubli@redhat.com
To:     libtirpc-devel@lists.sourceforge.net
Cc:     linux-nfs@vger.kernel.org, Xiubo Li <xiubli@redhat.com>
Subject: [PATCH] svc_run: make sure only one svc_run loop runs in one process
Date:   Tue,  9 Apr 2019 19:37:13 +0800
Message-Id: <20190409113713.30595-1-xiubli@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Tue, 09 Apr 2019 11:37:34 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Xiubo Li <xiubli@redhat.com>

In gluster-block project and there are 2 separate threads, both
of which will run the svc_run loop, this could work well in glibc
version, but in libtirpc we are hitting the random crash and stuck
issues.

More detail please see:
https://github.com/gluster/gluster-block/pull/182

Signed-off-by: Xiubo Li <xiubli@redhat.com>
---
 src/svc_run.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/src/svc_run.c b/src/svc_run.c
index f40314b..b295755 100644
--- a/src/svc_run.c
+++ b/src/svc_run.c
@@ -38,12 +38,17 @@
 #include <string.h>
 #include <unistd.h>
 #include <sys/poll.h>
+#include <syslog.h>
+#include <stdbool.h>
 
 
 #include <rpc/rpc.h>
 #include "rpc_com.h"
 #include <sys/select.h>
 
+static bool svc_loop_running = false;
+static pthread_mutex_t svc_run_lock = PTHREAD_MUTEX_INITIALIZER;
+
 void
 svc_run()
 {
@@ -51,6 +56,16 @@ svc_run()
   struct pollfd *my_pollfd = NULL;
   int last_max_pollfd = 0;
 
+  pthread_mutex_lock(&svc_run_lock);
+  if (svc_loop_running) {
+    pthread_mutex_unlock(&svc_run_lock);
+    syslog (LOG_ERR, "svc_run: svc loop is already running in current process %d", getpid());
+    return;
+  }
+
+  svc_loop_running = true;
+  pthread_mutex_unlock(&svc_run_lock);
+
   for (;;) {
     int max_pollfd = svc_max_pollfd;
     if (max_pollfd == 0 && svc_pollfd == NULL)
@@ -111,4 +126,8 @@ svc_exit()
 	svc_pollfd = NULL;
 	svc_max_pollfd = 0;
 	rwlock_unlock(&svc_fd_lock);
+
+    pthread_mutex_lock(&svc_run_lock);
+    svc_loop_running = false;
+    pthread_mutex_unlock(&svc_run_lock);
 }
-- 
1.8.3.1

