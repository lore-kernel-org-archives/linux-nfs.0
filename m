Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:38927 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754512Ab1KIDwE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Nov 2011 22:52:04 -0500
Message-ID: <4EB9F8D6.1080302@panasas.com>
Date: Tue, 8 Nov 2011 19:51:50 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Benny Halevy <benny@tonian.com>, NFS list <linux-nfs@vger.kernel.org>
CC: Steve Dickson <steved@redhat.com>
Subject: Subject: [PATCH] SQUASHME: pnfsd: nfs4pnfsd.c should dprint under
 NFSDDBG_PNFS
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I've been squinting  at pnfsd dprints for ages and aching under the wait. So I headed
up to the nfsd/debug.h to add a PNFS channel, and what do you know? there is one!
It's used by nfs4pnfsds.c. Surly  nfs4pnfsd.c is more _PNFS than _PROC.

While at it I changed  nfs4pnfsdlm.c to, also already defined, NFSDDBG_FILELAYOUT
which was unused before this patch.

CC: Steve Dickson <steved@redhat.com>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfsd/nfs4pnfsd.c   |    2 +-
 fs/nfsd/nfs4pnfsdlm.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 18b8fca..f514ebe 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -23,7 +23,7 @@
 
 #include "pnfsd.h"
 
-#define NFSDDBG_FACILITY                NFSDDBG_PROC
+#define NFSDDBG_FACILITY                NFSDDBG_PNFS
 
 /* Globals */
 static u32 current_layoutid = 1;
diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index abc4d83..0f0441a 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -30,7 +30,7 @@
 #include "nfsfh.h"
 #include "nfsd.h"
 
-#define NFSDDBG_FACILITY                NFSDDBG_PROC
+#define NFSDDBG_FACILITY                NFSDDBG_FILELAYOUT
 
 /* Just use a linked list. Do not expect more than 32 dlm_device_entries
  * the first implementation will just use one device per cluster file system
-- 
1.7.6.2


