Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42980 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751543AbdDJCTs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 9 Apr 2017 22:19:48 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 10 Apr 2017 12:19:40 +1000
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] sunrpc: don't check for failure from mempool_alloc()
Message-ID: <87zifpvwar.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


When mempool_alloc() is allowed to sleep (GFP_NOIO allows
sleeping) it cannot fail.
So rpc_alloc_task() cannot fail, so rpc_new_task doesn't need
to test for failure.
Consequently rpc_new_task() cannot fail, so the callers
don't need to test.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 net/sunrpc/clnt.c  | 8 --------
 net/sunrpc/sched.c | 5 -----
 2 files changed, 13 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 52da3ce54bb5..b5cb921775a0 100644
=2D-- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1042,8 +1042,6 @@ struct rpc_task *rpc_run_task(const struct rpc_task_s=
etup *task_setup_data)
 	struct rpc_task *task;
=20
 	task =3D rpc_new_task(task_setup_data);
=2D	if (IS_ERR(task))
=2D		goto out;
=20
 	rpc_task_set_client(task, task_setup_data->rpc_client);
 	rpc_task_set_rpc_message(task, task_setup_data->rpc_message);
@@ -1053,7 +1051,6 @@ struct rpc_task *rpc_run_task(const struct rpc_task_s=
etup *task_setup_data)
=20
 	atomic_inc(&task->tk_count);
 	rpc_execute(task);
=2Dout:
 	return task;
 }
 EXPORT_SYMBOL_GPL(rpc_run_task);
@@ -1140,10 +1137,6 @@ struct rpc_task *rpc_run_bc_task(struct rpc_rqst *re=
q)
 	 * Create an rpc_task to send the data
 	 */
 	task =3D rpc_new_task(&task_setup_data);
=2D	if (IS_ERR(task)) {
=2D		xprt_free_bc_request(req);
=2D		goto out;
=2D	}
 	task->tk_rqstp =3D req;
=20
 	/*
@@ -1158,7 +1151,6 @@ struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req)
 	WARN_ON_ONCE(atomic_read(&task->tk_count) !=3D 2);
 	rpc_execute(task);
=20
=2Dout:
 	dprintk("RPC: rpc_run_bc_task: task=3D %p\n", task);
 	return task;
 }
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 5db68b371db2..0cc83839c13c 100644
=2D-- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -965,11 +965,6 @@ struct rpc_task *rpc_new_task(const struct rpc_task_se=
tup *setup_data)
=20
 	if (task =3D=3D NULL) {
 		task =3D rpc_alloc_task();
=2D		if (task =3D=3D NULL) {
=2D			rpc_release_calldata(setup_data->callback_ops,
=2D					setup_data->callback_data);
=2D			return ERR_PTR(-ENOMEM);
=2D		}
 		flags =3D RPC_TASK_DYNAMIC;
 	}
=20
=2D-=20
2.12.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljq67wACgkQOeye3VZi
gbne3hAAwEkUUkP7w4ebXjf0drqeAHw+V0m2KqFBCYz694LD65BAnBO7/h7dZlRE
coepHeVo3mqACka71VETFBY2bhppjMyZHls7l0sjgzHu237fj6HyNYjwZwxWi7Zx
yIW4NVEqKIEu1iakEJ2eZj7OtMJcmrmgH4hlJKuhrLit0jm6v5YRjRlxpsch6qgk
ztWIxMbxlzTCtIab53GKy3SUyKR74zWS2a9k8nCPyMJoTZz1RJTkRXdpFYHwW5JG
HFE/+P9wzZmgbcZ6yf/FFQRz1HSArMmmpCn4mzvuw9rvCJWWFLzpo5droGEASd9q
3D0EAJ9suCNUO2Z38gEXfcUjKnjqqHhmkQO+3erZx0uYnTUBYGW2/CUvAMBFt2TB
gS1zzCw6nXcAnn9QGE1VwoCbU44iAF5shgz8O7tNmgO8u/oKssDcUTHB9sJ90f4Y
PkbAa6IowpFS9mxJaVOw97mCEIMs3UVPYer0oiO4pVjQKlFnHaLIzCTlaogGg+DT
qiGu0OqGmpmEAw1ymaeZD2T71vA+qGxcOM9EudzN9+vB/xMaDfh4xtMbLXnaPAnk
I/lS/sZAlseROKksmydM8Gy44SQE0hr/Q6mmB8Ky9RuDpHvOE87dTicMv3y6/f0c
1iZlTicZHl+NB2gk2gRb1ByvLoMifSEbMf+gfjYk1BASiDSLvaw=
=ckrW
-----END PGP SIGNATURE-----
--=-=-=--
