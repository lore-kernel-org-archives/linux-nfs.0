Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:40671 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932579AbbGJVFd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jul 2015 17:05:33 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH 5/9] NFS: Combine nfs_idmap_{init|quit}() and nfs_idmap_{init|quit}_keyring()
Date: Fri, 10 Jul 2015 16:58:13 -0400
Message-ID: <1436561897-8051-6-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1436561897-8051-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1436561897-8051-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The idmap_init() and idmap_quit() functions only exist to call the
_keyring() version.  Let's just call the keyring() functions directly.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4idmap.c | 14 ++------------
 1 file changed, 2 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs4idmap.c b/fs/nfs/nfs4idmap.c
index 535dfc6..2e49022 100644
--- a/fs/nfs/nfs4idmap.c
+++ b/fs/nfs/nfs4idmap.c
@@ -184,7 +184,7 @@ static struct key_type key_type_id_resolver = {
 	.read		= user_read,
 };
 
-static int nfs_idmap_init_keyring(void)
+int nfs_idmap_init(void)
 {
 	struct cred *cred;
 	struct key *keyring;
@@ -230,7 +230,7 @@ failed_put_cred:
 	return ret;
 }
 
-static void nfs_idmap_quit_keyring(void)
+void nfs_idmap_quit(void)
 {
 	key_revoke(id_resolver_cache->thread_keyring);
 	unregister_key_type(&key_type_id_resolver);
@@ -492,16 +492,6 @@ nfs_idmap_delete(struct nfs_client *clp)
 	kfree(idmap);
 }
 
-int nfs_idmap_init(void)
-{
-	return nfs_idmap_init_keyring();
-}
-
-void nfs_idmap_quit(void)
-{
-	nfs_idmap_quit_keyring();
-}
-
 static int nfs_idmap_prepare_message(char *desc, struct idmap *idmap,
 				     struct idmap_msg *im,
 				     struct rpc_pipe_msg *msg)
-- 
2.4.5

