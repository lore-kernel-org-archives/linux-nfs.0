From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH 11/12] vfs: nfsctl.c un-used nfsd #includes
Date: Thu,  3 Dec 2009 20:30:43 +0200
Message-ID: <1259865043-4941-1-git-send-email-bharrosh@panasas.com>
References: <4B1802D0.8060206@panasas.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:21049 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756139AbZLCSai (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Dec 2009 13:30:38 -0500
In-Reply-To: <4B1802D0.8060206@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Only linux/nfsd/syscall.h is actually used. Remove the
other nfsd #includes, so they can be moved to source
directory.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfsctl.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfsctl.c b/fs/nfsctl.c
index 8f9a205..d3854d9 100644
--- a/fs/nfsctl.c
+++ b/fs/nfsctl.c
@@ -7,8 +7,6 @@
 #include <linux/types.h>
 #include <linux/file.h>
 #include <linux/fs.h>
-#include <linux/sunrpc/svc.h>
-#include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/syscall.h>
 #include <linux/cred.h>
 #include <linux/sched.h>
-- 
1.6.5.2

