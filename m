Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55462 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727114AbeIYOT4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 25 Sep 2018 10:19:56 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id DEB79C015C37
        for <linux-nfs@vger.kernel.org>; Tue, 25 Sep 2018 08:13:34 +0000 (UTC)
From: Zhi Li <yieli@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: steved@redhat.com, Zhi Li <yieli@redhat.com>
Subject: [PATCH] getnetconfig.c: fix a BAD_FREE (CWE-763)
Date: Tue, 25 Sep 2018 16:13:32 +0800
Message-Id: <1537863212-1389-1-git-send-email-yieli@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Zhi Li <yieli@redhat.com>
---

https://bugzilla.redhat.com/show_bug.cgi?id=1631614

 src/getnetconfig.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/src/getnetconfig.c b/src/getnetconfig.c
index d67d97d..869556d 100644
--- a/src/getnetconfig.c
+++ b/src/getnetconfig.c
@@ -681,6 +681,7 @@ struct netconfig	*ncp;
 {
     struct netconfig	*p;
     char	*tmp;
+    char	*t;
     u_int	i;
 
     if ((tmp=malloc(MAXNETCONFIGLINE)) == NULL)
@@ -700,12 +701,12 @@ struct netconfig	*ncp;
      */
     *p = *ncp;
     p->nc_netid = (char *)strcpy(tmp,ncp->nc_netid);
-    tmp = strchr(tmp, 0) + 1;
-    p->nc_protofmly = (char *)strcpy(tmp,ncp->nc_protofmly);
-    tmp = strchr(tmp, 0) + 1;
-    p->nc_proto = (char *)strcpy(tmp,ncp->nc_proto);
-    tmp = strchr(tmp, 0) + 1;
-    p->nc_device = (char *)strcpy(tmp,ncp->nc_device);
+    t = strchr(tmp, 0) + 1;
+    p->nc_protofmly = (char *)strcpy(t,ncp->nc_protofmly);
+    t = strchr(t, 0) + 1;
+    p->nc_proto = (char *)strcpy(t,ncp->nc_proto);
+    t = strchr(t, 0) + 1;
+    p->nc_device = (char *)strcpy(t,ncp->nc_device);
     p->nc_lookups = (char **)malloc((size_t)(p->nc_nlookups+1) * sizeof(char *));
     if (p->nc_lookups == NULL) {
 	free(p->nc_netid);
@@ -714,8 +715,8 @@ struct netconfig	*ncp;
 	return(NULL);
     }
     for (i=0; i < p->nc_nlookups; i++) {
-    	tmp = strchr(tmp, 0) + 1;
-    	p->nc_lookups[i] = (char *)strcpy(tmp,ncp->nc_lookups[i]);
+	t = strchr(t, 0) + 1;
+	p->nc_lookups[i] = (char *)strcpy(t,ncp->nc_lookups[i]);
     }
     return(p);
 }
-- 
2.7.5
