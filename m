Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:36030 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932618AbbFFX1N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Jun 2015 19:27:13 -0400
Received: by igbpi8 with SMTP id pi8so38900113igb.1
        for <linux-nfs@vger.kernel.org>; Sat, 06 Jun 2015 16:27:13 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org,
        Michael Skralivetsky <michael.skralivetsky@primarydata.com>,
        chuck.lever@oracle.com
Subject: [PATCH v2 4/4] nfs: make nfs4_init_uniform_client_string use a dynamically allocated buffer
Date: Sat,  6 Jun 2015 19:26:50 -0400
Message-Id: <1433633210-26110-5-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1433633210-26110-1-git-send-email-jeff.layton@primarydata.com>
References: <1433633210-26110-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change the uniform client string generator to dynamically allocate the
NFSv4 client name string buffer. With this patch, we can eliminate the
buffers that are embedded within the "args" structs and simply use the
name string that is hanging off the client.

This uniform string case is a little simpler than the nonuniform since
we don't need to deal with RCU, but we do have two different cases,
depending on whether there is a uniquifier or not.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/nfs4proc.c       | 102 +++++++++++++++++++++++++++++++-----------------
 include/linux/nfs_xdr.h |   6 ---
 2 files changed, 67 insertions(+), 41 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 49e3b3e55887..afb90bb27038 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5000,28 +5000,68 @@ retry:
 	return 0;
 }
 
-static unsigned int
-nfs4_init_uniform_client_string(struct nfs_client *clp,
-				char *buf, size_t len)
+static int
+nfs4_init_uniquifier_client_string(struct nfs_client *clp)
+{
+	int result;
+	size_t len;
+	char *str;
+
+	len = 10 + 10 + 1 + 10 + 1 +
+		strlen(nfs4_client_id_uniquifier) + 1 +
+		strlen(clp->cl_rpcclient->cl_nodename) + 1;
+
+	if (len > NFS4_OPAQUE_LIMIT + 1)
+		return -EINVAL;
+
+	str = kmalloc(len, GFP_NOFS);
+	if (!str)
+		return -ENOMEM;
+
+	result = scnprintf(str, len, "Linux NFSv%u.%u %s/%s",
+			clp->rpc_ops->version, clp->cl_minorversion,
+			nfs4_client_id_uniquifier,
+			clp->cl_rpcclient->cl_nodename);
+	if (result >= len) {
+		kfree(str);
+		return -EINVAL;
+	}
+	clp->cl_owner_id = str;
+	return 0;
+}
+
+static int
+nfs4_init_uniform_client_string(struct nfs_client *clp)
 {
-	const char *nodename = clp->cl_rpcclient->cl_nodename;
-	unsigned int result;
+	int result;
+	size_t len;
+	char *str;
 
 	if (clp->cl_owner_id != NULL)
-		return strlcpy(buf, clp->cl_owner_id, len);
+		return 0;
 
 	if (nfs4_client_id_uniquifier[0] != '\0')
-		result = scnprintf(buf, len, "Linux NFSv%u.%u %s/%s",
-				clp->rpc_ops->version,
-				clp->cl_minorversion,
-				nfs4_client_id_uniquifier,
-				nodename);
-	else
-		result = scnprintf(buf, len, "Linux NFSv%u.%u %s",
-				clp->rpc_ops->version, clp->cl_minorversion,
-				nodename);
-	clp->cl_owner_id = kstrdup(buf, GFP_NOFS);
-	return result;
+		return nfs4_init_uniquifier_client_string(clp);
+
+	len = 10 + 10 + 1 + 10 + 1 +
+		strlen(clp->cl_rpcclient->cl_nodename) + 1;
+
+	if (len > NFS4_OPAQUE_LIMIT + 1)
+		return -EINVAL;
+
+	str = kmalloc(len, GFP_NOFS);
+	if (!str)
+		return -ENOMEM;
+
+	result = scnprintf(str, len, "Linux NFSv%u.%u %s",
+			clp->rpc_ops->version, clp->cl_minorversion,
+			clp->cl_rpcclient->cl_nodename);
+	if (result >= len) {
+		kfree(str);
+		return -EINVAL;
+	}
+	clp->cl_owner_id = str;
+	return 0;
 }
 
 /*
@@ -5088,20 +5128,14 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 
 	/* nfs_client_id4 */
 	nfs4_init_boot_verifier(clp, &sc_verifier);
-	if (test_bit(NFS_CS_MIGRATION, &clp->cl_flags)) {
-		setclientid.sc_name_len =
-				nfs4_init_uniform_client_string(clp,
-						setclientid.sc_name,
-						sizeof(setclientid.sc_name));
-		if (!clp->cl_owner_id) {
-			status = -ENOMEM;
-			goto out;
-		}
-	} else {
+
+	if (test_bit(NFS_CS_MIGRATION, &clp->cl_flags))
+		status = nfs4_init_uniform_client_string(clp);
+	else
 		status = nfs4_init_nonuniform_client_string(clp);
-		if (status)
-			goto out;
-	}
+
+	if (status)
+		goto out;
 
 	/* cb_client4 */
 	setclientid.sc_netid_len =
@@ -6875,12 +6909,10 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 	};
 
 	nfs4_init_boot_verifier(clp, &verifier);
-	args.id_len = nfs4_init_uniform_client_string(clp, args.id,
-							sizeof(args.id));
-	if (!clp->cl_owner_id) {
-		status = -ENOMEM;
+
+	status = nfs4_init_uniform_client_string(clp);
+	if (status)
 		goto out;
-	}
 
 	dprintk("NFS call  exchange_id auth=%s, '%s'\n",
 		clp->cl_rpcclient->cl_auth->au_ops->au_name,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 16991f5e274e..c959e7eb5bd4 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -984,11 +984,8 @@ struct nfs4_readlink_res {
 	struct nfs4_sequence_res	seq_res;
 };
 
-#define NFS4_SETCLIENTID_NAMELEN	(127)
 struct nfs4_setclientid {
 	const nfs4_verifier *		sc_verifier;
-	unsigned int			sc_name_len;
-	char				sc_name[NFS4_SETCLIENTID_NAMELEN + 1];
 	u32				sc_prog;
 	unsigned int			sc_netid_len;
 	char				sc_netid[RPCBIND_MAXNETIDLEN + 1];
@@ -1142,12 +1139,9 @@ struct nfs41_state_protection {
 	struct nfs4_op_map allow;
 };
 
-#define NFS4_EXCHANGE_ID_LEN	(48)
 struct nfs41_exchange_id_args {
 	struct nfs_client		*client;
 	nfs4_verifier			*verifier;
-	unsigned int 			id_len;
-	char 				id[NFS4_EXCHANGE_ID_LEN];
 	u32				flags;
 	struct nfs41_state_protection	state_protect;
 };
-- 
2.4.2

