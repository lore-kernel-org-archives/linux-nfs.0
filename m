Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34263 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751642AbdFHPwv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jun 2017 11:52:51 -0400
Subject: [PATCH v2 08/13] NFSv4.1: Handle EXCHGID4_FLAG_CONFIRMED_R during
 NFSv4.1 migration
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 08 Jun 2017 11:52:44 -0400
Message-ID: <20170608155244.18945.66640.stgit@manet.1015granger.net>
In-Reply-To: <20170608154339.18945.5500.stgit@manet.1015granger.net>
References: <20170608154339.18945.5500.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Transparent State Migration copies a client's lease state from the
server where a filesystem used to reside to the server where it now
resides. When an NFSv4.1 client first contacts that destination
server, it uses EXCHANGE_ID to detect trunking relationships.

The lease that was copied there is returned to that client, but the
destination server sets EXCHGID4_FLAG_CONFIRMED_R when replying to
the client. This is because the lease was confirmed on the source
server (before it was copied).

Normally, when CONFIRMED_R is set, a client purges the lease and
creates a new one. However, that throws away the entire benefit of
Transparent State Migration.

Therefore, the client must not purge that lease when it is possible
that Transparent State Migration has occurred.

Reported-by: Xuan Qi <xuan.qi@oracle.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Xuan Qi <xuan.qi@oracle.com>
---
 fs/nfs/nfs4client.c       |    5 +++++
 fs/nfs/nfs4state.c        |   16 +++++++++++-----
 include/linux/nfs_fs_sb.h |    2 ++
 3 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 692a7a8..203d7a3 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -414,6 +414,7 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 	if (clp != old)
 		clp->cl_preserve_clid = true;
 	nfs_put_client(clp);
+	clear_bit(NFS_CS_TSM_POSSIBLE, &clp->cl_flags);
 	return old;
 
 error:
@@ -853,6 +854,8 @@ static int nfs4_set_client(struct nfs_server *server,
 		set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
 	if (server->options & NFS_OPTION_MIGRATION)
 		set_bit(NFS_CS_MIGRATION, &cl_init.init_flags);
+	if (test_bit(NFS_MIG_TSM_POSSIBLE, &server->mig_status))
+		set_bit(NFS_CS_TSM_POSSIBLE, &cl_init.init_flags);
 
 	/* Allocate or find a client reference we can use */
 	clp = nfs_get_client(&cl_init);
@@ -1213,9 +1216,11 @@ int nfs4_update_server(struct nfs_server *server, const char *hostname,
 		return -EAFNOSUPPORT;
 
 	nfs_server_remove_lists(server);
+	set_bit(NFS_MIG_TSM_POSSIBLE, &server->mig_status);
 	error = nfs4_set_client(server, hostname, sap, salen, buf,
 				clp->cl_proto, clnt->cl_timeout,
 				clp->cl_minorversion, net);
+	clear_bit(NFS_MIG_TSM_POSSIBLE, &server->mig_status);
 	nfs_put_client(clp);
 	if (error != 0) {
 		nfs_server_insert_lists(server);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index b34de03..83f8e60 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -352,11 +352,17 @@ int nfs41_discover_server_trunking(struct nfs_client *clp,
 	if (clp != *result)
 		return 0;
 
-	/* Purge state if the client id was established in a prior instance */
-	if (clp->cl_exchange_flags & EXCHGID4_FLAG_CONFIRMED_R)
-		set_bit(NFS4CLNT_PURGE_STATE, &clp->cl_state);
-	else
-		set_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
+	/*
+	 * Purge state if the client id was established in a prior
+	 * instance and the client id could not have arrived on the
+	 * server via Transparent State Migration.
+	 */
+	if (clp->cl_exchange_flags & EXCHGID4_FLAG_CONFIRMED_R) {
+		if (!test_bit(NFS_CS_TSM_POSSIBLE, &clp->cl_flags))
+			set_bit(NFS4CLNT_PURGE_STATE, &clp->cl_state);
+		else
+			set_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
+	}
 	nfs4_schedule_state_manager(clp);
 	status = nfs_wait_client_init_complete(clp);
 	if (status < 0)
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index e418a10..74c4466 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -42,6 +42,7 @@ struct nfs_client {
 #define NFS_CS_MIGRATION	2		/* - transparent state migr */
 #define NFS_CS_INFINITE_SLOTS	3		/* - don't limit TCP slots */
 #define NFS_CS_NO_RETRANS_TIMEOUT	4	/* - Disable retransmit timeouts */
+#define NFS_CS_TSM_POSSIBLE	5		/* - Maybe state migration */
 	struct sockaddr_storage	cl_addr;	/* server identifier */
 	size_t			cl_addrlen;
 	char *			cl_hostname;	/* hostname of server */
@@ -210,6 +211,7 @@ struct nfs_server {
 	unsigned long		mig_status;
 #define NFS_MIG_IN_TRANSITION		(1)
 #define NFS_MIG_FAILED			(2)
+#define NFS_MIG_TSM_POSSIBLE		(3)
 
 	void (*destroy)(struct nfs_server *);
 

