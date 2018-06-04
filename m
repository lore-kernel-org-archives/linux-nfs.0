Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36474 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752370AbeFDOuy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Jun 2018 10:50:54 -0400
Received: from smtp.corp.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.26])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 019BCDF15C
        for <linux-nfs@vger.kernel.org>; Mon,  4 Jun 2018 14:50:53 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-116-215.phx2.redhat.com [10.3.116.215])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 9907C3083321
        for <linux-nfs@vger.kernel.org>; Mon,  4 Jun 2018 14:50:53 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/4] Removed ISO C does not support the '%m' gnu_printf format errors
Date: Mon,  4 Jun 2018 10:50:49 -0400
Message-Id: <20180604145051.146390-3-steved@redhat.com>
In-Reply-To: <20180604145051.146390-1-steved@redhat.com>
References: <20180604145051.146390-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsstat.c: In function 'mounts':
nfsstat.c:1016:3: error: ISO C does not support the '%m' gnu_printf
format [-Werror=format=]
   fprintf(stderr, "Warning: %s: %m\n", name);
   ^
nfsstat.c: In function 'get_stats':
nfsstat.c:1093:6: error: ISO C does not support the '%m' gnu_printf
format [-Werror=format=]
      label, file);

statd.c: In function 'set_nlm_port':
statd.c:235:5: error: ISO C does not support the '%m' gnu_printf format
[-Werror=format=]
     name_p, type);
     ^
statd.c:238:3: error: ISO C does not support the '%m' gnu_printf format
[-Werror=format=]
   fprintf(stderr, "%s: failed to open %s: %m\n", name_p, pathbuf);

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/nfsstat/nfsstat.c | 6 +++---
 utils/statd/statd.c     | 7 ++++---
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index c779053..8fccea7 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -1013,7 +1013,7 @@ mounts(const char *name)
 	 * be a fatal error -- it usually means the module isn't loaded.
 	 */
 	if ((fp = fopen(name, "r")) == NULL) {
-		fprintf(stderr, "Warning: %s: %m\n", name);
+		fprintf(stderr, "Warning: %s: %s\n", name, strerror(errno));
 		return 0;
 	}
 
@@ -1089,8 +1089,8 @@ out:
 		fclose(fp);
 	if (err) {
 		if (!other_opt) {
-			fprintf(stderr, "Error: No %s Stats (%s: %m). \n",
-					label, file);
+			fprintf(stderr, "Error: No %s Stats (%s: %s). \n",
+					label, file, strerror(errno));
 			exit(2);
 		}
 		*opt = 0;
diff --git a/utils/statd/statd.c b/utils/statd/statd.c
index 563a272..2cc6cf3 100644
--- a/utils/statd/statd.c
+++ b/utils/statd/statd.c
@@ -231,11 +231,12 @@ static void set_nlm_port(char *type, int port)
 	}
 	if (fd >= 0) {
 		if (write(fd, nbuf, strlen(nbuf)) != (ssize_t)strlen(nbuf))
-			fprintf(stderr, "%s: fail to set NLM %s port: %m\n",
-				name_p, type);
+			fprintf(stderr, "%s: fail to set NLM %s port: %s\n",
+				name_p, type, strerror(errno));
 		close(fd);
 	} else
-		fprintf(stderr, "%s: failed to open %s: %m\n", name_p, pathbuf);
+		fprintf(stderr, "%s: failed to open %s: %s\n", 
+			name_p, pathbuf, strerror(errno));
 }
 
 /*
-- 
1.8.3.1

