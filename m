Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:45915 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757689AbaGOGjw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2014 02:39:52 -0400
Date: Tue, 15 Jul 2014 16:39:42 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH/RFC] NFS: state manager thread must start running.
Message-ID: <20140715163942.1d94304f@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/n/3z/JKWxxEe7LXEIQYwD8_"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/n/3z/JKWxxEe7LXEIQYwD8_
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

In this patch the manager thread no longer holds a reference on the
client. Instead nfs4_shutdown_client() signals the thread to
shutdown and waits for it to do so using a completion.

Signed-off-by: NeilBrown <neilb@suse.de>

--
I suggested in an earlier email that it might be possible to use a
work-queue for this.  I concluded that it wasn't a good idea.
If a server was down, the manager cold block indefinitely.
If memory was tight and only one workqueue thread was active,
this would block other NFS mounts.

It is unfortunate that the task comm[] array only allow 16 chars.
A non-trivial IPv6 address doesn't fit in that at ALL.
I wonder if there is a better way to manage that.

NeilBrown


diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index ba2affa51941..0b7bc4da4035 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -432,6 +432,8 @@ extern void nfs4_schedule_lease_recovery(struct nfs_cli=
ent *);
 extern int nfs4_wait_clnt_recover(struct nfs_client *clp);
 extern int nfs4_client_recover_expired_lease(struct nfs_client *clp);
 extern void nfs4_schedule_state_manager(struct nfs_client *);
+extern int nfs4_start_state_manager(struct nfs_client *);
+extern void nfs4_shutdown_state_manager(struct nfs_client *);
 extern void nfs4_schedule_path_down_recovery(struct nfs_client *clp);
 extern int nfs4_schedule_stateid_recovery(const struct nfs_server *, struc=
t nfs4_state *);
 extern int nfs4_schedule_migration_recovery(const struct nfs_server *);
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index aa9ef4876046..24c80a52e633 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -219,6 +219,8 @@ static void nfs4_shutdown_client(struct nfs_client *clp)
 {
 	if (__test_and_clear_bit(NFS_CS_RENEWD, &clp->cl_res_state))
 		nfs4_kill_renewd(clp);
+	if (__test_and_clear_bit(NFS_CS_MANAGER, &clp->cl_res_state))
+		nfs4_shutdown_state_manager(clp);
 	clp->cl_mvops->shutdown_client(clp);
 	nfs4_destroy_callback(clp);
 	if (__test_and_clear_bit(NFS_CS_IDMAP, &clp->cl_res_state))
@@ -401,6 +403,11 @@ struct nfs_client *nfs4_init_client(struct nfs_client =
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
index 848f6853c59e..fbcc01f6193d 100644
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
@@ -1171,10 +1168,28 @@ void nfs4_schedule_state_manager(struct nfs_client =
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
+}
+
+void nfs4_shutdown_state_manager(struct nfs_client *clp)
+{
+	DECLARE_COMPLETION_ONSTACK(done);
+
+	clp->cl_manager_done =3D &done;
+	nfs4_schedule_state_manager(clp);
+	wait_for_completion(&done);
+	clp->cl_manager_done =3D NULL;
 }
=20
 /*
@@ -2328,7 +2343,6 @@ static void nfs4_state_manager(struct nfs_client *clp)
 	int status =3D 0;
 	const char *section =3D "", *section_sep =3D "";
=20
-	/* Ensure exclusive access to NFSv4 state */
 	do {
 		if (test_bit(NFS4CLNT_PURGE_STATE, &clp->cl_state)) {
 			section =3D "purge state";
@@ -2426,9 +2440,8 @@ static void nfs4_state_manager(struct nfs_client *clp)
 		/* Did we race with an attempt to give us more work? */
 		if (clp->cl_state =3D=3D 0)
 			break;
-		if (test_and_set_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) !=3D 0)
-			break;
-	} while (atomic_read(&clp->cl_count) > 1);
+		set_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state);
+	} while (atomic_read(&clp->cl_count) > 0);
 	return;
 out_error:
 	if (strlen(section))
@@ -2446,8 +2459,16 @@ static int nfs4_run_state_manager(void *ptr)
 	struct nfs_client *clp =3D ptr;
=20
 	allow_signal(SIGKILL);
-	nfs4_state_manager(clp);
-	nfs_put_client(clp);
+	while (!clp->cl_manager_done) {
+		if (signal_pending(current))
+			flush_signals(current);
+		wait_event_interruptible(
+			*bit_waitqueue(&clp->cl_state,
+				       NFS4CLNT_MANAGER_RUNNING),
+			test_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state));
+		nfs4_state_manager(clp);
+	}
+	complete(clp->cl_manager_done);
 	module_put_and_exit(0);
 	return 0;
 }
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 1150ea41b626..ee7483022c46 100644
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
@@ -69,6 +70,7 @@ struct nfs_client {
 	struct delayed_work	cl_renewd;
=20
 	struct rpc_wait_queue	cl_rpcwaitq;
+	struct completion	*cl_manager_done;
=20
 	/* idmapper */
 	struct idmap *		cl_idmap;

--Sig_/n/3z/JKWxxEe7LXEIQYwD8_
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU8TMrjnsnt1WYoG5AQI/eg//XizRjq32DGwMrhQo6V9yuOn/NfXKxoHT
e30/FCMcKnFIdUhYPe+23AukVYtzlmVsdyFYoGYea5Tb7N16+TMn8le+linkxlLs
kbBmg2ZEJW3Wmv5oftxsRWFQOJKovP67M3bIib6S/NCBHLTkvtYTp8qdJRbSo8xu
qT7hRKwu+yeWOfcFkU0zPKEOvykeEGzNNAlri0hl0kAhuvMEZjwkUT1p9Nx4OFvf
+qL1NGhKOcL6Go15CAHNhTY9IwzwQ6KnHVARqppzkpa28cRiPAcave0wCosZslmo
4hvChOSJU+ORa1vV4D3cTe4zhrHhCf7LFwaoxOoBCq/hOgdLqGAuNYQZzJCE/MqD
03DO3DEnWpFf3fSTLT+804iktMOIVjWWWC1EBTaPr/q+80tnLx1a1txGW2d256lr
X17wAVqpOBG3G1QjGQ37s+EkOFHdkfS5EYYlxhdIhAgzpu+Dh3E/FlH/wvJkd3KD
fpg/Mllf6/bt6eHLNMjAsc0nJWqlFXepeAnSTINBpmexUzFeYn/2lvkB7+77tyUu
qSXjJLAYvnp77UlFoOfRrfwCCjqeqnSAARrCDODduzhSfZ5uH5njuroSHmlId1Cs
pYErJ/JNDQXs8T/8I+JGPLvje6bY4Ks9QuLnU+s+keghyC5aGflvvOlGZZIe+es1
ZgWYsdgiRl8=
=NQfs
-----END PGP SIGNATURE-----

--Sig_/n/3z/JKWxxEe7LXEIQYwD8_--
