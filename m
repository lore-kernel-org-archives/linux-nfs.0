Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35590 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750958Ab1LVOsz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Dec 2011 09:48:55 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pBMEmt75001212
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 22 Dec 2011 09:48:55 -0500
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id pBMEmsgO005698
	for <linux-nfs@vger.kernel.org>; Thu, 22 Dec 2011 09:48:54 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] nfs4_setfacl failed with unexpected messages
Date: Thu, 22 Dec 2011 09:49:10 -0500
Message-Id: <1324565350-9764-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: faizan <faizan.husain@in.ibm.com>

When the format of the input file is incorrect nfs4_setfacl
fails with a *** glibc detected *** error.

See: https://bugzilla.redhat.com/show_bug.cgi?id=693422

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 libnfs4acl/nfs4_ace_from_string.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/libnfs4acl/nfs4_ace_from_string.c b/libnfs4acl/nfs4_ace_from_string.c
index 510ffee..d26c829 100644
--- a/libnfs4acl/nfs4_ace_from_string.c
+++ b/libnfs4acl/nfs4_ace_from_string.c
@@ -86,9 +86,10 @@ free_fields(char *fields[NUMFIELDS])
 {
 	int i;
 
-	for (i = 0; i < NUMFIELDS; i++)
-		if (fields[i] != NULL)
-			free(fields[i]);
+	for (i = 0; i < NUMFIELDS; i++) {
+		free(fields[i]);
+		fields[i] = NULL;
+	}
 }
 
 int
@@ -107,7 +108,7 @@ parse_alloc_fields(char *buf, char *fields[NUMFIELDS])
 			count++;
 	}
 	if (count != 3)
-		goto out_free;
+		return -EINVAL;
 
 	for (i = 0; i < NUMFIELDS; i++) {
 		field = strsep(&buf, ":");
-- 
1.7.7.3

