Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:33695 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755172Ab2DWUzh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 16:55:37 -0400
Received: by yenl12 with SMTP id l12so6485905yen.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2012 13:55:37 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/20] NFS: Use the same nfs_client_id4 for every server
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 23 Apr 2012 16:55:34 -0400
Message-ID: <20120423205534.11446.48187.stgit@degas.1015granger.net>
In-Reply-To: <20120423205312.11446.67081.stgit@degas.1015granger.net>
References: <20120423205312.11446.67081.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, when identifying itself to NFS servers, the Linux NFS
client uses a unique nfs_client_id4 string for each server IP address
it talks with.  For example, when client A talks to server X, the
client identifies itself using a string like "AX".

These strings are opaque to servers.  Each client is free to choose
any content, as long as it is unique from other client instances.  A
server must not parse the contents of the string, it can only test
these strings for equality.  These requirements are specified in
detail by RFC 3530 (and bis).

This form of client identification presents a problem for Transparent
State Migration.  When client A's state on server X is migrated to
server Y, it continues to be associated with string "AX."  But client
A will present string "AY" when communicating with server Y.

Server Y thus has no way to know that client A should be associated
with the state migrated from server X.  "AX" is all but abandoned,
interferring with establishing fresh state for A on server Y.

To support Transparent State Migration, then, NFSv4.0 clients must
instead use the same nfs_client_id4 string to identify themselves to
every NFS server; something like "A".

As part of a migration event, when state associated with string "A"
shows up at server Y, client A identifies itself as "A" and server Y
will know immediately that the state associated with "A," whether it
is native or migrated, is owned by client A.

As a pre-requisite to adding support for NFSv4 migration to the Linux
NFS client, this patch changes the way Linux identifies itself to NFS
servers via the SETCLIENTID (NFSv4 minor version 0) and EXCHANGE_ID
(NFSv4 minor version 1) operations.

In addition to removing the server's IP address from nfs_client_id4,
the Linux NFS client will also no longer use its own source IP address
as part of the nfs_client_id4 string.  On multi-homed clients, the
value of this address depends on the address family and network
routing used to contact the server, thus it can be different for each
server.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c |   50 ++++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 40 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7ec1b68..9fe19d4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3908,6 +3908,34 @@ nfs4_init_nonuniform_client_string(const struct nfs_client *clp,
 	return result;
 }
 
+/*
+ * XXX:
+ *
+ * Our client ID string should not use init_utsname->nodename, but
+ * rather should contain the nodename for the appropriate net
+ * namespace for this nfs_client.
+ *
+ * There's a pointer to the correct net namespace in the rpc_clnt's
+ * xprt, but I have no idea how then to get the net namespace's nodename.
+ *
+ * However, rpc_create() should be using that namespace to construct
+ * ->cl_nodename, which is exactly the string we need...  but it is
+ * currently still using init_utsname().
+ *
+ * For now I'm going to stick with init_utsname.  We can easily work
+ * this out later when the client has container support.
+ */
+static unsigned int
+nfs4_init_uniform_client_string(const struct nfs_client *clp,
+				char *buf, size_t len)
+{
+	return scnprintf(buf, len, "Linux NFSv%u.%u %s %s %s uniform",
+				clp->rpc_ops->version, clp->cl_minorversion,
+				init_utsname()->nodename,
+				init_utsname()->domainname,
+				clp->cl_rpcclient->cl_auth->au_ops->au_name);
+}
+
 /**
  * nfs4_proc_setclientid - Negotiate client ID
  * @clp: state data structure
@@ -3941,7 +3969,14 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 
 	/* Client ID */
 	nfs4_init_boot_verifier(clp, &sc_verifier);
-	setclientid.sc_name_len = nfs4_init_nonuniform_client_string(clp,
+	if (test_bit(NFS_CS_MIGRATION, &clp->cl_flags))
+		setclientid.sc_name_len =
+				nfs4_init_uniform_client_string(clp,
+						setclientid.sc_name,
+						sizeof(setclientid.sc_name));
+	else
+		setclientid.sc_name_len =
+				nfs4_init_nonuniform_client_string(clp,
 						setclientid.sc_name,
 						sizeof(setclientid.sc_name));
 
@@ -5061,14 +5096,8 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	BUG_ON(clp == NULL);
 
 	nfs4_init_boot_verifier(clp, &verifier);
-
-	args.id_len = scnprintf(args.id, sizeof(args.id),
-				"%s/%s.%s/%u",
-				clp->cl_ipaddr,
-				init_utsname()->nodename,
-				init_utsname()->domainname,
-				clp->cl_rpcclient->cl_auth->au_flavor);
-
+	args.id_len = nfs4_init_uniform_client_string(clp, args.id,
+							sizeof(args.id));
 	res.server_scope = kzalloc(sizeof(struct nfs41_server_scope),
 					GFP_KERNEL);
 	if (unlikely(res.server_scope == NULL)) {
@@ -5119,7 +5148,8 @@ out:
 			__func__, clp->cl_implid->domain, clp->cl_implid->name,
 			clp->cl_implid->date.seconds,
 			clp->cl_implid->date.nseconds);
-	dprintk("<-- %s status= %d\n", __func__, status);
+	dprintk("<-- %s nfs_client_id4 '%.*s' (status %d)\n",
+		__func__, args.id_len, args.id, status);
 	return status;
 }
 

