Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:32965 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbbG3NlW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 09:41:22 -0400
Received: by pdbnt7 with SMTP id nt7so24915827pdb.0
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 06:41:22 -0700 (PDT)
Message-ID: <55BA2974.6000206@gmail.com>
Date: Thu, 30 Jul 2015 21:41:08 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH 2/7 v2] NFS: Error out when register_shrinker fail in register_nfs_fs
References: <55BA290B.2020704@gmail.com>
In-Reply-To: <55BA290B.2020704@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 1d3d4437ea "vmscan: per-node deferred work" have made
register_shrinker can return an intergater error.

If register_shrinker() fail, the later unregister_shrinker() will
 cause a NULL pointer access.

v2, same as v1.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/super.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index aa62004..383a027 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -381,9 +381,12 @@ int __init register_nfs_fs(void)
 	ret = nfs_register_sysctl();
 	if (ret < 0)
 		goto error_2;
-	register_shrinker(&acl_shrinker);
+	ret = register_shrinker(&acl_shrinker);
+	if (ret < 0)
+		goto error_3;
 	return 0;
-
+error_3:
+	nfs_unregister_sysctl();
 error_2:
 	unregister_nfs4_fs();
 error_1:
-- 
2.4.3

