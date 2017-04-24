Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43408 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752583AbdDXDnw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 23 Apr 2017 23:43:52 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 24 Apr 2017 13:43:43 +1000
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [nfs PATCH] NFS: remove error handling for callers of rpc_new_task()
In-Reply-To: <87zifpvwar.fsf@notabene.neil.brown.name>
References: <87zifpvwar.fsf@notabene.neil.brown.name>
Message-ID: <8760huqxlc.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Since commit 62b2417e84ba ("sunrpc: don't check for failure from mempool_al=
loc()")

rpc_new_task() cannot fail, so functions which fail only when it failed
also cannot fail.
This means we no longer need to check for errors from:

 rpc_run_task()
 rpc_run_bc_task()
 __nlm_async_call()
 nfs4_do_unlck()
 _nfs41_proc_sequence()
 _nfs41_free_stateid()
 nfs_async_rename()
 rpc_call_null()
 rpc_call_null_helper()
 rpcb_call_async()

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

Hi,
 if you think there might ever be a need to allow
 rpc_new_task() to fail in the future, we might not
 want to take this approach.

Thanks,
NeilBrown



 fs/lockd/clntproc.c            |  4 ---
 fs/nfs/nfs42proc.c             |  2 --
 fs/nfs/nfs4proc.c              | 66 ++++++--------------------------------=
----
 fs/nfs/pagelist.c              |  5 ----
 fs/nfs/unlink.c                |  9 +-----
 fs/nfs/write.c                 |  2 --
 net/sunrpc/auth_gss/auth_gss.c |  3 +-
 net/sunrpc/clnt.c              | 10 -------
 net/sunrpc/rpcb_clnt.c         |  6 ----
 net/sunrpc/svc.c               |  6 ----
 10 files changed, 11 insertions(+), 102 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 112952037933..6f472f4161b8 100644
=2D-- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -357,8 +357,6 @@ static int nlm_do_async_call(struct nlm_rqst *req, u32 =
proc, struct rpc_message
 	struct rpc_task *task;
=20
 	task =3D __nlm_async_call(req, proc, msg, tk_ops);
=2D	if (IS_ERR(task))
=2D		return PTR_ERR(task);
 	rpc_put_task(task);
 	return 0;
 }
@@ -402,8 +400,6 @@ static int nlmclnt_async_call(struct rpc_cred *cred, st=
ruct nlm_rqst *req, u32 p
 	int err;
=20
 	task =3D __nlm_async_call(req, proc, &msg, tk_ops);
=2D	if (IS_ERR(task))
=2D		return PTR_ERR(task);
 	err =3D rpc_wait_for_completion_task(task);
 	rpc_put_task(task);
 	return err;
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index c81c61971625..7f08c972a138 100644
=2D-- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -453,8 +453,6 @@ int nfs42_proc_layoutstats_generic(struct nfs_server *s=
erver,
 	}
 	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 0);
 	task =3D rpc_run_task(&task_setup);
=2D	if (IS_ERR(task))
=2D		return PTR_ERR(task);
 	rpc_put_task(task);
 	return 0;
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6e9ff2d9a5bf..e17fba7baf06 100644
=2D-- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -973,12 +973,8 @@ static int nfs4_call_sync_sequence(struct rpc_clnt *cl=
nt,
 	};
=20
 	task =3D rpc_run_task(&task_setup);
=2D	if (IS_ERR(task))
=2D		ret =3D PTR_ERR(task);
=2D	else {
=2D		ret =3D task->tk_status;
=2D		rpc_put_task(task);
=2D	}
+	ret =3D task->tk_status;
+	rpc_put_task(task);
 	return ret;
 }
=20
@@ -2020,8 +2016,6 @@ static int _nfs4_proc_open_confirm(struct nfs4_openda=
ta *data)
 	if (data->is_recover)
 		nfs4_set_sequence_privileged(&data->c_arg.seq_args);
 	task =3D rpc_run_task(&task_setup_data);
=2D	if (IS_ERR(task))
=2D		return PTR_ERR(task);
 	status =3D rpc_wait_for_completion_task(task);
 	if (status !=3D 0) {
 		data->cancelled =3D 1;
@@ -2187,8 +2181,6 @@ static int nfs4_run_open_task(struct nfs4_opendata *d=
ata, int isrecover)
 		data->is_recover =3D 1;
 	}
 	task =3D rpc_run_task(&task_setup_data);
