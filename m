Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:32121 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753176Ab1JSUne (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Oct 2011 16:43:34 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p9JKhYpN016704
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 19 Oct 2011 16:43:34 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p9JKhXJR014441
	for <linux-nfs@vger.kernel.org>; Wed, 19 Oct 2011 16:43:34 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] rpcdebug: Add missing debug flags
Date: Wed, 19 Oct 2011 16:43:33 -0400
Message-Id: <1319057013-19015-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch added the following debug flags:

fscache - enable FSCache debugging
pnfs - enable general pNFS debugging
pnfs_ld - enable file layout pNFS debugging

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/include/nfs/debug.h |    3 +++
 tools/rpcdebug/rpcdebug.c   |    3 +++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/support/include/nfs/debug.h b/support/include/nfs/debug.h
index d391e91..dbec5ba 100644
--- a/support/include/nfs/debug.h
+++ b/support/include/nfs/debug.h
@@ -76,6 +76,9 @@ enum {
 #define NFSDBG_CALLBACK		0x0100
 #define NFSDBG_CLIENT		0x0200
 #define NFSDBG_MOUNT		0x0400
+#define NFSDBG_FSCACHE		0x0800
+#define NFSDBG_PNFS			0x1000
+#define NFSDBG_PNFS_LD		0x2000
 #define NFSDBG_ALL		0xFFFF
 
 #endif /* _NFS_DEBUG_H */
diff --git a/tools/rpcdebug/rpcdebug.c b/tools/rpcdebug/rpcdebug.c
index 275a491..444616d 100644
--- a/tools/rpcdebug/rpcdebug.c
+++ b/tools/rpcdebug/rpcdebug.c
@@ -167,6 +167,9 @@ static struct flagmap {
 	FLAG(NFS,       CALLBACK),
 	FLAG(NFS,       CLIENT),
 	FLAG(NFS,       MOUNT),
+	FLAG(NFS,       FSCACHE),
+	FLAG(NFS,       PNFS),
+	FLAG(NFS,       PNFS_LD),
 	FLAG(NFS,	ALL),
 
 	/* nfsd */
-- 
1.7.6.2

