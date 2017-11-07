Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48668 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755156AbdKGO32 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Nov 2017 09:29:28 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: fix a deadlock in nfs v4.1 client initialization
Date: Tue,  7 Nov 2017 09:29:27 -0500
Message-Id: <20171107142927.9468-1-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following deadlock can occur between a process waiting for a client
to initialize in while walking the client list and another process
waiting for the nfs_clid_init_mutex so it can initialize that client:

Process 1                               Process 2
---------                               ---------
spin_lock(&nn->nfs_client_lock);
list_add_tail(&CLIENTA->cl_share_link,
        &nn->nfs_client_list);
spin_unlock(&nn->nfs_client_lock);
                                        spin_lock(&nn->nfs_client_lock);
                                        list_add_tail(&CLIENTB->cl_share_link,
                                                &nn->nfs_client_list);
                                        spin_unlock(&nn->nfs_client_lock);
                                        mutex_lock(&nfs_clid_init_mutex);
                                        nfs41_walk_client_list(clp, result, cred);
                                        nfs_wait_client_init_complete(CLIENTA);
(waiting for nfs_clid_init_mutex)

Make sure nfs_match_client() only evaluates clients that have completed
initialization in order to prevent that deadlock.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfs/client.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 22880ef..8b093994 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -291,12 +291,21 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 	const struct sockaddr *sap = data->addr;
 	struct nfs_net *nn = net_generic(data->net, nfs_net_id);
 
+again:
 	list_for_each_entry(clp, &nn->nfs_client_list, cl_share_link) {
 	        const struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;
 		/* Don't match clients that failed to initialise properly */
 		if (clp->cl_cons_state < 0)
 			continue;
 
+		if (clp->cl_minorversion > 0 &&
+				clp->cl_cons_state > NFS_CS_READY) {
+			spin_unlock(&nn->nfs_client_lock);
+			nfs_wait_client_init_complete(clp);
+			spin_lock(&nn->nfs_client_lock);
+			goto again;
+		}
+
 		/* Different NFS versions cannot share the same nfs_client */
 		if (clp->rpc_ops != data->nfs_mod->rpc_ops)
 			continue;
-- 
2.9.5