=2D	if (IS_ERR(task))
=2D		return PTR_ERR(task);
 	status =3D rpc_wait_for_completion_task(task);
 	if (status !=3D 0) {
 		data->cancelled =3D 1;
@@ -3205,8 +3197,6 @@ int nfs4_do_close(struct nfs4_state *state, gfp_t gfp=
_mask, int wait)
 	msg.rpc_resp =3D &calldata->res;
 	task_setup_data.callback_data =3D calldata;
 	task =3D rpc_run_task(&task_setup_data);
=2D	if (IS_ERR(task))
=2D		return PTR_ERR(task);
 	status =3D 0;
 	if (wait)
 		status =3D rpc_wait_for_completion_task(task);
@@ -5472,10 +5462,6 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u3=
2 program,
 		clp->cl_rpcclient->cl_auth->au_ops->au_name,
 		clp->cl_owner_id);
 	task =3D rpc_run_task(&task_setup_data);
=2D	if (IS_ERR(task)) {
=2D		status =3D PTR_ERR(task);
=2D		goto out;
=2D	}
 	status =3D task->tk_status;
 	if (setclientid.sc_cred) {
 		clp->cl_acceptor =3D rpcauth_stringify_acceptor(setclientid.sc_cred);
@@ -5691,8 +5677,6 @@ static int _nfs4_proc_delegreturn(struct inode *inode=
, struct rpc_cred *cred, co
 	msg.rpc_argp =3D &data->args;
 	msg.rpc_resp =3D &data->res;
 	task =3D rpc_run_task(&task_setup_data);
=2D	if (IS_ERR(task))
=2D		return PTR_ERR(task);
 	if (!issync)
 		goto out;
 	status =3D rpc_wait_for_completion_task(task);
@@ -5962,9 +5946,6 @@ static int nfs4_proc_unlck(struct nfs4_state *state, =
int cmd, struct file_lock *
 	if (IS_ERR(seqid))
 		goto out;
 	task =3D nfs4_do_unlck(request, nfs_file_open_context(request->fl_file), =
lsp, seqid);
=2D	status =3D PTR_ERR(task);
=2D	if (IS_ERR(task))
=2D		goto out;
 	status =3D rpc_wait_for_completion_task(task);
 	rpc_put_task(task);
 out:
@@ -6120,8 +6101,7 @@ static void nfs4_lock_release(void *calldata)
 		struct rpc_task *task;
 		task =3D nfs4_do_unlck(&data->fl, data->ctx, data->lsp,
 				data->arg.lock_seqid);
=2D		if (!IS_ERR(task))
=2D			rpc_put_task_async(task);
+		rpc_put_task_async(task);
 		dprintk("%s: cancelling lock!\n", __func__);
 	} else
 		nfs_free_seqid(data->arg.lock_seqid);
@@ -6190,8 +6170,6 @@ static int _nfs4_do_setlk(struct nfs4_state *state, i=
nt cmd, struct file_lock *f
 	} else
 		data->arg.new_lock =3D 1;
 	task =3D rpc_run_task(&task_setup_data);
=2D	if (IS_ERR(task))
=2D		return PTR_ERR(task);
 	ret =3D rpc_wait_for_completion_task(task);
 	if (ret =3D=3D 0) {
 		ret =3D data->rpc_status;
@@ -7166,11 +7144,8 @@ int nfs4_proc_bind_one_conn_to_session(struct rpc_cl=
nt *clnt,
 		args.dir =3D NFS4_CDFC4_FORE;
=20
 	task =3D rpc_run_task(&task_setup_data);
=2D	if (!IS_ERR(task)) {
=2D		status =3D task->tk_status;
=2D		rpc_put_task(task);
=2D	} else
=2D		status =3D PTR_ERR(task);
+	status =3D task->tk_status;
+	rpc_put_task(task);
 	trace_nfs4_bind_conn_to_session(clp, status);
 	if (status =3D=3D 0) {
 		if (memcmp(res.sessionid.data,
@@ -7524,8 +7499,6 @@ static int _nfs4_proc_exchange_id(struct nfs_client *=
clp, struct rpc_cred *cred,
 	task_setup_data.callback_data =3D calldata;
=20
 	task =3D rpc_run_task(&task_setup_data);
=2D	if (IS_ERR(task))
=2D		return PTR_ERR(task);
=20
 	if (!xprt) {
 		status =3D rpc_wait_for_completion_task(task);
@@ -7754,12 +7727,11 @@ int nfs4_proc_get_lease_time(struct nfs_client *clp=
, struct nfs_fsinfo *fsinfo)
 	nfs4_init_sequence(&args.la_seq_args, &res.lr_seq_res, 0);
 	nfs4_set_sequence_privileged(&args.la_seq_args);
 	task =3D rpc_run_task(&task_setup);
=2D
=2D	if (IS_ERR(task))
=2D		return PTR_ERR(task);
=2D
 	status =3D task->tk_status;
 	rpc_put_task(task);
+
+	dprintk("<-- %s return %d\n", __func__, status);
+
 	return status;
 }
=20
@@ -8105,10 +8077,7 @@ static int nfs41_proc_async_sequence(struct nfs_clie=
nt *clp, struct rpc_cred *cr
 	if ((renew_flags & NFS4_RENEW_TIMEOUT) =3D=3D 0)
 		return -EAGAIN;
 	task =3D _nfs41_proc_sequence(clp, cred, false);
=2D	if (IS_ERR(task))
=2D		ret =3D PTR_ERR(task);
=2D	else
=2D		rpc_put_task_async(task);
+	rpc_put_task_async(task);
 	dprintk("<-- %s status=3D%d\n", __func__, ret);
 	return ret;
 }
@@ -8119,15 +8088,10 @@ static int nfs4_proc_sequence(struct nfs_client *cl=
p, struct rpc_cred *cred)
 	int ret;
=20
 	task =3D _nfs41_proc_sequence(clp, cred, true);
=2D	if (IS_ERR(task)) {
=2D		ret =3D PTR_ERR(task);
=2D		goto out;
=2D	}
 	ret =3D rpc_wait_for_completion_task(task);
 	if (!ret)
 		ret =3D task->tk_status;
 	rpc_put_task(task);
=2Dout:
 	dprintk("<-- %s status=3D%d\n", __func__, ret);
 	return ret;
 }
@@ -8230,10 +8194,6 @@ static int nfs41_proc_reclaim_complete(struct nfs_cl=
ient *clp,
 	msg.rpc_resp =3D &calldata->res;
 	task_setup_data.callback_data =3D calldata;
 	task =3D rpc_run_task(&task_setup_data);
=2D	if (IS_ERR(task)) {
=2D		status =3D PTR_ERR(task);
=2D		goto out;
=2D	}
 	status =3D rpc_wait_for_completion_task(task);
 	if (status =3D=3D 0)
 		status =3D task->tk_status;
@@ -8464,8 +8424,6 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, long =
*timeout, gfp_t gfp_flags)
 	nfs4_init_sequence(&lgp->args.seq_args, &lgp->res.seq_res, 0);
=20
 	task =3D rpc_run_task(&task_setup_data);
=2D	if (IS_ERR(task))
=2D		return ERR_CAST(task);
 	status =3D rpc_wait_for_completion_task(task);
 	if (status =3D=3D 0) {
 		status =3D nfs4_layoutget_handle_exception(task, lgp, &exception);
@@ -8582,8 +8540,6 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *=
lrp, bool sync)
 	}
 	nfs4_init_sequence(&lrp->args.seq_args, &lrp->res.seq_res, 1);
 	task =3D rpc_run_task(&task_setup_data);
=2D	if (IS_ERR(task))
=2D		return PTR_ERR(task);
 	if (sync)
 		status =3D task->tk_status;
 	trace_nfs4_layoutreturn(lrp->args.inode, &lrp->args.stateid, status);
@@ -8729,8 +8685,6 @@ nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data =
*data, bool sync)
 	}
 	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
 	task =3D rpc_run_task(&task_setup_data);
=2D	if (IS_ERR(task))
=2D		return PTR_ERR(task);
 	if (sync)
 		status =3D task->tk_status;
 	trace_nfs4_layoutcommit(data->args.inode, &data->args.stateid, status);
@@ -9056,8 +9010,6 @@ static int nfs41_free_stateid(struct nfs_server *serv=
er,
 	struct rpc_task *task;
=20
 	task =3D _nfs41_free_stateid(server, stateid, cred, is_recovery);
=2D	if (IS_ERR(task))
=2D		return PTR_ERR(task);
 	rpc_put_task(task);
 	return 0;
 }
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index f53610672f03..ec94f36d650b 100644
=2D-- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -599,17 +599,12 @@ int nfs_initiate_pgio(struct rpc_clnt *clnt, struct n=
fs_pgio_header *hdr,
 		(unsigned long long)hdr->args.offset);
=20
 	task =3D rpc_run_task(&task_setup_data);
=2D	if (IS_ERR(task)) {
=2D		ret =3D PTR_ERR(task);
=2D		goto out;
=2D	}
 	if (how & FLUSH_SYNC) {
 		ret =3D rpc_wait_for_completion_task(task);
 		if (ret =3D=3D 0)
 			ret =3D task->tk_status;
 	}
 	rpc_put_task(task);
=2Dout:
 	return ret;
 }
 EXPORT_SYMBOL_GPL(nfs_initiate_pgio);
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 191aa577dd1f..fcdc4b289962 100644
=2D-- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -108,8 +108,7 @@ static void nfs_do_call_unlink(struct nfs_unlinkdata *d=
ata)
=20
 	task_setup_data.rpc_client =3D NFS_CLIENT(dir);
 	task =3D rpc_run_task(&task_setup_data);
=2D	if (!IS_ERR(task))
=2D		rpc_put_task_async(task);
+	rpc_put_task_async(task);
 }
=20
 static int nfs_call_unlink(struct dentry *dentry, struct nfs_unlinkdata *d=
ata)
@@ -484,12 +483,6 @@ nfs_sillyrename(struct inode *dir, struct dentry *dent=
ry)
 	/* run the rename task, undo unlink if it fails */
 	task =3D nfs_async_rename(dir, dir, dentry, sdentry,
 					nfs_complete_sillyrename);
=2D	if (IS_ERR(task)) {
=2D		error =3D -EBUSY;
=2D		nfs_cancel_async_unlink(dentry);
=2D		goto out_dput;
=2D	}
=2D
 	/* wait for the RPC task to complete, unless a SIGKILL intervenes */
 	error =3D rpc_wait_for_completion_task(task);
 	if (error =3D=3D 0)
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index bbb289591e02..1572e9b94173 100644
=2D-- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1622,8 +1622,6 @@ int nfs_initiate_commit(struct rpc_clnt *clnt, struct=
 nfs_commit_data *data,
 		NFS_SP4_MACH_CRED_COMMIT, &task_setup_data.rpc_client, &msg);
=20
 	task =3D rpc_run_task(&task_setup_data);
=2D	if (IS_ERR(task))
=2D		return PTR_ERR(task);
 	if (how & FLUSH_SYNC)
 		rpc_wait_for_completion_task(task);
 	rpc_put_task(task);
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 4f16953e4954..8b0718b39930 100644
=2D-- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1232,8 +1232,7 @@ gss_destroying_context(struct rpc_cred *cred)
 	get_rpccred(cred);
=20
 	task =3D rpc_call_null(gss_auth->client, cred, RPC_TASK_ASYNC|RPC_TASK_SO=
FT);
=2D	if (!IS_ERR(task))
=2D		rpc_put_task(task);
+	rpc_put_task(task);
=20
 	put_rpccred(cred);
 	return 1;
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index b5cb921775a0..66fbf1d0c7fa 100644
=2D-- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1080,8 +1080,6 @@ int rpc_call_sync(struct rpc_clnt *clnt, const struct=
 rpc_message *msg, int flag
 	}
=20
 	task =3D rpc_run_task(&task_setup_data);
=2D	if (IS_ERR(task))
=2D		return PTR_ERR(task);
 	status =3D task->tk_status;
 	rpc_put_task(task);
 	return status;
@@ -1110,8 +1108,6 @@ rpc_call_async(struct rpc_clnt *clnt, const struct rp=
c_message *msg, int flags,
 	};
=20
 	task =3D rpc_run_task(&task_setup_data);
=2D	if (IS_ERR(task))
=2D		return PTR_ERR(task);
 	rpc_put_task(task);
 	return 0;
 }
@@ -2582,8 +2578,6 @@ int rpc_clnt_test_and_add_xprt(struct rpc_clnt *clnt,
 			RPC_TASK_SOFT|RPC_TASK_SOFTCONN|RPC_TASK_ASYNC,
 			&rpc_cb_add_xprt_call_ops, data);
 	put_rpccred(cred);
=2D	if (IS_ERR(task))
=2D		return PTR_ERR(task);
 	rpc_put_task(task);
 	return 1;
 }
