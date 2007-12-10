From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/27] NFS: eliminate NIPQUAD(clp->cl_addr.sin_addr)
Date: Mon, 10 Dec 2007 14:57:16 -0500
Message-ID: <20071210195716.2823.83484.stgit@manray.1015granger.net>
References: <20071210195106.2823.43884.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:35301 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752567AbXLJUDL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 15:03:11 -0500
In-Reply-To: <20071210195106.2823.43884.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To ensure the NFS client displays IPv6 addresses properly, replace
address family-specific NIPQUAD() invocations with a call to the RPC
client to get a formatted string representing the remote peer's
address.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
---

 fs/nfs/client.c     |   12 ++++++------
 fs/nfs/delegation.c |   10 ++++++----
 fs/nfs/nfs4state.c  |    9 +++++----
 fs/nfs/super.c      |    5 +++--
 4 files changed, 20 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index b24b6db..5ab1ca1 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1265,10 +1265,10 @@ static int nfs_server_list_show(struct seq_file *m, void *v)
 	/* display one transport per line on subsequent lines */
 	clp = list_entry(v, struct nfs_client, cl_share_link);
 
-	seq_printf(m, "v%u %02x%02x%02x%02x %4hx %3d %s\n",
+	seq_printf(m, "v%u %s %s %3d %s\n",
 		   clp->rpc_ops->version,
-		   NIPQUAD(clp->cl_addr.sin_addr),
-		   ntohs(clp->cl_addr.sin_port),
+		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_ADDR),
+		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_PORT),
 		   atomic_read(&clp->cl_count),
 		   clp->cl_hostname);
 
@@ -1344,10 +1344,10 @@ static int nfs_volume_list_show(struct seq_file *m, void *v)
 		 (unsigned long long) server->fsid.major,
 		 (unsigned long long) server->fsid.minor);
 
-	seq_printf(m, "v%u %02x%02x%02x%02x %4hx %-7s %-17s\n",
+	seq_printf(m, "v%u %s %s %-7s %-17s\n",
 		   clp->rpc_ops->version,
-		   NIPQUAD(clp->cl_addr.sin_addr),
-		   ntohs(clp->cl_addr.sin_port),
+		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_ADDR),
+		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_PORT),
 		   dev,
 		   fsid);
 
diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 11833f4..b03dcd8 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -156,8 +156,9 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 		if (memcmp(&delegation->stateid, &nfsi->delegation->stateid,
 					sizeof(delegation->stateid)) != 0 ||
 				delegation->type != nfsi->delegation->type) {
-			printk("%s: server %u.%u.%u.%u, handed out a duplicate delegation!\n",
-					__FUNCTION__, NIPQUAD(clp->cl_addr.sin_addr));
+			printk(KERN_WARNING "%s: server %s handed out "
+					"a duplicate delegation!\n",
+					__FUNCTION__, clp->cl_hostname);
 			status = -EIO;
 		}
 	}
@@ -314,8 +315,9 @@ void nfs_expire_all_delegations(struct nfs_client *clp)
 	__module_get(THIS_MODULE);
 	atomic_inc(&clp->cl_count);
 	task = kthread_run(nfs_do_expire_all_delegations, clp,
-			"%u.%u.%u.%u-delegreturn",
-			NIPQUAD(clp->cl_addr.sin_addr));
+				"%s-delegreturn",
+				rpc_peeraddr2str(clp->cl_rpcclient,
+							RPC_DISPLAY_ADDR));
 	if (!IS_ERR(task))
 		return;
 	nfs_put_client(clp);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 23a9a36..86f95d4 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -755,8 +755,9 @@ static void nfs4_recover_state(struct nfs_client *clp)
 
 	__module_get(THIS_MODULE);
 	atomic_inc(&clp->cl_count);
-	task = kthread_run(reclaimer, clp, "%u.%u.%u.%u-reclaim",
-			NIPQUAD(clp->cl_addr.sin_addr));
+	task = kthread_run(reclaimer, clp, "%s-reclaim",
+				rpc_peeraddr2str(clp->cl_rpcclient,
+							RPC_DISPLAY_ADDR));
 	if (!IS_ERR(task))
 		return;
 	nfs4_clear_recover_bit(clp);
@@ -967,8 +968,8 @@ out:
 	module_put_and_exit(0);
 	return 0;
 out_error:
-	printk(KERN_WARNING "Error: state recovery failed on NFSv4 server %u.%u.%u.%u with error %d\n",
-				NIPQUAD(clp->cl_addr.sin_addr), -status);
+	printk(KERN_WARNING "Error: state recovery failed on NFSv4 server %s"
+			" with error %d\n", clp->cl_hostname, -status);
 	set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
 	goto out;
 }
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 4fed577..6b004d8 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -467,8 +467,9 @@ static int nfs_show_options(struct seq_file *m, struct vfsmount *mnt)
 
 	nfs_show_mount_options(m, nfss, 0);
 
-	seq_printf(m, ",addr="NIPQUAD_FMT,
-		NIPQUAD(nfss->nfs_client->cl_addr.sin_addr));
+	seq_printf(m, ",addr=%s",
+			rpc_peeraddr2str(nfss->nfs_client->cl_rpcclient,
+							RPC_DISPLAY_ADDR));
 
 	return 0;
 }

