Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:32970 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751838AbbFDQol (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jun 2015 12:44:41 -0400
Received: by igbpi8 with SMTP id pi8so19788730igb.0
        for <linux-nfs@vger.kernel.org>; Thu, 04 Jun 2015 09:44:40 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org,
        Michael Skralivetsky <michael.skralivetsky@primarydata.com>
Subject: [PATCH 1/4] nfs: convert setclientid and exchange_id encoders to use clp->cl_owner_id
Date: Thu,  4 Jun 2015 12:44:26 -0400
Message-Id: <1433436269-12292-2-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1433436269-12292-1-git-send-email-jeff.layton@primarydata.com>
References: <1433436269-12292-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...instead of buffers that are part of their arg structs. We already
hold a reference to the client, so we might as well use the allocated
buffer. In the event that we can't allocate the clp->cl_owner_id, then
just return -ENOMEM.

Note too that we switch from a GFP_KERNEL allocation here to GFP_NOFS.
It's possible we could end up trying to do a SETCLIENTID or EXCHANGE_ID
in order to reclaim some memory, and the GFP_KERNEL allocations in the
existing code could cause recursion back into NFS reclaim.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/nfs4proc.c       | 25 ++++++++++++++++++-------
 fs/nfs/nfs4xdr.c        |  7 ++++---
 include/linux/nfs_xdr.h |  2 +-
 3 files changed, 23 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 55e1e3af23a3..24256bf389e5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4972,7 +4972,7 @@ nfs4_init_nonuniform_client_string(struct nfs_client *clp,
 				rpc_peeraddr2str(clp->cl_rpcclient,
 							RPC_DISPLAY_PROTO));
 	rcu_read_unlock();
-	clp->cl_owner_id = kstrdup(buf, GFP_KERNEL);
+	clp->cl_owner_id = kstrdup(buf, GFP_NOFS);
 	return result;
 }
 
@@ -4996,7 +4996,7 @@ nfs4_init_uniform_client_string(struct nfs_client *clp,
 		result = scnprintf(buf, len, "Linux NFSv%u.%u %s",
 				clp->rpc_ops->version, clp->cl_minorversion,
 				nodename);
-	clp->cl_owner_id = kstrdup(buf, GFP_KERNEL);
+	clp->cl_owner_id = kstrdup(buf, GFP_NOFS);
 	return result;
 }
 
@@ -5044,7 +5044,7 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 	struct nfs4_setclientid setclientid = {
 		.sc_verifier = &sc_verifier,
 		.sc_prog = program,
-		.sc_cb_ident = clp->cl_cb_ident,
+		.sc_clnt = clp,
 	};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SETCLIENTID],
@@ -5074,6 +5074,12 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 				nfs4_init_nonuniform_client_string(clp,
 						setclientid.sc_name,
 						sizeof(setclientid.sc_name));
+
+	if (!clp->cl_owner_id) {
+		status = -ENOMEM;
+		goto out;
+	}
+
 	/* cb_client4 */
 	setclientid.sc_netid_len =
 				nfs4_init_callback_netid(clp,
@@ -5083,9 +5089,9 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 				sizeof(setclientid.sc_uaddr), "%s.%u.%u",
 				clp->cl_ipaddr, port >> 8, port & 255);
 
-	dprintk("NFS call  setclientid auth=%s, '%.*s'\n",
+	dprintk("NFS call  setclientid auth=%s, '%s'\n",
 		clp->cl_rpcclient->cl_auth->au_ops->au_name,
-		setclientid.sc_name_len, setclientid.sc_name);
+		clp->cl_owner_id);
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task)) {
 		status = PTR_ERR(task);
@@ -6848,9 +6854,14 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 	nfs4_init_boot_verifier(clp, &verifier);
 	args.id_len = nfs4_init_uniform_client_string(clp, args.id,
 							sizeof(args.id));
-	dprintk("NFS call  exchange_id auth=%s, '%.*s'\n",
+	if (!clp->cl_owner_id) {
+		status = -ENOMEM;
+		goto out;
+	}
+
+	dprintk("NFS call  exchange_id auth=%s, '%s'\n",
 		clp->cl_rpcclient->cl_auth->au_ops->au_name,
-		args.id_len, args.id);
+		clp->cl_owner_id);
 
 	res.server_owner = kzalloc(sizeof(struct nfs41_server_owner),
 					GFP_NOFS);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 0aea97841d30..2826e117e3df 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1667,13 +1667,13 @@ static void encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclie
 	encode_op_hdr(xdr, OP_SETCLIENTID, decode_setclientid_maxsz, hdr);
 	encode_nfs4_verifier(xdr, setclientid->sc_verifier);
 
-	encode_string(xdr, setclientid->sc_name_len, setclientid->sc_name);
+	encode_string(xdr, strlen(setclientid->sc_clnt->cl_owner_id), setclientid->sc_clnt->cl_owner_id);
 	p = reserve_space(xdr, 4);
 	*p = cpu_to_be32(setclientid->sc_prog);
 	encode_string(xdr, setclientid->sc_netid_len, setclientid->sc_netid);
 	encode_string(xdr, setclientid->sc_uaddr_len, setclientid->sc_uaddr);
 	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(setclientid->sc_cb_ident);
+	*p = cpu_to_be32(setclientid->sc_clnt->cl_cb_ident);
 }
 
 static void encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs4_setclientid_res *arg, struct compound_hdr *hdr)
@@ -1747,7 +1747,8 @@ static void encode_exchange_id(struct xdr_stream *xdr,
 	encode_op_hdr(xdr, OP_EXCHANGE_ID, decode_exchange_id_maxsz, hdr);
 	encode_nfs4_verifier(xdr, args->verifier);
 
-	encode_string(xdr, args->id_len, args->id);
+	encode_string(xdr, strlen(args->client->cl_owner_id),
+			args->client->cl_owner_id);
 
 	encode_uint32(xdr, args->flags);
 	encode_uint32(xdr, args->state_protect.how);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 93ab6071bbe9..16991f5e274e 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -994,7 +994,7 @@ struct nfs4_setclientid {
 	char				sc_netid[RPCBIND_MAXNETIDLEN + 1];
 	unsigned int			sc_uaddr_len;
 	char				sc_uaddr[RPCBIND_MAXUADDRLEN + 1];
-	u32				sc_cb_ident;
+	struct nfs_client		*sc_clnt;
 	struct rpc_cred			*sc_cred;
 };
 
-- 
2.4.2

