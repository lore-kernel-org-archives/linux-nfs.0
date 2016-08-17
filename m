Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37560 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752435AbcHQR5J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Aug 2016 13:57:09 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 65E0381243
	for <linux-nfs@vger.kernel.org>; Wed, 17 Aug 2016 17:50:32 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (vpn-57-39.rdu2.redhat.com [10.10.57.39])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u7HHoVBG026611
	for <linux-nfs@vger.kernel.org>; Wed, 17 Aug 2016 13:50:32 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] nss_getpwnam: correctly check for negative values in unsigned ints.
Date: Wed, 17 Aug 2016 13:50:30 -0400
Message-Id: <1471456230-10624-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit e22368f6 introduce a couple checks for
negative buffer lengths. The variables are unsigned
ints so UINT_MAX should be used.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 nss.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/nss.c b/nss.c
index 8e9412d..47c6b14 100644
--- a/nss.c
+++ b/nss.c
@@ -44,6 +44,7 @@
 #include <netdb.h>
 #include <err.h>
 #include <grp.h>
+#include <limits.h>
 #include "nfsidmap.h"
 #include "nfsidmap_internal.h"
 #include "cfg.h"
@@ -171,7 +172,7 @@ static struct passwd *nss_getpwnam(const char *name, const char *domain, int *er
 	char *localname;
 	int err = ENOMEM;
 
-	if (buflen < 0)
+	if (buflen > UINT_MAX)
 		goto err;
 
 	buf = malloc(sizeof(*buf) + buflen);
@@ -240,7 +241,7 @@ static int nss_name_to_gid(char *name, gid_t *gid)
 		goto out;
 
 	err = -ENOMEM;
-	if (buflen < 0)
+	if (buflen > UINT_MAX)
 		goto out;
 
 	do {
-- 
2.7.4

