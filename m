Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56949 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932248AbeBTALI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Feb 2018 19:11:08 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Tue, 20 Feb 2018 11:10:59 +1100
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 14/23 - V2] SUNRPC: add side channel to use non-generic cred for rpc call.
In-Reply-To: <151901654925.17421.8083987724119246673.stgit@noble>
References: <151901634940.17421.7637564368419392071.stgit@noble> <151901654925.17421.8083987724119246673.stgit@noble>
Message-ID: <87zi44jzak.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


The credential passed in rpc_message.rpc_cred is always a
generic credential except in one instance.
When gss_destroying_context() calls rpc_call_null(), it passes
a specific credential that it needs to destroy.
In this case the RPC acts *on* the credential rather than
being authorized by it.

This special case deserves explicit support and providing that will
mean that rpc_message.rpc_cred is *always* generic, allowing
some optimizations.

So add "tk_op_cred" to rpc_task and "rpc_op_cred" to the setup data.
Use this to pass the cred down from rpc_call_null(), and have
rpcauth_bindcred() notice it and bind it in place.

Credit to kernel test robot <fengguang.wu@intel.com> for finding
a bug in earlier version of this patch.

Signed-off-by: NeilBrown <neilb@suse.com>

=2D--

This replaces a patch already in nfs-next.
If you would like an incremental patch instead, please let me know.

Thanks,
NeilBrown

 include/linux/sunrpc/sched.h | 2 ++
 net/sunrpc/auth.c            | 6 +++++-
 net/sunrpc/clnt.c            | 2 +-
 net/sunrpc/sched.c           | 3 +++
 4 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 216b6a7513db..be278d92ff4f 100644
=2D-- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -71,6 +71,7 @@ struct rpc_task {
=20
 	struct rpc_clnt *	tk_client;	/* RPC client */
 	struct rpc_xprt *	tk_xprt;	/* Transport */
+	struct rpc_cred *	tk_op_cred;	/* cred being operated on */
=20
 	struct rpc_rqst *	tk_rqstp;	/* RPC request */
=20
@@ -105,6 +106,7 @@ struct rpc_task_setup {
 	struct rpc_task *task;
 	struct rpc_clnt *rpc_client;
 	struct rpc_xprt *rpc_xprt;
+	struct rpc_cred *rpc_op_cred;	/* credential being operated on */
 	const struct rpc_message *rpc_message;
 	const struct rpc_call_ops *callback_ops;
 	void *callback_data;
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 484a850a7e00..0130d0151623 100644
=2D-- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -726,7 +726,11 @@ rpcauth_bindcred(struct rpc_task *task, struct rpc_cre=
d *cred, int flags)
=20
 	if (flags & RPC_TASK_ASYNC)
 		lookupflags |=3D RPCAUTH_LOOKUP_NEW;
=2D	if (cred !=3D NULL && cred !=3D &machine_cred)
+	if (task->tk_op_cred)
+		/* Task must use exactly this rpc_cred */
+		new =3D task->tk_op_cred->cr_ops->crbind(task, task->tk_op_cred,
+						       lookupflags);
+	else if (cred !=3D NULL && cred !=3D &machine_cred)
 		new =3D cred->cr_ops->crbind(task, cred, lookupflags);
 	else if (cred =3D=3D &machine_cred)
 		new =3D rpcauth_bind_machine_cred(task, lookupflags);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 85db88bfb4c8..be66fec601b0 100644
=2D-- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2516,12 +2516,12 @@ struct rpc_task *rpc_call_null_helper(struct rpc_cl=
nt *clnt,
 {
 	struct rpc_message msg =3D {
 		.rpc_proc =3D &rpcproc_null,
=2D		.rpc_cred =3D cred,
 	};
 	struct rpc_task_setup task_setup_data =3D {
 		.rpc_client =3D clnt,
 		.rpc_xprt =3D xprt,
 		.rpc_message =3D &msg,
+		.rpc_op_cred =3D cred,
 		.callback_ops =3D (ops !=3D NULL) ? ops : &rpc_default_ops,
 		.callback_data =3D data,
 		.flags =3D flags,
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index d9db2eab3a8d..91a8265d00d5 100644
=2D-- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -949,6 +949,8 @@ static void rpc_init_task(struct rpc_task *task, const =
struct rpc_task_setup *ta
=20
 	task->tk_xprt =3D xprt_get(task_setup_data->rpc_xprt);
=20
+	task->tk_op_cred =3D get_rpccred(task_setup_data->rpc_op_cred);
+
 	if (task->tk_ops->rpc_call_prepare !=3D NULL)
 		task->tk_action =3D rpc_prepare_task;
=20
@@ -1006,6 +1008,7 @@ static void rpc_free_task(struct rpc_task *task)
 {
 	unsigned short tk_flags =3D task->tk_flags;
=20
+	put_rpccred(task->tk_op_cred);
 	rpc_release_calldata(task->tk_ops, task->tk_calldata);
=20
 	if (tk_flags & RPC_TASK_DYNAMIC) {
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlqLZ5QACgkQOeye3VZi
gbm2fA//Ve0vTdh8O9afFeavMuOjxrPuFFEgGGozRHkjt/iVJBemGFurKpxIcG+J
s4weEVClx3I7wTbbSxAyyWCkiC3Wri4ObomiPZtJxS9JDzruusOlLoRzpuKB4q90
QU196WWykkzc3CY1yi0EB3C2tmaCk/QEuGsxrUqGmbMbhRVLNjzeBPrMYgZtyf4h
ByrxhL6W0gZ3/lcLCJ3QZ3+NvM5L6S2v59mcV1UmEzspNpRKKmMQZPhGVO1DAFEv
Uqr4ZsUbEZfMttLYDZ6z3aFCkfOJmTlXnQK5UVMOoAeeLFk7NK0slXrDkkRJ5y8u
A9maHw0OhuETeXzcKtJtRjPMQz90vPkDrWxr8tndfqFYHWgI9xg9jat7RBxV4Ejm
jRDR3fZ4qpgkmhGODBieof63LzcngAcuLnfJWlgcS87mlO+nnljTl8x1WDKHb7N/
9dC7K3Cx6Vly6zQVI6N5i5Zlia8YlNt01v97f7WWgaNPnCnzBmXF0JcgJg99/mQq
rlcfz2lEmlqOph1TUq379xszBL9QcJ6xNhxomJprg1pc4z0heEHGptm51uczXJKa
8SiJKRjLhv8jHMK4XiddV6zFasImxDRhETGD8BxX74DOQobnNSOtZbI4MUcW7+/H
wsW9YY30DIDf/CWcvtr0dtlsIbwlpwVmkypDut606bCA/hSSn+U=
=1ODE
-----END PGP SIGNATURE-----
--=-=-=--
