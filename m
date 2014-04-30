Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:20875 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422649AbaD3PSc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Apr 2014 11:18:32 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s3UFIUPE016750
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 30 Apr 2014 11:18:31 -0400
Received: from smallhat.boston.devel.redhat.com (vpn-63-95.rdu2.redhat.com [10.10.63.95])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s3UFIUYU028779
	for <linux-nfs@vger.kernel.org>; Wed, 30 Apr 2014 11:18:30 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] libnfsidmap: id_as_chars() fails zero value ids.
Date: Wed, 30 Apr 2014 11:18:28 -0400
Message-Id: <1398871108-18213-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Root has a zero value id which is valid and
should not be mapped to nfsnobody

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 libnfsidmap.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/libnfsidmap.c b/libnfsidmap.c
index 641d766..92bc493 100644
--- a/libnfsidmap.c
+++ b/libnfsidmap.c
@@ -99,8 +99,12 @@ static char * toupper_str(char *s)
 static int id_as_chars(char *name, int *id)
 {
 	long int value = strtol(name, NULL, 10);
-	if (value == 0)
-		return 0;
+
+	if (value == 0) {
+		/* zero value ids are valid */
+		if (strcmp(name, "0") != 0)
+			return 0;
+	}
 	*id = (int)value;
 	return 1;
 }
-- 
1.9.0

