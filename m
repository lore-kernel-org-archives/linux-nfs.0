Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:63717 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756870Ab2CPT0L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Mar 2012 15:26:11 -0400
Message-ID: <1331925952.2336.5.camel@localhost>
Subject: [PATCH] Try using machine credentials for RENEW calls
From: Sachin Prabhu <sprabhu@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Fri, 16 Mar 2012 19:25:52 +0000
In-Reply-To: <1331924613.12136.1.camel@lade.trondhjem.org>
References: <1331912791.2336.3.camel@localhost>
	 <1331919386.2518.44.camel@lade.trondhjem.org>
	 <4F637B68.2000202@fifthhorseman.net>
	 <1331924613.12136.1.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Using user credentials for RENEW calls will fail when the user
credentials have expired.

To avoid this, try using the machine credentials when making RENEW
calls. If no machine credentials have been set, fall back to using user
credentials as before.

Signed-off-by: Sachin Prabhu <sprabhu@redhat.com>

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 4539203..10194eb 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -146,6 +146,11 @@ struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp)
 	struct rpc_cred *cred = NULL;
 	struct nfs_server *server;
 
+	/* Use machine credentials if available */
+	cred = nfs4_get_machine_cred_locked(clp);
+	if (cred != NULL)
+		goto out;
+
 	rcu_read_lock();
 	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
 		cred = nfs4_get_renew_cred_server_locked(server);
@@ -153,6 +158,8 @@ struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp)
 			break;
 	}
 	rcu_read_unlock();
+
+out:
 	return cred;
 }
 