@@ -2629,10 +2623,6 @@ int rpc_clnt_setup_test_and_add_xprt(struct rpc_clnt=
 *clnt,
 				    RPC_TASK_SOFT | RPC_TASK_SOFTCONN,
 				    NULL, NULL);
 	put_rpccred(cred);
=2D	if (IS_ERR(task)) {
=2D		status =3D PTR_ERR(task);
=2D		goto out_err;
=2D	}
 	status =3D task->tk_status;
 	rpc_put_task(task);
=20
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 5b30603596d0..5e30f1b8e4d9 100644
=2D-- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -781,12 +781,6 @@ void rpcb_getport_async(struct rpc_task *task)
=20
 	child =3D rpcb_call_async(rpcb_clnt, map, proc);
 	rpc_release_client(rpcb_clnt);
=2D	if (IS_ERR(child)) {
=2D		/* rpcb_map_release() has freed the arguments */
=2D		dprintk("RPC: %5u %s: rpc_run_task failed\n",
=2D			task->tk_pid, __func__);
=2D		return;
=2D	}
=20
 	xprt->stat.bind_count++;
 	rpc_put_task(child);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index a08aeb56b8e4..58b823d7b68c 100644
=2D-- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1449,16 +1449,10 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rq=
st *req,
 	/* Finally, send the reply synchronously */
 	memcpy(&req->rq_snd_buf, &rqstp->rq_res, sizeof(req->rq_snd_buf));
 	task =3D rpc_run_bc_task(req);
