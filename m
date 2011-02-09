Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50332 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750898Ab1BIGiL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Feb 2011 01:38:11 -0500
Message-ID: <4D523618.8080106@cn.fujitsu.com>
Date: Wed, 09 Feb 2011 14:37:12 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: Steve Dickson <SteveD@redhat.com>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] Gssd: modify wrong err message at handle_gssd_upcall
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Modify wrong err message at handle_gssd_upcall when 
sscanf encryption types fail.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 utils/gssd/gssd_proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index c301d46..41328c9 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -1245,7 +1245,7 @@ handle_gssd_upcall(struct clnt_info *clp)
 			goto out;
 		if (sscanf(p, "enctypes=%s", enctypes) != 1) {
 			printerr(0, "WARNING: handle_gssd_upcall: "
-				    "failed to parse target name "
+				    "failed to parse encryption types "
 				    "in upcall string '%s'\n", lbuf);
 			goto out;
 		}
-- 
1.7.3.5


