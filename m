Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51914 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753372AbeFDOuy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Jun 2018 10:50:54 -0400
Received: from smtp.corp.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.26])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 55DBA379E2E
        for <linux-nfs@vger.kernel.org>; Mon,  4 Jun 2018 14:50:54 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-116-215.phx2.redhat.com [10.3.116.215])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 0B8733083326
        for <linux-nfs@vger.kernel.org>; Mon,  4 Jun 2018 14:50:53 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/4] Removed format expects argument of type errors
Date: Mon,  4 Jun 2018 10:50:50 -0400
Message-Id: <20180604145051.146390-4-steved@redhat.com>
In-Reply-To: <20180604145051.146390-1-steved@redhat.com>
References: <20180604145051.146390-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

idmapd.c: In function 'getfield':
idmapd.c:936:4: error: format '%o' expects argument of type 'unsigned
int *', but argument 3 has type 'int *' [-Werror=format=]
    if ((n = sscanf(bp, "\\%03o", &val)) != 1)

nfsidmap.c: In function 'key_invalidate':
nfsidmap.c:322:3: error: format '%x' expects argument of type 'unsigned
int *', but argument 3 has type 'key_serial_t *' [-Werror=format=]
   sscanf(buf, "%x", &key);

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/idmapd/idmapd.c     | 3 ++-
 utils/nfsidmap/nfsidmap.c | 2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index b87c4dd..2585fb2 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -923,7 +923,8 @@ static int
 getfield(char **bpp, char *fld, size_t fldsz)
 {
 	char *bp;
-	int val, n;
+	unsigned int val; 
+	int n;
 
 	while ((bp = strsep(bpp, " ")) != NULL && bp[0] == '\0')
 		;
diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index 374bc5d..d3967a3 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -283,7 +283,7 @@ static int key_invalidate(char *keystr, int keymask)
 {
 	FILE *fp;
 	char buf[BUFSIZ], *ptr;
-	key_serial_t key;
+	unsigned int key;
 	int mask;
 
 	xlog_syslog(0);
-- 
1.8.3.1

