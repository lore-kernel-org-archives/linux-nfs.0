Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:11195 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752123Ab1DTXuV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Apr 2011 19:50:21 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] NFSv4.1: Don't loop forever in nfs4_proc_create_session
Date: Wed, 20 Apr 2011 16:50:03 -0700
Message-Id: <1303343405-5021-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

If a server for some reason keeps sending NFS4ERR_DELAY errors, we can end
up looping forever inside nfs4_proc_create_session, and so the usual
mechanisms for detecting if the nfs_client is dead don't work.

Fix this by ensuring that we loop inside the nfs4_state_manager thread
instead.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h          |    1 +
 fs/nfs/nfs4proc.c         |   84 ++++++++++++---------------------------------
 fs/nfs/nfs4state.c        |   47 +++++++++++++++++--------
 include/linux/nfs_fs_sb.h |    1 +
 4 files changed, 56 insertions(+), 77 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index e1c261d..c4a6983 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -47,6 +47,7 @@ enum nfs4_client_state {
 	NFS4CLNT_LAYOUTRECALL,
 	NFS4CLNT_SESSION_RESET,
 	NFS4CLNT_RECALL_SLOT,
+	NFS4CLNT_LEASE_CONFIRM,
 };
 
 enum nfs4_session_state {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 628e35f..2507f1f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3726,46 +3726,36 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 		.rpc_cred = cred,
 	};
 	__be32 *p;
-	int loop = 0;
 	int status;
 
 	p = (__be32*)sc_verifier.data;
 	*p++ = htonl((u32)clp->cl_boot_time.tv_sec);
 	*p = htonl((u32)clp->cl_boot_time.tv_nsec);
 
-	for(;;) {
-		setclientid.sc_name_len = scnprintf(setclientid.sc_name,
-				sizeof(setclientid.sc_name), "%s/%s %s %s %u",
-				clp->cl_ipaddr,
-				rpc_peeraddr2str(clp->cl_rpcclient,
-							RPC_DISPLAY_ADDR),
-				rpc_peeraddr2str(clp->cl_rpcclient,
-							RPC_DISPLAY_PROTO),
-				clp->cl_rpcclient->cl_auth->au_ops->au_name,
-				clp->cl_id_uniquifier);
-		setclientid.sc_netid_len = scnprintf(setclientid.sc_netid,
-				sizeof(setclientid.sc_netid),
-				rpc_peeraddr2str(clp->cl_rpcclient,
-							RPC_DISPLAY_NETID));
-		setclientid.sc_uaddr_len = scnprintf(setclientid.sc_uaddr,
-				sizeof(setclientid.sc_uaddr), "%s.%u.%u",
-				clp->cl_ipaddr, port >> 8, port & 255);
-
-		status = rpc_call_sync(clp->cl_rpcclient, &msg, 0);
-		if (status != -NFS4ERR_CLID_INUSE)
-			break;
-		if (signalled())
-			break;
-		if (loop++ & 1)
-			ssleep(clp->cl_lease_time / HZ + 1);
-		else
-			if (++clp->cl_id_uniquifier == 0)
-				break;
-	}
+	setclientid.sc_name_len = scnprintf(setclientid.sc_name,
+			sizeof(setclientid.sc_name), "%s/%s %s %s %u",
+			clp->cl_ipaddr,
+			rpc_peeraddr2str(clp->cl_rpcclient,
+						RPC_DISPLAY_ADDR),
+			rpc_peeraddr2str(clp->cl_rpcclient,
+						RPC_DISPLAY_PROTO),
+			clp->cl_rpcclient->cl_auth->au_ops->au_name,
+			clp->cl_id_uniquifier);
+	setclientid.sc_netid_len = scnprintf(setclientid.sc_netid,
+			sizeof(setclientid.sc_netid),
+			rpc_peeraddr2str(clp->cl_rpcclient,
+						RPC_DISPLAY_NETID));
+	setclientid.sc_uaddr_len = scnprintf(setclientid.sc_uaddr,
+			sizeof(setclientid.sc_uaddr), "%s.%u.%u",
+			clp->cl_ipaddr, port >> 8, port & 255);
+
+	status = rpc_call_sync(clp->cl_rpcclient, &msg, 0);
+	if (status == -NFS4ERR_CLID_INUSE)
+		ssleep(clp->cl_lease_time / HZ + 1);
 	return status;
 }
 
