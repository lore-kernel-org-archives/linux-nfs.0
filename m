Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:35295 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751851Ab2GIPpO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jul 2012 11:45:14 -0400
Received: by mail-yw0-f46.google.com with SMTP id m54so10996794yhm.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 Jul 2012 08:45:13 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/14] NFS: Use the same nfs_client_id4 for every server
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 09 Jul 2012 11:45:11 -0400
Message-ID: <20120709154510.1604.49158.stgit@degas.1015granger.net>
In-Reply-To: <20120709153355.1604.14102.stgit@degas.1015granger.net>
References: <20120709153355.1604.14102.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, when identifying itself to NFS servers, the Linux NFS
client uses a unique nfs_client_id4.id string for each server IP
address it talks with.  For example, when client A talks to server X,
the client identifies itself using a string like "AX".

These strings are opaque to servers.  Each client is free to choose
any content, as long as it is unique from other client instances.  A
server must not parse the contents of the string, it can only test
these strings for equality.  These requirements are specified in
detail by RFC 3530 (and bis).

This form of client identification presents a problem for Transparent
State Migration.  When client A's state on server X is migrated to
server Y, it continues to be associated with string "AX."  But,
according to the rules of client string construction above, client
A will present string "AY" when communicating with server Y.

Server Y thus has no way to know that client A should be associated
with the state migrated from server X.  "AX" is all but abandoned,
interferring with establishing fresh state for A on server Y.

To support transparent state migration, then, NFSv4.0 clients must
instead use the same nfs_client_id4.id string to identify themselves
to every NFS server; something like "A".

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

 fs/nfs/nfs4proc.c |   51 +++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 39 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1d3b28d..214e1e0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4030,6 +4030,32 @@ static void nfs4_init_boot_verifier(const struct nfs_client *clp,
 	memcpy(bootverf->data, verf, sizeof(bootverf->data));
 }
 
+static unsigned int
+nfs4_init_nonuniform_client_string(const struct nfs_client *clp,
+				   char *buf, size_t len)
+{
+	unsigned int result;
+
+	rcu_read_lock();
+	result = scnprintf(buf, len, "Linux NFSv4.0 %s/%s %s",
+				clp->cl_ipaddr,
+				rpc_peeraddr2str(clp->cl_rpcclient,
+							RPC_DISPLAY_ADDR),
+				rpc_peeraddr2str(clp->cl_rpcclient,
+							RPC_DISPLAY_PROTO));
+	rcu_read_unlock();
+	return result;
+}
+
+static unsigned int
+nfs4_init_uniform_client_string(const struct nfs_client *clp,
+				char *buf, size_t len)
+{
+	return scnprintf(buf, len, "Linux NFSv%u.%u %s",
+				clp->rpc_ops->version, clp->cl_minorversion,
+				clp->cl_rpcclient->cl_nodename);
+}
+
 /**
  * nfs4_proc_setclientid - Negotiate client ID
  * @clp: state data structure
@@ -4060,15 +4086,18 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 
 	/* nfs_client_id4 */
 	nfs4_init_boot_verifier(clp, &sc_verifier);
-	rcu_read_lock();
-	setclientid.sc_name_len = scnprintf(setclientid.sc_name,
-			sizeof(setclientid.sc_name), "%s/%s %s",
-			clp->cl_ipaddr,
-			rpc_peeraddr2str(clp->cl_rpcclient,
-						RPC_DISPLAY_ADDR),
-			rpc_peeraddr2str(clp->cl_rpcclient,
-						RPC_DISPLAY_PROTO));
+	if (test_bit(NFS_CS_MIGRATION, &clp->cl_flags))
+		setclientid.sc_name_len =
+				nfs4_init_uniform_client_string(clp,
+						setclientid.sc_name,
+						sizeof(setclientid.sc_name));
+	else
+		setclientid.sc_name_len =
+				nfs4_init_nonuniform_client_string(clp,
+						setclientid.sc_name,
+						sizeof(setclientid.sc_name));
 	/* cb_client4 */
+	rcu_read_lock();
 	setclientid.sc_netid_len = scnprintf(setclientid.sc_netid,
 				sizeof(setclientid.sc_netid),
 				rpc_peeraddr2str(clp->cl_rpcclient,
@@ -5294,10 +5323,8 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	};
 
 	nfs4_init_boot_verifier(clp, &verifier);
-	args.id_len = scnprintf(args.id, sizeof(args.id),
-				"%s/%s",
-				clp->cl_ipaddr,
-				clp->cl_rpcclient->cl_nodename);
+	args.id_len = nfs4_init_uniform_client_string(clp, args.id,
+							sizeof(args.id));
 	dprintk("NFS call  exchange_id auth=%s, '%.*s'\n",
 		clp->cl_rpcclient->cl_auth->au_ops->au_name,
 		args.id_len, args.id);

