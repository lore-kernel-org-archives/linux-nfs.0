Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:44926 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751166AbeFTMMx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Jun 2018 08:12:53 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.rdu2.redhat.com [10.11.54.6])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id D512140200A7
        for <linux-nfs@vger.kernel.org>; Wed, 20 Jun 2018 12:12:52 +0000 (UTC)
Message-ID: <1529496770.7473.11.camel@redhat.com>
Subject: [PATCH 3/5] nfs-utils: swap xlog_err for less fatal version
From: Justin Mitchell <jumitche@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Steve Dickson <steved@redhat.com>
Date: Wed, 20 Jun 2018 13:12:50 +0100
In-Reply-To: <1529496583.7473.8.camel@redhat.com>
References: <1529496583.7473.8.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use of xlog_err is immediately fatal, switch to using
xlog(L_ERROR, ...) instead so that the error handling and
cleanup mechanisms can operate properly

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 support/nfs/conffile.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 51b85f2..c7c3a62 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -495,7 +495,7 @@ conf_readfile(const char *path)
 {
 	struct stat sb;
 	if (!path) {
-		xlog_err("conf_readfile: no path given");
+		xlog(L_ERROR, "conf_readfile: no path given");
 		return NULL;
 	}
 
-- 
1.8.3.1