=2D	if (IS_ERR(task)) {
=2D		error =3D PTR_ERR(task);
=2D		goto out;
=2D	}
=2D
 	WARN_ON_ONCE(atomic_read(&task->tk_count) !=3D 1);
 	error =3D task->tk_status;
 	rpc_put_task(task);
=20
=2Dout:
 	dprintk("svc: %s(), error=3D%d\n", __func__, error);
 	return error;
 }
=2D-=20
2.12.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlj9dG8ACgkQOeye3VZi
gbmL7hAAqEVxfnBnZ79X5ff4wDHd/eiwVqCxfyof2mgK80fJxTt8fYwXM/nvRO8V
9WxDnd7GTdjfP/yqBh7Aowi4Akyto2chVdUYYSlX2tfOpJVAcxGG61FpqGwQ/7Qe
OhWzMbXzMFSqzwIgOdSKUopVEZTwk7uY5YvPkVlm2BMwTw/qDENDlv4JPn0wXefd
S2BE9JUQjf4/nIgxveIXX87db8tZDxRhDDUi2TfxId2ePGIl+7vAU9C/2GkR8E/p
SQC0TNiXL0t/NSiRojKWHACncIlDShKrOFj1Fw4hc8WH7P9QsqZ3e4RzEJYAzOyK
+t9Arp7QyWQEnfvbh1SJcUvyXAlOm5TEaRz16hPvOX1zK/mIffHVSm5ypqASwXjm
SKljxv1vqnrjELLNigF7B4EyWzGFc70Uq8uIowc7Ay4b1A5uQ95H9eC3XTk+P5I5
0R0lkRnj9LTWlR+jSxdqXHAJCMu3gldDF67r/2cgLmZWZg82BghU7FA9Z/Hm2rXM
Mil6zkinei4T4SU6DdyVyyAFLB71CqC+M/6jidtfxej2RwUjouqXScpiDmoM3jdR
tS5TyKNkX/jzyjJAXniP1ET7guBmrtzjbkCb2WnNpbMQAwir8XarsrBbo2rDWdmi
TFcs21VcS4pQcgAsTna2rRAMn0UKVVOgF0OSlTH8utoACcciJXU=
=Qbad
-----END PGP SIGNATURE-----
--=-=-=--
