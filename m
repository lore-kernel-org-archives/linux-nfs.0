Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6349 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753952Ab3KTQsv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Nov 2013 11:48:51 -0500
From: Susant Sahani <ssahani@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] __nc_error() does not check return value from malloc
Date: Wed, 20 Nov 2013 22:19:31 +0530
Message-Id: <1384966173-6229-2-git-send-email-ssahani@redhat.com>
In-Reply-To: <1384966173-6229-1-git-send-email-ssahani@redhat.com>
References: <1384966173-6229-1-git-send-email-ssahani@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Susant Sahani <ssahani@redhat.com>
---
 src/getnetconfig.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/src/getnetconfig.c b/src/getnetconfig.c
index af4a484..2460a6e 100644
--- a/src/getnetconfig.c
+++ b/src/getnetconfig.c
@@ -146,7 +146,8 @@ __nc_error()
 			return (&nc_error);
 	}
 	if ((nc_addr = (int *)thr_getspecific(nc_key)) == NULL) {
-		nc_addr = (int *)malloc(sizeof (int));
+		if((nc_addr = (int *)malloc(sizeof (int))) == NULL)
+			return (&nc_error);
 		if (thr_setspecific(nc_key, (void *) nc_addr) != 0) {
 			if (nc_addr)
 				free(nc_addr);
-- 
1.8.4.2

