Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:43242 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753984Ab2DWUyk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 16:54:40 -0400
Received: by mail-iy0-f174.google.com with SMTP id i9so2498807iad.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2012 13:54:40 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/20] NFS: Always use the same SETCLIENTID boot verifier
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 23 Apr 2012 16:54:37 -0400
Message-ID: <20120423205437.11446.40304.stgit@degas.1015granger.net>
In-Reply-To: <20120423205312.11446.67081.stgit@degas.1015granger.net>
References: <20120423205312.11446.67081.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently our NFS client assigns a unique SETCLIENTID boot verifier
for each server IP address.  It's set to CURRENT_TIME when a struct
nfs_client for that server is created.

During the SETCLIENTID operation, our client also presents an
nfs_client_id4 string to servers as an identifier on which the server
can hang all of this client's NFSv4 state.  Our client's
nfs_client_id4 string is also unique for each server IP address.

An NFSv4 server is obligated to wipe all NFSv4 state associated with
an nfs_client_id4 string when the client presents this string with a
changed SETCLIENTID boot verifier.

When our client unmounts the last of a server's shares, it destroys
that server's struct nfs_client.  The next time the client mounts that
NFS server, it creates a fresh struct nfs_client with a fresh boot
verifier.  On seeing the fresh verifer, the server wipes any previous
NFSv4 state associated with that nfs_client_id4.

However, NFSv4.1 clients are supposed to present the same
nfs_client_id4 string to all servers.  And, to support Transparent
State Migration, the same nfs_client_id4 string should be presented
to all servers so they recognize that migrated state for this client
belongs with state a server may already have for this client.

If the nfs_client_id4 string is the same but the boot verifier changes
for each server IP address, SETCLIENTIDs from such a client could
result in the server wiping the client's previously obtained lease.

Thus, if our NFS client is going to use a fixed nfs_client_id4 string,
our NFS client should also use a SETCLIENTID boot verifier that does
not change depending on which NFS server is being contacted.

Replace our current per-nfs_client boot verifier with a per-nfs_net
boot verifier.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c           |    2 +-
 fs/nfs/netns.h            |    5 +++++
 fs/nfs/nfs4proc.c         |   14 ++++++++------
 fs/nfs/nfs4xdr.c          |    5 ++++-
 include/linux/nfs_fs_sb.h |    3 ---
 5 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index c0232aa..3ba6c62 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -182,7 +182,6 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	spin_lock_init(&clp->cl_lock);
 	INIT_DELAYED_WORK(&clp->cl_renewd, nfs4_renew_state);
 	rpc_init_wait_queue(&clp->cl_rpcwaitq, "NFS client");
-	clp->cl_boot_time = CURRENT_TIME;
 	clp->cl_state = 1 << NFS4CLNT_LEASE_EXPIRED;
 	clp->cl_minorversion = cl_init->minorversion;
 	clp->cl_mvops = nfs_v4_minor_ops[cl_init->minorversion];
@@ -1804,6 +1803,7 @@ void nfs_clients_init(struct net *net)
 	idr_init(&nn->cb_ident_idr);
 #endif
 	spin_lock_init(&nn->nfs_client_lock);
+	nn->boot_time = CURRENT_TIME;
 }
 
 #ifdef CONFIG_PROC_FS
diff --git a/fs/nfs/netns.h b/fs/nfs/netns.h
index aa14ec3..8a6394e 100644
--- a/fs/nfs/netns.h
+++ b/fs/nfs/netns.h
@@ -1,3 +1,7 @@
+/*
+ * NFS-private data for each "struct net".  Accessed with net_generic().
+ */
+
 #ifndef __NFS_NETNS_H__
 #define __NFS_NETNS_H__
 
@@ -20,6 +24,7 @@ struct nfs_net {
 	struct idr cb_ident_idr; /* Protected by nfs_client_lock */
 #endif
 	spinlock_t nfs_client_lock;
+	struct timespec boot_time;
 };
 
 extern int nfs_net_id;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b19cf81..8bdc6fd 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -64,6 +64,7 @@
 #include "iostat.h"
 #include "callback.h"
 #include "pnfs.h"
+#include "netns.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
@@ -3873,8 +3874,8 @@ wait_on_recovery:
 	return -EAGAIN;
 }
 
-static void nfs4_construct_boot_verifier(struct nfs_client *clp,
-					 nfs4_verifier *bootverf)
+static void nfs4_init_boot_verifier(const struct nfs_client *clp,
+				    nfs4_verifier *bootverf)
 {
 	__be32 verf[2];
 
@@ -3882,8 +3883,9 @@ static void nfs4_construct_boot_verifier(struct nfs_client *clp,
 		verf[0] = (__be32)CURRENT_TIME.tv_sec;
 		verf[1] = (__be32)CURRENT_TIME.tv_nsec;
 	} else {
-		verf[0] = (__be32)clp->cl_boot_time.tv_sec;
-		verf[1] = (__be32)clp->cl_boot_time.tv_nsec;
+		struct nfs_net *nn = net_generic(clp->cl_net, nfs_net_id);
+		verf[0] = (__be32)nn->boot_time.tv_sec;
+		verf[1] = (__be32)nn->boot_time.tv_nsec;
 	}
 	memcpy(bootverf->data, verf, sizeof(bootverf->data));
 }
@@ -3907,7 +3909,7 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 	int loop = 0;
 	int status;
 
-	nfs4_construct_boot_verifier(clp, &sc_verifier);
+	nfs4_init_boot_verifier(clp, &sc_verifier);
 
 	for(;;) {
 		rcu_read_lock();
@@ -5033,7 +5035,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	dprintk("--> %s\n", __func__);
 	BUG_ON(clp == NULL);
 
-	nfs4_construct_boot_verifier(clp, &verifier);
+	nfs4_init_boot_verifier(clp, &verifier);
 
 	args.id_len = scnprintf(args.id, sizeof(args.id),
 				"%s/%s.%s/%u",
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 9fce30f..312f619 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -53,9 +53,11 @@
 #include <linux/nfs4.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_idmap.h>
+
 #include "nfs4_fs.h"
 #include "internal.h"
 #include "pnfs.h"
+#include "netns.h"
 
 #define NFSDBG_FACILITY		NFSDBG_XDR
 
@@ -1724,6 +1726,7 @@ static void encode_create_session(struct xdr_stream *xdr,
 	char machine_name[NFS4_MAX_MACHINE_NAME_LEN];
 	uint32_t len;
 	struct nfs_client *clp = args->client;
+	struct nfs_net *nn = net_generic(clp->cl_net, nfs_net_id);
 	u32 max_resp_sz_cached;
 
 	/*
@@ -1765,7 +1768,7 @@ static void encode_create_session(struct xdr_stream *xdr,
 	*p++ = cpu_to_be32(RPC_AUTH_UNIX);			/* auth_sys */
 
 	/* authsys_parms rfc1831 */
-	*p++ = cpu_to_be32((u32)clp->cl_boot_time.tv_nsec);	/* stamp */
+	*p++ = (__be32)nn->boot_time.tv_nsec;		/* stamp */
 	p = xdr_encode_opaque(p, machine_name, len);
 	*p++ = cpu_to_be32(0);				/* UID */
 	*p++ = cpu_to_be32(0);				/* GID */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 3c38291..b246582 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -61,9 +61,6 @@ struct nfs_client {
 
 	struct rpc_wait_queue	cl_rpcwaitq;
 
-	/* used for the setclientid verifier */
-	struct timespec		cl_boot_time;
-
 	/* idmapper */
 	struct idmap *		cl_idmap;
 

