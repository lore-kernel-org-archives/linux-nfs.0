Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39733 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755456AbdKJBja (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Nov 2017 20:39:30 -0500
From: NeilBrown <neilb@suse.com>
To: Joshua Watt <jpewhacker@gmail.com>,
        Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Date: Fri, 10 Nov 2017 12:39:18 +1100
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        David Howells <dhowells@redhat.com>,
        Joshua Watt <JPEWhacker@gmail.com>
Subject: Re: [RFC 1/4] SUNRPC: Add flag to kill new tasks
In-Reply-To: <20171108145942.5127-2-JPEWhacker@gmail.com>
References: <CAJdd5GZ-EMj8f3RaV_WUdeZs6aWbEAeC6xX8BadMD-aOFL3_jA@mail.gmail.com> <20171108145942.5127-1-JPEWhacker@gmail.com> <20171108145942.5127-2-JPEWhacker@gmail.com>
Message-ID: <87o9oaewu1.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 08 2017, Joshua Watt wrote:

> The new flag to rpc_killall_tasks() causes new tasks that are killed
> after to call to be killed immediately instead of being executed. This
> will all clients (particularly NFS) to prevents these task from delaying
> shutdown of the RPC session longer than necessary.

I have trouble remembering to proof-read my commit messages too. :-)
(I count 3 typos).

