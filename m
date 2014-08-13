Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:50909 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750713AbaHMEIl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Aug 2014 00:08:41 -0400
Date: Wed, 13 Aug 2014 14:08:31 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: NFS <linux-nfs@vger.kernel.org>, Tejun Heo <tj@kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: [PATCH] NFS: state manager thread must stay running.
Message-ID: <20140813140831.22f3e9c7@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/_FKqIF...lYNnrLwSO5Euv0"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/_FKqIF...lYNnrLwSO5Euv0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



If the server restarts at an awkward time it is possible for write
requests to block waiting for the state manager to run.
If the state manager isn't already running a new thread will
need to be started which requires a GFP_KERNEL allocation
(for do_fork).

If memory is short, that GFP_KERNEL allocation could block on the
writes going out via NFS, resulting in a deadlock.

The easiest solution is to keep the manager thread running
always.

There are two interesting requirements for the manager thread:
1/ It must allow SIGKILL, which can abort NFS transactions to
   a dead server.
2/ It may continue running after the filesystem is unmounted,
   until the server recovers or the thread is SIGKILLed

These, particularly the last, make it unsuitable for kthread_worker,
which can only be killed synchronously (via kthread_stop()).

In this patch the manager thread no longer holds a counted reference
on the client. Instead a new flag NFS_CS_MANAGER indicates that the
thread is running and so holds an implicit reference.
nfs_put_client will only free the client if this flag is clear.
If it is set, the manager must free the client.

nn->nfs_client_lock is used to ensure nfs_put_client() and the
thread don't trip over each other at shutdown.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 180d1ec9c32e..9973675737dd 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -272,13 +272,16 @@ void nfs_put_client(struct nfs_client *clp)
 	nn =3D net_generic(clp->cl_net, nfs_net_id);
=20
 	if (atomic_dec_and_lock(&clp->cl_count, &nn->nfs_client_lock)) {
+		int manager_will_free =3D
+			test_bit(NFS_CS_MANAGER, &clp->cl_res_state);
 		list_del(&clp->cl_share_link);
 		nfs_cb_idr_remove_locked(clp);
-		spin_unlock(&nn->nfs_client_lock);
-
+		if (manager_will_free)
+			nfs4_schedule_state_manager(clp);
 		WARN_ON_ONCE(!list_empty(&clp->cl_superblocks));
-
-		clp->rpc_ops->free_client(clp);
+		spin_unlock(&nn->nfs_client_lock);
+		if (!manager_will_free)
+			clp->rpc_ops->free_client(clp);
 	}
 }
 EXPORT_SYMBOL_GPL(nfs_put_client);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index ba2affa51941..014e730ee7a2 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -432,6 +432,7 @@ extern void nfs4_schedule_lease_recovery(struct nfs_cli=
ent *);
 extern int nfs4_wait_clnt_recover(struct nfs_client *clp);
 extern int nfs4_client_recover_expired_lease(struct nfs_client *clp);
 extern void nfs4_schedule_state_manager(struct nfs_client *);
+extern int nfs4_start_state_manager(struct nfs_client *);
 extern void nfs4_schedule_path_down_recovery(struct nfs_client *clp);
 extern int nfs4_schedule_stateid_recovery(const struct nfs_server *, struc=
t nfs4_state *);
 extern int nfs4_schedule_migration_recovery(const struct nfs_server *);
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index aa9ef4876046..907111174886 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -401,6 +401,11 @@ struct nfs_client *nfs4_init_client(struct nfs_client =
*clp,
 	}
 	__set_bit(NFS_CS_IDMAP, &clp->cl_res_state);
=20
+	error =3D nfs4_start_state_manager(clp);
+	if (error < 0)
+		goto error;
+	__set_bit(NFS_CS_MANAGER, &clp->cl_res_state);
+
 	error =3D nfs4_init_client_minor_version(clp);
 	if (error < 0)
 		goto error;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 42f121182167..69d12decd04a 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1150,15 +1150,12 @@ static void nfs4_clear_state_manager_bit(struct nfs=
_client *clp)
 /*
  * Schedule the nfs_client asynchronous state management routine
  */
-void nfs4_schedule_state_manager(struct nfs_client *clp)
+int nfs4_start_state_manager(struct nfs_client *clp)
 {
 	struct task_struct *task;
 	char buf[INET6_ADDRSTRLEN + sizeof("-manager") + 1];
=20
-	if (test_and_set_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) !=3D 0)
-		return;
 	__module_get(THIS_MODULE);
