From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 02/35] pnfsd: define NFSDDBG_PNFS
Date: Mon,  7 Dec 2009 11:30:10 +0200
Message-ID: <1260178210-14710-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:46430 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759252AbZLGJ3O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 04:29:14 -0500
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[extraced from pnfsd: Initial pNFS server implementation.]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfsd/debug.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfsd/debug.h b/include/linux/nfsd/debug.h
index ee4aa91..9926c24 100644
--- a/include/linux/nfsd/debug.h
+++ b/include/linux/nfsd/debug.h
@@ -32,6 +32,7 @@
 #define NFSDDBG_REPCACHE	0x0080
 #define NFSDDBG_XDR		0x0100
 #define NFSDDBG_LOCKD		0x0200
+#define NFSDDBG_PNFS		0x0400
 #define NFSDDBG_ALL		0x7FFF
 #define NFSDDBG_NOCHANGE	0xFFFF
 
-- 
1.6.5.1

