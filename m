Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f193.google.com ([209.85.160.193]:33276 "EHLO
	mail-yk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751408AbbCURVF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 Mar 2015 13:21:05 -0400
Received: by ykbq200 with SMTP id q200so3410881ykb.0
        for <linux-nfs@vger.kernel.org>; Sat, 21 Mar 2015 10:21:04 -0700 (PDT)
From: Sanidhya Kashyap <sanidhya.gatech@gmail.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: taesoo@gatech.edu, changwoo@gatech.edu, sanidhya@gatech.edu,
        blee@gatech.edu, Sanidhya Kashyap <sanidhya.gatech@gmail.com>
Subject: [PATCH] nfs: kstrdup() memory handling
Date: Sat, 21 Mar 2015 13:07:28 -0400
Message-Id: <1426957648-13104-1-git-send-email-sanidhya.gatech@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patch tries to correctly handle the memory failure even
for kstrdup() during memory pressure. Therefore, putting extra check
for ENOMEM in places where the kstrdup() has not been validated. Further
more checks have been added which called the functions
nfs4_init_nonuniform_client_string(), nfs4_init_uniform_client_string()
and _nfs4_proc_exchange_id().

Signed-off-by: Sanidhya Kashyap <sanidhya.gatech@gmail.com>
---
 fs/nfs/nfs4client.c |  9 ++++++++-
 fs/nfs/nfs4proc.c   | 30 ++++++++++++++++++++++++------
 2 files changed, 32 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 86d6214..08bf1f1 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -1217,8 +1217,15 @@ int nfs4_update_server(struct nfs_server *server, const char *hostname,
 		goto out;
 	}
 
-	if (server->nfs_client->cl_hostname == NULL)
+	if (server->nfs_client->cl_hostname == NULL) {
 		server->nfs_client->cl_hostname = kstrdup(hostname, GFP_KERNEL);
+		if (!server->nfs_client->cl_hostname) {
+			error = -ENOMEM;
+			dprintk("<-- %s(): not enough memory %d\n",
+				__func__, error);
+			goto out;
+		}
+	}
 	nfs_server_insert_lists(server);
 
 	error = nfs_probe_destination(server);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 627f37c..2d8b408 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4974,6 +4974,9 @@ nfs4_init_nonuniform_client_string(struct nfs_client *clp,
 							RPC_DISPLAY_PROTO));
 	rcu_read_unlock();
 	clp->cl_owner_id = kstrdup(buf, GFP_KERNEL);
+	if (!clp->cl_owner_id)
+		return -ENOMEM;
+
 	return result;
 }
 
@@ -4998,6 +5001,9 @@ nfs4_init_uniform_client_string(struct nfs_client *clp,
 				clp->rpc_ops->version, clp->cl_minorversion,
 				nodename);
 	clp->cl_owner_id = kstrdup(buf, GFP_KERNEL);
+	if (!clp->cl_owner_id)
+		return -ENOMEM;
+
 	return result;
 }
 
@@ -5062,19 +5068,24 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 		.flags = RPC_TASK_TIMEOUT,
 	};
 	int status;
+	int ret;
 
 	/* nfs_client_id4 */
 	nfs4_init_boot_verifier(clp, &sc_verifier);
 	if (test_bit(NFS_CS_MIGRATION, &clp->cl_flags))
-		setclientid.sc_name_len =
-				nfs4_init_uniform_client_string(clp,
+		ret = nfs4_init_uniform_client_string(clp,
 						setclientid.sc_name,
 						sizeof(setclientid.sc_name));
 	else
-		setclientid.sc_name_len =
-				nfs4_init_nonuniform_client_string(clp,
+		ret = nfs4_init_nonuniform_client_string(clp,
 						setclientid.sc_name,
 						sizeof(setclientid.sc_name));
+	if (ret < 0) {
+		status = ret;
+		goto out;
+	}
+	setclientid.sc_name_len = ret;
+
 	/* cb_client4 */
 	setclientid.sc_netid_len =
 				nfs4_init_callback_netid(clp,
@@ -6837,6 +6848,7 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 		0
 	};
 	int status;
+	int ret;
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_EXCHANGE_ID],
 		.rpc_argp = &args,
@@ -6845,8 +6857,14 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 	};
 
 	nfs4_init_boot_verifier(clp, &verifier);
-	args.id_len = nfs4_init_uniform_client_string(clp, args.id,
-							sizeof(args.id));
+	ret = nfs4_init_uniform_client_string(clp, args.id,
+						sizeof(args.id));
+	if (ret < 0) {
+		status = ret;
+		goto out;
+	}
+	args.id_len = ret;
+
 	dprintk("NFS call  exchange_id auth=%s, '%.*s'\n",
 		clp->cl_rpcclient->cl_auth->au_ops->au_name,
 		args.id_len, args.id);
-- 
2.1.0

