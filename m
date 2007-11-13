From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/25] NFS: eliminate NIPQUAD(clp->cl_addr.sin_addr)
Date: Tue, 13 Nov 2007 13:31:27 -0500
Message-ID: <20071113183126.5087.27810.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Is0Xl-0000Mj-IS
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:31:25 -0800
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Is0Xr-0007qb-9m
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:31:31 -0800
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

To ensure the NFS client displays IPv6 addresses properly, replace
address-specific NIPQUAD() invocations with a call to the RPC client to
get a formatted string representing the remote peer's address.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
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
index 91e26e2..5a742a8 100644
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


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
