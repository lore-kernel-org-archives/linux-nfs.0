Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f174.google.com ([209.85.210.174]:35852 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753769Ab2KPX2z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Nov 2012 18:28:55 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so2063184iay.19
        for <linux-nfs@vger.kernel.org>; Fri, 16 Nov 2012 15:28:55 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] SUNRPC: Allow rpc_clone_client() to share rpc_auth objects
To: linux-nfs@vger.kernel.org
Date: Fri, 16 Nov 2012 18:28:51 -0500
Message-ID: <20121116232846.4931.88675.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields reports:
> On 3.7-rc1:
>
> 	client# mount -tnfs -osec=krb5,vers=3 server:/exports/ext4 /mnt/
>
> 		server# ls -l /exports/ext4|grep TMP
> 		server#
>
> 	# mkdir /mnt/TMP
> 	mkdir: cannot create directory `/mnt/TMP': Permission denied
>
> 		server# ls -l /exports/ext4|grep TMP
> 		drwxr-xr-x  2 nfsnobody nfsnobody 4096 Oct 16 08:56 TMP
> 		server#
>
> Wireshark also shows that the create succeeds.

The NFS3 MKDIR operation succeeds but the mkdir(2) system call fails
because the NFS client attempts to retrieve the ACL on the new
directory, but encounters a problem that appears to have been
introduced by commit 1b63a751 "SUNRPC: Refactor rpc_clone_client()",
Sep 14 17:23:52 2012.

NFSv3 ACL requests are part of a side-band protocol called NFSACL.
Unlike the MNT or NLM side-band protocols, an NFS client sends
NFSACL protocol requests on the same transport as it sends NFS
protocol requests.

The Linux NFS client clones the rpc_clnt for the NFS protocol to
make an rpc_clnt for NFSACL protocol requests, but they share the
underlying transport (rpc_xprt).  Normally the original rpc_clnt's
rpc_auth object should also be shared by both rpc_clnt's.  See
rpc_bind_new_program() and rpc_clone_client().

Thanks to 1b63a751, however, rpc_clone_client() create a _new_
rpc_auth object for the NFSACL rpc_clnt.  With AUTH_GSS, this means
a fresh GSS context must be created for the new rpc_auth object.
rpc.gssd tries to create the context with the service name
"nfsacl@servername".  The NFS server does not recognize that service
name.

The solution is to restore the original pre-1b63a751 behavior of
rpc_clone_client().  This behavior is to share an rpc_auth
object between the original rpc_clnt and the cloned rpc_clnt.  A
fresh GSS context for the NFSACL rpc_clnt is then no longer
required.  It simply uses the one that is already established for
the NFS rpc_clnt.

Reported-by: J. Bruce Fields <bfields@fieldses.org>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/clnt.h |    1 +
 net/sunrpc/clnt.c           |   21 +++++++++++++++------
 2 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 34206b8..2931952 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -112,6 +112,7 @@ struct rpc_create_args {
 	u32			prognumber;	/* overrides program->number */
 	u32			version;
 	rpc_authflavor_t	authflavor;
+	struct rpc_auth		*auth;
 	unsigned long		flags;
 	char			*client_name;
 	struct svc_xprt		*bc_xprt;	/* NFSv4.1 backchannel */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index cdc7564..c75630a 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -356,12 +356,17 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 	if (err < 0)
 		goto out_no_path;
 
-	auth = rpcauth_create(args->authflavor, clnt);
-	if (IS_ERR(auth)) {
-		printk(KERN_INFO "RPC: Couldn't create auth handle (flavor %u)\n",
-				args->authflavor);
-		err = PTR_ERR(auth);
-		goto out_no_auth;
+	if (args->auth == NULL) {
+		auth = rpcauth_create(args->authflavor, clnt);
+		if (IS_ERR(auth)) {
+			printk(KERN_INFO "RPC: Couldn't create auth handle (flavor %u)\n",
+					args->authflavor);
+			err = PTR_ERR(auth);
+			goto out_no_auth;
+		}
+	} else {
+		atomic_inc(&args->auth->au_count);
+		clnt->cl_auth = args->auth;
 	}
 
 	/* save the nodename */
@@ -542,6 +547,7 @@ struct rpc_clnt *rpc_clone_client(struct rpc_clnt *clnt)
 		.prognumber	= clnt->cl_prog,
 		.version	= clnt->cl_vers,
 		.authflavor	= clnt->cl_auth->au_flavor,
+		.auth		= clnt->cl_auth,
 		.client_name	= clnt->cl_principal,
 	};
 	return __rpc_clone_client(&args, clnt);
@@ -566,6 +572,9 @@ rpc_clone_client_set_auth(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
 		.authflavor	= flavor,
 		.client_name	= clnt->cl_principal,
 	};
+
+	if (flavor == clnt->cl_auth->au_flavor)
+		args.auth = clnt->cl_auth;
 	return __rpc_clone_client(&args, clnt);
 }
 EXPORT_SYMBOL_GPL(rpc_clone_client_set_auth);