>
> Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
> ---
>  fs/nfs/super.c               |  4 ++--
>  include/linux/sunrpc/clnt.h  |  1 +
>  include/linux/sunrpc/sched.h |  2 +-
>  net/sunrpc/clnt.c            | 13 ++++++++++---
>  net/sunrpc/sched.c           |  7 +++++++
>  5 files changed, 21 insertions(+), 6 deletions(-)
>
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 216f67d628b3..66fda2dcadd0 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -903,10 +903,10 @@ void nfs_umount_begin(struct super_block *sb)
>  	/* -EIO all pending I/O */
>  	rpc =3D server->client_acl;
>  	if (!IS_ERR(rpc))
> -		rpc_killall_tasks(rpc);
> +		rpc_killall_tasks(rpc, 0);
>  	rpc =3D server->client;
>  	if (!IS_ERR(rpc))
> -		rpc_killall_tasks(rpc);
> +		rpc_killall_tasks(rpc, 0);
>  }
>  EXPORT_SYMBOL_GPL(nfs_umount_begin);
>=20=20
> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> index 71c237e8240e..94f4e464de1b 100644
> --- a/include/linux/sunrpc/clnt.h
> +++ b/include/linux/sunrpc/clnt.h
> @@ -54,6 +54,7 @@ struct rpc_clnt {
>  				cl_noretranstimeo: 1,/* No retransmit timeouts */
>  				cl_autobind : 1,/* use getport() */
>  				cl_chatty   : 1;/* be verbose */
> +	bool			cl_kill_new_tasks;	/* Kill all new tasks */
>=20=20
>  	struct rpc_rtt *	cl_rtt;		/* RTO estimator data */
>  	const struct rpc_timeout *cl_timeout;	/* Timeout strategy */
> diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
> index d96e74e114c0..9b8bebaee0f4 100644
> --- a/include/linux/sunrpc/sched.h
> +++ b/include/linux/sunrpc/sched.h
> @@ -218,7 +218,7 @@ void		rpc_put_task_async(struct rpc_task *);
>  void		rpc_exit_task(struct rpc_task *);
>  void		rpc_exit(struct rpc_task *, int);
>  void		rpc_release_calldata(const struct rpc_call_ops *, void *);
> -void		rpc_killall_tasks(struct rpc_clnt *);
> +void		rpc_killall_tasks(struct rpc_clnt *clnt, int kill_new_tasks);
>  void		rpc_execute(struct rpc_task *);
>  void		rpc_init_priority_wait_queue(struct rpc_wait_queue *, const char *=
);
>  void		rpc_init_wait_queue(struct rpc_wait_queue *, const char *);
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index df4ecb042ebe..70005252b32f 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -814,14 +814,21 @@ EXPORT_SYMBOL_GPL(rpc_clnt_iterate_for_each_xprt);
>   * Kill all tasks for the given client.
>   * XXX: kill their descendants as well?
>   */
> -void rpc_killall_tasks(struct rpc_clnt *clnt)
> +void rpc_killall_tasks(struct rpc_clnt *clnt, int kill_new_tasks)
>  {
>  	struct rpc_task	*rovr;
>=20=20
> +	dprintk("RPC:       killing all tasks for client %p\n", clnt);
> +
> +	if (kill_new_tasks) {
> +		WRITE_ONCE(clnt->cl_kill_new_tasks, true);
> +
> +		/* Ensure the kill flag is set before checking the task list */
> +		smp_mb();
> +	}

I don't find this smp_mb() usage convincing.  It might be "right", but
to me it looks weird.
Partly, this is because there is a perfectly good spinlock that would
make the code obviously correct.

I would remove the short-circuit (which returns if list_empty()) and
always take the spinlock.  Then
   if (kill_new_tasks)
   	clnt->cl_kill_new_tasks =3D true;


In __rpc_execute() I would just have
  if (task->tk_client->cl_kill_new_tasks)
  	rpc_exit(task, -EIO);

As the task was added to the client list with the cl_lock spinlock
helds, there are no visibility issues to require a memory barrier.

Otherwise, the patch seems to make sense.

Thanks,
NeilBrown


>=20=20
>  	if (list_empty(&clnt->cl_tasks))
>  		return;
> -	dprintk("RPC:       killing all tasks for client %p\n", clnt);
>  	/*
>  	 * Spin lock all_tasks to prevent changes...
>  	 */
> @@ -854,7 +861,7 @@ void rpc_shutdown_client(struct rpc_clnt *clnt)
>  			rcu_dereference(clnt->cl_xprt)->servername);
>=20=20
>  	while (!list_empty(&clnt->cl_tasks)) {
> -		rpc_killall_tasks(clnt);
> +		rpc_killall_tasks(clnt, 0);
>  		wait_event_timeout(destroy_wait,
>  			list_empty(&clnt->cl_tasks), 1*HZ);
>  	}
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> index 0cc83839c13c..c9bf1ab9e941 100644
> --- a/net/sunrpc/sched.c
> +++ b/net/sunrpc/sched.c
> @@ -748,6 +748,13 @@ static void __rpc_execute(struct rpc_task *task)
>  	dprintk("RPC: %5u __rpc_execute flags=3D0x%x\n",
>  			task->tk_pid, task->tk_flags);
>=20=20
> +	/* Ensure the task is in the client task list before checking the kill
> +	 * flag
> +	 */
> +	smp_mb();
> +	if (READ_ONCE(task->tk_client->cl_kill_new_tasks))
> +		rpc_exit(task, -EIO);
> +
>  	WARN_ON_ONCE(RPC_IS_QUEUED(task));
>  	if (RPC_IS_QUEUED(task))
>  		return;
> --=20
> 2.13.6

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAloFA0gACgkQOeye3VZi
gblIEBAArI1CeTxusMIprd2Z1GH1YT0ljqbm2dJZF/DmiBvRPmoh+UKWTkyAjsEs
XPd2F4P4eNt2nbk/ZK02EfAXt8Nn0HFQDFgNaF2YtMGr3+HGRYb1XSrdtY9hcyTW
rKI3q+LwfHPrWYzN3pz1/AAOwLwhbDUQms9t50w3iHkm+fyQNHKNCbIgLUuRqYfn
bdVtJdHwnXYSGdVTl6mI9w9KLVMuX3DFeB8/ffN+bwZNpy6sezJPN7NxFjOgIE+6
C1RGJpC/w0U5znFcjpDyPN2/lpvwqkIZwdV2JJSrx5NSCWXLeK0nSAJg3DMW5FNj
Ic3cnG65PE7hkr/cFJ4RaQEj1DXT8BezyijK/4NhPMMve5+LsFGgOLKRzKcQK12H
xEUCb0Ybm306s54KfEw8hMUa5qCQQhbgK+ftgsGe0H9+/DsHLdkII7Gbvwm34K6j
aFH83sj+sCkNol7gozDN33nAlNdr79Y6Qqlr0ukxoBVK3dJeRsBzGjO9kDcigolH
lMM6Llfrhfrheyx19HuhIb/+j8LM0SxN6r2QoRno+vp/L6KjUyGxanCTX5xfjbmL
fuZGuoWOdwGizDHDrIgaR3G0KAyIQA5+Kuk/F6dJg8RPpSpak7x94t93eUxZbLuS
E1Kx2j7XSiTG0DmzVkO0IQmhiHVyewpTliClm1vyAIZkfPG7KYA=
=ZrMt
-----END PGP SIGNATURE-----
--=-=-=--