-	atomic_inc(&clp->cl_count);
=20
 	/* The rcu_read_lock() is not strictly necessary, as the state
 	 * manager is the only thread that ever changes the rpc_xprt
@@ -1171,10 +1168,18 @@ void nfs4_schedule_state_manager(struct nfs_client =
*clp)
 	if (IS_ERR(task)) {
 		printk(KERN_ERR "%s: kthread_run: %ld\n",
 			__func__, PTR_ERR(task));
-		nfs4_clear_state_manager_bit(clp);
-		nfs_put_client(clp);
 		module_put(THIS_MODULE);
+		return PTR_ERR(task);
 	}
+	return 0;
+}
+
+void nfs4_schedule_state_manager(struct nfs_client *clp)
+{
+	if (test_and_set_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) !=3D 0)
+		return;
+	smp_mb__after_atomic();
+	wake_up_bit(&clp->cl_state, NFS4CLNT_MANAGER_RUNNING);
 }
=20
 /*
@@ -2328,8 +2333,12 @@ static void nfs4_state_manager(struct nfs_client *cl=
p)
 	int status =3D 0;
 	const char *section =3D "", *section_sep =3D "";
=20
-	/* Ensure exclusive access to NFSv4 state */
-	do {
+	while (atomic_read(&clp->cl_count) && clp->cl_state) {
+		/* If we found more work to do, we must ensure the
+		 * bit is set so other code can wait for it.
+		 */
+		set_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state);
+
 		if (test_bit(NFS4CLNT_PURGE_STATE, &clp->cl_state)) {
 			section =3D "purge state";
 			status =3D nfs4_purge_lease(clp);
@@ -2423,12 +2432,7 @@ static void nfs4_state_manager(struct nfs_client *cl=
p)
 		}
=20
 		nfs4_clear_state_manager_bit(clp);
-		/* Did we race with an attempt to give us more work? */
-		if (clp->cl_state =3D=3D 0)
-			break;
-		if (test_and_set_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) !=3D 0)
-			break;
-	} while (atomic_read(&clp->cl_count) > 1);
+	}
 	return;
 out_error:
 	if (strlen(section))
@@ -2444,10 +2448,23 @@ out_error:
 static int nfs4_run_state_manager(void *ptr)
 {
 	struct nfs_client *clp =3D ptr;
+	struct nfs_net *nn;
=20
 	allow_signal(SIGKILL);
-	nfs4_state_manager(clp);
-	nfs_put_client(clp);
+	while (atomic_read(&clp->cl_count)) {
+		if (signal_pending(current))
+			flush_signals(current);
+		wait_event_interruptible(
+			*bit_waitqueue(&clp->cl_state,
+				       NFS4CLNT_MANAGER_RUNNING),
+			test_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state));
+		nfs4_state_manager(clp);
+	}
+	nn =3D net_generic(clp->cl_net, nfs_net_id);
+	spin_lock(&nn->nfs_client_lock);
+	/* nfs_put_client has definitely stopped using its reference */
+	spin_unlock(&nn->nfs_client_lock);
+	clp->rpc_ops->free_client(clp);
 	module_put_and_exit(0);
 	return 0;
 }
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 1150ea41b626..40c7d1a53388 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -36,6 +36,7 @@ struct nfs_client {
 #define NFS_CS_RENEWD		3		/* - renewd started */
 #define NFS_CS_STOP_RENEW	4		/* no more state to renew */
 #define NFS_CS_CHECK_LEASE_TIME	5		/* need to check lease time */
+#define NFS_CS_MANAGER		6		/* NFSv4 manager thread running */
 	unsigned long		cl_flags;	/* behavior switches */
 #define NFS_CS_NORESVPORT	0		/* - use ephemeral src port */
 #define NFS_CS_DISCRTRY		1		/* - disconnect on RPC retry */

--Sig_/_FKqIF...lYNnrLwSO5Euv0
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU+rkvznsnt1WYoG5AQJoMw/8CGG5E1s6N2eStYFFrn6NqpFbnhvqae1W
uxdyoPW8ULhl8h2lIIbKgbjDrjkRGq/20e1JZkc873iSQUbarXZiGSldtsFD03xa
T3ePy3nFdnY1eGr//spyPuHidQHKepO/yzsyHUSXSd89+qgKuvcdS5SyuuKJexas
pXRzdpHoy23D/XXAQa+ETBqCuiyBx0cg9fdYwUPuQw4g3XdBgt3H3+gvVoi99kve
CuhbpnEzXgwF5WDLMabuu+Jiv7ZifnIlIeLIbKhHFiixGYYBtWGydrNb56Rs0jDW
DgneafruMZWCjqmwzpTntKii8IQZf6olnZ0XzHeNRFvfMxSjifA86lOal0nRa1H0
N+r1IF/1f/SVU40G6ztk/eef0C0Ox3NlA90vh+hYVmD3bEjOEM58CgeJJgcAeueJ
HpFL3oVJdnZJCa88bxJQ0+dI4eSWITCqrNn3tD8er9K7frtgRSF4YIcpf4L58wdW
xnw8mphs/SRNmI7ru3mGnz/cZZzKW+1OkHML2juXyZBvoTrWp3cwTDX47asmEqD3
bdEh1hCKkt6STSvF0yfSJ/XJX9eFrboPtgosHn6x+JuJWQwkAu+H5G4GsSxDhdh0
mMPx6JEfF3l/gLXj2+BFA3O/8lcUArL7+xllaQuCIV6pRkRNwOGRzG1Q9J8pXM3l
tqJWpeOiBYU=
=SME+
-----END PGP SIGNATURE-----

--Sig_/_FKqIF...lYNnrLwSO5Euv0--
