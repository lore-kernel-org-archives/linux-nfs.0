Return-Path: linux-kernel-owner@vger.kernel.org
From: Kevin Mulvey <king.feruke@gmail.com>
To: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Cc: Kevin Mulvey <kmulvey@linux.com>
Subject: [PATCH] nfs: correct typo in nfs Kconfig
Date: Mon, 12 Jan 2015 17:55:10 -0500
Message-Id: <1421103310-25755-1-git-send-email-king.feruke@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kevin Mulvey <kmulvey@linux.com>

The help section of NFS_V3_ACL currently mentions the "noacl" option
but the correct syntax is "no_acl".

Signed-off-by: Kevin Mulvey <kmulvey@linux.com>
---
 fs/nfs/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 3dece03..7de164b 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -65,7 +65,7 @@ config NFS_V3_ACL
 	  applications to access and modify ACLs on files on the server.
 
 	  Most NFS servers don't support the Solaris NFSv3 ACL protocol
-	  extension.  You can choose N here or specify the "noacl" mount
+	  extension.  You can choose N here or specify the "no_acl" mount
 	  option to prevent your NFS client from trying to use the NFSv3
 	  ACL protocol.
 
-- 
2.1.0

