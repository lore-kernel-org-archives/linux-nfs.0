Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10343 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751089AbaAHSpY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Jan 2014 13:45:24 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s08IjNaJ010638
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 8 Jan 2014 13:45:23 -0500
Received: from smallhat.boston.devel.redhat.com (smallhat.boston.devel.redhat.com [10.19.60.65])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s08IjNP2032080
	for <linux-nfs@vger.kernel.org>; Wed, 8 Jan 2014 13:45:23 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] exportfs: Don't buffer overflow on exports that are too big.
Date: Wed,  8 Jan 2014 13:47:10 -0500
Message-Id: <1389206830-5368-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signe-doff-by: Steve Dickson <steved@redhat.com>
---
 utils/exportfs/exportfs.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 9ea86cb..8c86790 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -452,6 +452,8 @@ static int test_export(char *path, int with_fsid)
 	bp += n;
 	len -= n;
 	qword_add(&bp, &len, path);
+	if (len < 1)
+		return 0;
 	snprintf(bp, len, " 3 %d 65534 65534 0\n", with_fsid ? NFSEXP_FSID : 0);
 	fd = open("/proc/net/rpc/nfsd.export/channel", O_WRONLY);
 	if (fd < 0)
-- 
1.8.3.1