-static int _nfs4_proc_setclientid_confirm(struct nfs_client *clp,
+int nfs4_proc_setclientid_confirm(struct nfs_client *clp,
 		struct nfs4_setclientid_res *arg,
 		struct rpc_cred *cred)
 {
@@ -3790,26 +3780,6 @@ static int _nfs4_proc_setclientid_confirm(struct nfs_client *clp,
 	return status;
 }
 
-int nfs4_proc_setclientid_confirm(struct nfs_client *clp,
-		struct nfs4_setclientid_res *arg,
-		struct rpc_cred *cred)
-{
-	long timeout = 0;
-	int err;
-	do {
-		err = _nfs4_proc_setclientid_confirm(clp, arg, cred);
-		switch (err) {
-			case 0:
-				return err;
-			case -NFS4ERR_RESOURCE:
-				/* The IBM lawyers misread another document! */
-			case -NFS4ERR_DELAY:
-				err = nfs4_delay(clp->cl_rpcclient, &timeout);
-		}
-	} while (err == 0);
-	return err;
-}
-
 struct nfs4_delegreturndata {
 	struct nfs4_delegreturnargs args;
 	struct nfs4_delegreturnres res;
@@ -5222,20 +5192,10 @@ int nfs4_proc_create_session(struct nfs_client *clp)
 	int status;
 	unsigned *ptr;
 	struct nfs4_session *session = clp->cl_session;
-	long timeout = 0;
-	int err;
 
 	dprintk("--> %s clp=%p session=%p\n", __func__, clp, session);
 
-	do {
-		status = _nfs4_proc_create_session(clp);
-		if (status == -NFS4ERR_DELAY) {
-			err = nfs4_delay(clp->cl_rpcclient, &timeout);
-			if (err)
-				status = err;
-		}
-	} while (status == -NFS4ERR_DELAY);
-
+	status = _nfs4_proc_create_session(clp);
 	if (status)
 		goto out;
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 4dfb34b..9a7f9df 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -64,10 +64,15 @@ static LIST_HEAD(nfs4_clientid_list);
 
 int nfs4_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
 {
-	struct nfs4_setclientid_res clid;
+	struct nfs4_setclientid_res clid = {
+		.clientid = clp->cl_clientid,
+		.confirm = clp->cl_confirm,
+	};
 	unsigned short port;
 	int status;
 
+	if (test_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state))
+		goto do_confirm;
 	port = nfs_callback_tcpport;
 	if (clp->cl_addr.ss_family == AF_INET6)
 		port = nfs_callback_tcpport6;
@@ -75,10 +80,14 @@ int nfs4_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
 	status = nfs4_proc_setclientid(clp, NFS4_CALLBACK, port, cred, &clid);
 	if (status != 0)
 		goto out;
+	clp->cl_clientid = clid.clientid;
+	clp->cl_confirm = clid.confirm;
+	set_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
+do_confirm:
 	status = nfs4_proc_setclientid_confirm(clp, &clid, cred);
 	if (status != 0)
 		goto out;
-	clp->cl_clientid = clid.clientid;
+	clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
 	nfs4_schedule_state_renewal(clp);
 out:
 	return status;
@@ -230,13 +239,18 @@ int nfs41_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
 {
 	int status;
 
+	if (test_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state))
+		goto do_confirm;
 	nfs4_begin_drain_session(clp);
 	status = nfs4_proc_exchange_id(clp, cred);
 	if (status != 0)
 		goto out;
+	set_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
+do_confirm:
 	status = nfs4_proc_create_session(clp);
 	if (status != 0)
 		goto out;
+	clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
 	nfs41_setup_state_renewal(clp);
 	nfs_mark_client_ready(clp, NFS_CS_READY);
 out:
@@ -1584,20 +1598,23 @@ static int nfs4_recall_slot(struct nfs_client *clp) { return 0; }
  */
 static void nfs4_set_lease_expired(struct nfs_client *clp, int status)
 {
-	if (nfs4_has_session(clp)) {
-		switch (status) {
-		case -NFS4ERR_DELAY:
-		case -NFS4ERR_CLID_INUSE:
-		case -EAGAIN:
-			break;
+	switch (status) {
+	case -NFS4ERR_CLID_INUSE:
+		clp->cl_id_uniquifier++;
+	case -NFS4ERR_STALE_CLIENTID:
+		clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
+		break;
+	case -NFS4ERR_DELAY:
+	case -EAGAIN:
+		ssleep(1);
+		break;
 
-		case -EKEYEXPIRED:
-			nfs4_warn_keyexpired(clp->cl_hostname);
-		case -NFS4ERR_NOT_SAME: /* FixMe: implement recovery
-					 * in nfs4_exchange_id */
-		default:
-			return;
-		}
+	case -EKEYEXPIRED:
+		nfs4_warn_keyexpired(clp->cl_hostname);
+	case -NFS4ERR_NOT_SAME: /* FixMe: implement recovery
+				 * in nfs4_exchange_id */
+	default:
+		return;
 	}
 	set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
 }
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 216cea5..87694ca 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -47,6 +47,7 @@ struct nfs_client {
 
 #ifdef CONFIG_NFS_V4
 	u64			cl_clientid;	/* constant */
+	nfs4_verifier		cl_confirm;	/* Clientid verifier */
 	unsigned long		cl_state;
 
 	spinlock_t		cl_lock;
-- 
1.7.4.4

