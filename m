Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:45769 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757082Ab2EVCpo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 May 2012 22:45:44 -0400
Received: by gglu4 with SMTP id u4so4992913ggl.19
        for <linux-nfs@vger.kernel.org>; Mon, 21 May 2012 19:45:43 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/14] NFS: Always use the same SETCLIENTID boot verifier
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 21 May 2012 22:45:41 -0400
Message-ID: <20120522024541.1787.9904.stgit@degas.1015granger.net>
In-Reply-To: <20120522022702.1787.45940.stgit@degas.1015granger.net>
References: <20120522022702.1787.45940.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently our NFS client assigns a unique SETCLIENTID boot verifier
for each server IP address it knows about.  It's set to CURRENT_TIME
when the struct nfs_client for that server IP is created.

During the SETCLIENTID operation, our client also presents an
nfs_client_id4 string to servers, as an identifier on which the server
can hang all of this client's NFSv4 state.  Our client's
nfs_client_id4 string is unique for each server IP address.

An NFSv4 server is obligated to wipe all NFSv4 state associated with
an nfs_client_id4 string when the client presents the same
nfs_client_id4 string along with a changed SETCLIENTID boot verifier.

When our client unmounts the last of a server's shares, it destroys
that server's struct nfs_client.  The next time the client mounts that
NFS server, it creates a fresh struct nfs_client with a fresh boot
verifier.  On seeing the fresh verifer, the server wipes any previous
NFSv4 state associated with that nfs_client_id4.

However, NFSv4.1 clients are supposed to present the same
nfs_client_id4 string to all servers.  And, to support Transparent
State Migration, the same nfs_client_id4 string should be presented
to all NFSv4.0 servers so they recognize that migrated state for this
client belongs with state a server may already have for this client.
(This is known as the Uniform Client String model).

If the nfs_client_id4 string is the same but the boot verifier changes
for each server IP address, SETCLIENTID and EXCHANGE_ID operations
from such a client could unintentionally result in a server wiping a
client's previously obtained lease.

Thus, if our NFS client is going to use a fixed nfs_client_id4 string,
either for NFSv4.0 or NFSv4.1 mounts, our NFS client should use a
boot verifier that does not change depending on server IP address.
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
index 9b9df71..af9b7e4 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -184,7 +184,6 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	spin_lock_init(&clp->cl_lock);
 	INIT_DELAYED_WORK(&clp->cl_renewd, nfs4_renew_state);
 	rpc_init_wait_queue(&clp->cl_rpcwaitq, "NFS client");
-	clp->cl_boot_time = CURRENT_TIME;
 	clp->cl_state = 1 << NFS4CLNT_LEASE_EXPIRED;
 	clp->cl_minorversion = cl_init->minorversion;
 	clp->cl_mvops = nfs_v4_minor_ops[cl_init->minorversion];
@@ -1813,6 +1812,7 @@ void nfs_clients_init(struct net *net)
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
index 81ccdbb..9e9334a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -64,6 +64,7 @@
 #include "iostat.h"
 #include "callback.h"
 #include "pnfs.h"
+#include "netns.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
@@ -3903,8 +3904,8 @@ wait_on_recovery:
 	return -EAGAIN;
 }
 
-static void nfs4_construct_boot_verifier(struct nfs_client *clp,
-					 nfs4_verifier *bootverf)
+static void nfs4_init_boot_verifier(const struct nfs_client *clp,
+				    nfs4_verifier *bootverf)
 {
 	__be32 verf[2];
 
@@ -3914,8 +3915,9 @@ static void nfs4_construct_boot_verifier(struct nfs_client *clp,
 		verf[0] = 0;
 		verf[1] = (__be32)(NSEC_PER_SEC + 1);
 	} else {
-		verf[0] = (__be32)clp->cl_boot_time.tv_sec;
-		verf[1] = (__be32)clp->cl_boot_time.tv_nsec;
+		struct nfs_net *nn = net_generic(clp->cl_net, nfs_net_id);
+		verf[0] = (__be32)nn->boot_time.tv_sec;
+		verf[1] = (__be32)nn->boot_time.tv_nsec;
 	}
 	memcpy(bootverf->data, verf, sizeof(bootverf->data));
 }
@@ -3939,7 +3941,7 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 	int loop = 0;
 	int status;
 
-	nfs4_construct_boot_verifier(clp, &sc_verifier);
+	nfs4_init_boot_verifier(clp, &sc_verifier);
 
 	for(;;) {
 		rcu_read_lock();
@@ -5099,7 +5101,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	dprintk("--> %s\n", __func__);
 	BUG_ON(clp == NULL);
 
-	nfs4_construct_boot_verifier(clp, &verifier);
+	nfs4_init_boot_verifier(clp, &verifier);
 
 	args.id_len = scnprintf(args.id, sizeof(args.id),
 				"%s/%s/%u",
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index db040e9..12b9982 100644
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
 
@@ -1702,6 +1704,7 @@ static void encode_create_session(struct xdr_stream *xdr,
 	char machine_name[NFS4_MAX_MACHINE_NAME_LEN];
 	uint32_t len;
 	struct nfs_client *clp = args->client;
+	struct nfs_net *nn = net_generic(clp->cl_net, nfs_net_id);
 	u32 max_resp_sz_cached;
 
 	/*
@@ -1743,7 +1746,7 @@ static void encode_create_session(struct xdr_stream *xdr,
 	*p++ = cpu_to_be32(RPC_AUTH_UNIX);			/* auth_sys */
 
 	/* authsys_parms rfc1831 */
-	*p++ = cpu_to_be32((u32)clp->cl_boot_time.tv_nsec);	/* stamp */
+	*p++ = (__be32)nn->boot_time.tv_nsec;		/* stamp */
 	p = xdr_encode_opaque(p, machine_name, len);
 	*p++ = cpu_to_be32(0);				/* UID */
 	*p++ = cpu_to_be32(0);				/* GID */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 59410b3..fbec57d 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -61,9 +61,6 @@ struct nfs_client {
 
 	struct rpc_wait_queue	cl_rpcwaitq;
 
-	/* used for the setclientid verifier */
-	struct timespec		cl_boot_time;
-
 	/* idmapper */
 	struct idmap *		cl_idmap;
 

