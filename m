From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH 06/12] compat.c: Remove dependence on nfsd private headers
Date: Thu,  3 Dec 2009 20:29:27 +0200
Message-ID: <1259864967-4801-1-git-send-email-bharrosh@panasas.com>
References: <4B1802D0.8060206@panasas.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:15593 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754249AbZLCS3Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Dec 2009 13:29:24 -0500
In-Reply-To: <4B1802D0.8060206@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Two nfsd related headers where included but never actually
used. The linux/nfsd/nfsd.h file will eventually be moved
to fs/nfsd directory as it is only needed by nfsd itself.

There are 3 more compat.c files in the Kernel at other ARCHs
that wrongly #include nfsd headers. Once these are fixed the
headers can be moved.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/compat.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/compat.c b/fs/compat.c
index 6c19040..00d90c2 100644
--- a/fs/compat.c
+++ b/fs/compat.c
@@ -38,8 +38,6 @@
 #include <linux/dirent.h>
 #include <linux/fsnotify.h>
 #include <linux/highuid.h>
-#include <linux/sunrpc/svc.h>
-#include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/syscall.h>
 #include <linux/personality.h>
 #include <linux/rwsem.h>
-- 
1.6.5.2

