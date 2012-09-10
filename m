Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:63560 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752923Ab2IJAuk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Sep 2012 20:50:40 -0400
From: ycnian@gmail.com
To: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Cc: Yanchuan Nian <ycnian@gmail.com>
Subject: [PATCH] NFS: Remove unnecessary semicolons (fs/nfs/client.c)
Date: Mon, 10 Sep 2012 08:40:16 +0800
Message-Id: <1347237616-3835-1-git-send-email-ycnian@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yanchuan Nian <ycnian@gmail.com>

There are some unnecessary semicolons in function find_nfs_version. Just remove them.

Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
---
 fs/nfs/client.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 9969444..d2e1612 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -93,10 +93,10 @@ static struct nfs_subversion *find_nfs_version(unsigned int version)
 			spin_unlock(&nfs_version_lock);
 			return nfs;
 		}
-	};
+	}
 
 	spin_unlock(&nfs_version_lock);
-	return ERR_PTR(-EPROTONOSUPPORT);;
+	return ERR_PTR(-EPROTONOSUPPORT);
 }
 
 struct nfs_subversion *get_nfs_version(unsigned int version)
-- 
1.7.4.4

