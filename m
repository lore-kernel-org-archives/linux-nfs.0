Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f170.google.com ([209.85.192.170]:44719 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753441AbaG3N0a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 09:26:30 -0400
Received: by mail-pd0-f170.google.com with SMTP id g10so1455655pdj.29
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 06:26:29 -0700 (PDT)
Message-ID: <53D8F26D.8070304@gmail.com>
Date: Wed, 30 Jul 2014 21:26:05 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH] NFSD: Decrease nfsd_users in nfsd_startup_generic fail
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If nfsd_startup_generic fail, nfsd_users isn't decreased right now.

NFSD restarts will return 0 at the first nfsd_users checking,
after that, nfs4_state_start_net() will meet a bad laundry_wq
(I meet NULL), after nfsd4_grace timeout, the kernel will crash.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfssvc.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 5d026dc..752d56b 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -221,7 +221,8 @@ static int nfsd_startup_generic(int nrservs)
 	 */
 	ret = nfsd_racache_init(2*nrservs);
 	if (ret)
-		return ret;
+		goto dec_users;
+
 	ret = nfs4_state_start();
 	if (ret)
 		goto out_racache;
@@ -229,6 +230,8 @@ static int nfsd_startup_generic(int nrservs)
 
 out_racache:
 	nfsd_racache_shutdown();
+dec_users:
+	nfsd_users--;
 	return ret;
 }
 
-- 
1.9.3

