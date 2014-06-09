Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:49950 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878AbaFITd2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Jun 2014 15:33:28 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 2/3] NFS Return -EPERM if no supported or matching SECINFO flavor
Date: Mon, 9 Jun 2014 15:33:20 -0400
Message-ID: <1402342401-5640-3-git-send-email-andros@netapp.com>
In-Reply-To: <1402342401-5640-1-git-send-email-andros@netapp.com>
References: <1402342401-5640-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Do not return RPC_AUTH_UNIX if SEINFO reply tests fail. This
prevents an infinite loop of NFS4ERR_WRONGSEC for non RPC_AUTH_UNIX mounts.

Without this patch, a mount with no sec= option to a server
that does not include RPC_AUTH_UNIX in the
SECINFO return can be presented with an attemtp to use RPC_AUTH_UNIX
which will result in an NFS4ERR_WRONG_SEC which will prompt the SECINFO
call which will again try RPC_AUTH_UNIX....

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4namespace.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 1b86fef..fd4dcb6 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -140,10 +140,11 @@ static size_t nfs_parse_server_name(char *string, size_t len,
  * @flavors: List of security tuples returned by SECINFO procedure
  *
  * Return the pseudoflavor of the first security mechanism in
- * "flavors" that is locally supported.  Return RPC_AUTH_UNIX if
- * no matching flavor is found in the array.  The "flavors" array
+ * "flavors" that is locally supported. The "flavors" array
  * is searched in the order returned from the server, per RFC 3530
  * recommendation.
+ *
+ * Return -EPERM if no matching flavor is found in the array.
  */
 static rpc_authflavor_t nfs_find_best_sec(struct nfs_server *server,
 					  struct nfs4_secinfo_flavors *flavors)
@@ -170,11 +171,7 @@ static rpc_authflavor_t nfs_find_best_sec(struct nfs_server *server,
 		}
 	}
 
-	/* if there were any sec= options then nothing matched */
-	if (server->auth_info.flavor_len > 0)
-		return -EPERM;
-
-	return RPC_AUTH_UNIX;
+	return -EPERM;
 }
 
 static rpc_authflavor_t nfs4_negotiate_security(struct inode *inode, struct qstr *name)
-- 
1.8.3.1

