Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:60628 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758041Ab2CIWf4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Mar 2012 17:35:56 -0500
Received: by iagz16 with SMTP id z16so2859109iag.19
        for <linux-nfs@vger.kernel.org>; Fri, 09 Mar 2012 14:35:56 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: Always use the same SETCLIENTID boot verifier
To: linux-nfs@vger.kernel.org
Date: Fri, 09 Mar 2012 17:35:54 -0500
Message-ID: <20120309223445.4005.78869.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Our NFS client allocates a struct nfs_client to represent an NFS
server it has contacted.  Each server IP address a client knows about
gets one of these.

Currently our NFS client assigns a unique SETCLIENTID boot verifier
for each struct nfs_client.  It's set to CURRENT_TIME when a struct
nfs_client is created.

During a SETCLIENTID, our client also presents an nfs_client_id4
string to servers as a hook on which the server can hang all of the
client's NFSv4 state.  Our client's nfs_client_id4 string is also
unique for each server IP address.

An NFSv4 server is obligated to wipe all NFSv4 state for an NFS client
when the client presents a different SETCLIENTID boot verifier.  When
our client unmounts all shares on a server, it destroys the server's
nfs_client.  The next time the client mounts that NFS server, the
server will wipe any previous NFSv4 state for that client, because the
server will think the client rebooted, thanks to the changed boot
verifier value.

If we desire to allow sharing a client's state information between
servers that have unique IP addresses (for example, for clustered
NFSv4 servers), this client-side design becomes troublesome.

We can (and probably will) change our nfs_client_id4 string to be the
same for all NFS servers the client contacts, in order to support
Transparent State Migration.

If the boot verifier changes for each server IP address, a SETCLIENTID
from such a client could result in the server wiping the client's
previously obtained lease.  That would result in lost state and crashed
applications if our NFS client mounts shares on a single server that has
multiple separate IP addresses.

Thus, if our NFS client is going to use a fixed nfs_client_id4 string,
our NFS client should also use a SETCLIENTID boot verifier that does
not change depending on which NFS server is being contacted.  Set up a
global boot verifier that remains constant while the nfs.ko module is
loaded.

nfs4_reset_all_state() does not need to reset the boot verifier, so
that logic is removed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

For review only.

 fs/nfs/client.c           |    1 -
 fs/nfs/inode.c            |    4 ++++
 fs/nfs/internal.h         |    1 +
 fs/nfs/nfs4proc.c         |   11 +++++------
 fs/nfs/nfs4state.c        |    1 -
 fs/nfs/nfs4xdr.c          |    2 +-
 include/linux/nfs_fs_sb.h |    3 ---
 7 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 11b3864..e236d0b 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -180,7 +180,6 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	spin_lock_init(&clp->cl_lock);
 	INIT_DELAYED_WORK(&clp->cl_renewd, nfs4_renew_state);
 	rpc_init_wait_queue(&clp->cl_rpcwaitq, "NFS client");
-	clp->cl_boot_time = CURRENT_TIME;
 	clp->cl_state = 1 << NFS4CLNT_LEASE_EXPIRED;
 	clp->cl_minorversion = cl_init->minorversion;
 	clp->cl_mvops = nfs_v4_minor_ops[cl_init->minorversion];
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 6c619de..13c27ff 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -64,6 +64,8 @@ static int nfs_update_inode(struct inode *, struct nfs_fattr *);
 
 static struct kmem_cache * nfs_inode_cachep;
 
+struct timespec nfs_boot_time __read_mostly;
+
 static inline unsigned long
 nfs_fattr_to_ino_t(struct nfs_fattr *fattr)
 {
@@ -1649,6 +1651,8 @@ static int __init init_nfs_fs(void)
 #endif
 	if ((err = register_nfs_fs()) != 0)
 		goto out;
+
+	nfs_boot_time = CURRENT_TIME;
 	return 0;
 out:
 #ifdef CONFIG_PROC_FS
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 62ffefa..47b3384 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -248,6 +248,7 @@ extern int nfs_access_cache_shrinker(struct shrinker *shrink,
 					struct shrink_control *sc);
 
 /* inode.c */
+extern struct timespec nfs_boot_time;
 extern struct workqueue_struct *nfsiod_workqueue;
 extern struct inode *nfs_alloc_inode(struct super_block *sb);
 extern void nfs_destroy_inode(struct inode *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c0d7220..747bf7a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3773,13 +3773,12 @@ wait_on_recovery:
 	return -EAGAIN;
 }
 
-static void nfs4_construct_boot_verifier(struct nfs_client *clp,
-					 nfs4_verifier *bootverf)
+static void nfs4_gen_boot_verifier(nfs4_verifier *bootverf)
 {
 	__be32 verf[2];
 
-	verf[0] = htonl((u32)clp->cl_boot_time.tv_sec);
-	verf[1] = htonl((u32)clp->cl_boot_time.tv_nsec);
+	verf[0] = cpu_to_be32((u32)nfs_boot_time.tv_sec);
+	verf[1] = cpu_to_be32((u32)nfs_boot_time.tv_nsec);
 	memcpy(bootverf->data, verf, sizeof(bootverf->data));
 }
 
@@ -3802,7 +3801,7 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 	int loop = 0;
 	int status;
 
-	nfs4_construct_boot_verifier(clp, &sc_verifier);
+	nfs4_gen_boot_verifier(&sc_verifier);
 
 	for(;;) {
 		rcu_read_lock();
@@ -4888,7 +4887,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	dprintk("--> %s\n", __func__);
 	BUG_ON(clp == NULL);
 
-	nfs4_construct_boot_verifier(clp, &verifier);
+	nfs4_gen_boot_verifier(&verifier);
 
 	args.id_len = scnprintf(args.id, sizeof(args.id),
 				"%s/%s.%s/%u",
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 4db330d..a2b7c47 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1570,7 +1570,6 @@ void nfs41_handle_recall_slot(struct nfs_client *clp)
 static void nfs4_reset_all_state(struct nfs_client *clp)
 {
 	if (test_and_set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) == 0) {
-		clp->cl_boot_time = CURRENT_TIME;
 		nfs4_state_start_reclaim_nograce(clp);
 		nfs4_schedule_state_manager(clp);
 	}
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index ab41dce..7f4e5c2 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1834,7 +1834,7 @@ static void encode_create_session(struct xdr_stream *xdr,
 	*p++ = cpu_to_be32(RPC_AUTH_UNIX);			/* auth_sys */
 
 	/* authsys_parms rfc1831 */
-	*p++ = cpu_to_be32((u32)clp->cl_boot_time.tv_nsec);	/* stamp */
+	*p++ = cpu_to_be32((u32)nfs_boot_time.tv_nsec);	/* stamp */
 	p = xdr_encode_opaque(p, machine_name, len);
 	*p++ = cpu_to_be32(0);				/* UID */
 	*p++ = cpu_to_be32(0);				/* GID */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index d4dcb00..4689c92 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -59,9 +59,6 @@ struct nfs_client {
 
 	struct rpc_wait_queue	cl_rpcwaitq;
 
-	/* used for the setclientid verifier */
-	struct timespec		cl_boot_time;
-
 	/* idmapper */
 	struct idmap *		cl_idmap;
 

