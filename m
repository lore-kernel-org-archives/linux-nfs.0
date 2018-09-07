Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36788 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726151AbeIGWoB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Sep 2018 18:44:01 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 05/13] getnetconfig.c: cppcheck_warning
Date: Fri,  7 Sep 2018 14:01:43 -0400
Message-Id: <20180907180151.178872-6-steved@redhat.com>
In-Reply-To: <20180907180151.178872-1-steved@redhat.com>
References: <20180907180151.178872-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Memory leak: p
Memory leak: tmp

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/getnetconfig.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/src/getnetconfig.c b/src/getnetconfig.c
index 92e7c43..d67d97d 100644
--- a/src/getnetconfig.c
+++ b/src/getnetconfig.c
@@ -709,6 +709,8 @@ struct netconfig	*ncp;
     p->nc_lookups = (char **)malloc((size_t)(p->nc_nlookups+1) * sizeof(char *));
     if (p->nc_lookups == NULL) {
 	free(p->nc_netid);
+	free(p);
+	free(tmp);
 	return(NULL);
     }
     for (i=0; i < p->nc_nlookups; i++) {
-- 
2.17.1
