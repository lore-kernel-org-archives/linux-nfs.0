Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44555 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752390AbdLEW7y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Dec 2017 17:59:54 -0500
From: NeilBrown <neilb@suse.com>
To: Joshua Watt <jpewhacker@gmail.com>,
        Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>
Date: Wed, 06 Dec 2017 09:59:45 +1100
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        David Howells <dhowells@redhat.com>,
        Joshua Watt <JPEWhacker@gmail.com>
Subject: Re: [RFC v4 1/9] SUNRPC: Add flag to kill new tasks
In-Reply-To: <20171117174552.18722-2-JPEWhacker@gmail.com>
References: <20171117174552.18722-1-JPEWhacker@gmail.com> <20171117174552.18722-2-JPEWhacker@gmail.com>
Message-ID: <87o9ncsrvi.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 17 2017, Joshua Watt wrote:

> The flag causes any new tasks that are queued to exit immediately with
> -EIO instead of executing. This will allow clients (particularly NFS) to
> prevents these task from delaying shutdown of the RPC session longer
> than necessary.
>
> Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
> ---
>  include/linux/sunrpc/clnt.h | 1 +
>  net/sunrpc/clnt.c           | 5 ++---
>  net/sunrpc/sched.c          | 3 +++
>  3 files changed, 6 insertions(+), 3 deletions(-)
>
> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> index 71c237e8240e..d36dc529fdf0 100644
> --- a/include/linux/sunrpc/clnt.h
> +++ b/include/linux/sunrpc/clnt.h
> @@ -54,6 +54,7 @@ struct rpc_clnt {
>  				cl_noretranstimeo: 1,/* No retransmit timeouts */
>  				cl_autobind : 1,/* use getport() */
>  				cl_chatty   : 1;/* be verbose */
> +	atomic_t		cl_kill_new_tasks;	/* Kill all new tasks */

It looks a little weird that this is an atomic_t.
Looking further ahead, it seems that it is a counter of threads that
have request new tasks be killed.
It might help to make that clear, at least in a comment.

>=20=20
>  	struct rpc_rtt *	cl_rtt;		/* RTO estimator data */
>  	const struct rpc_timeout *cl_timeout;	/* Timeout strategy */
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index df4ecb042ebe..d5eedabf0b4d 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -626,6 +626,8 @@ static struct rpc_clnt *__rpc_clone_client(struct rpc=
_create_args *args,
>  	new->cl_noretranstimeo =3D clnt->cl_noretranstimeo;
>  	new->cl_discrtry =3D clnt->cl_discrtry;
>  	new->cl_chatty =3D clnt->cl_chatty;
> +	atomic_set(&new->cl_kill_new_tasks,
> +		   atomic_read(&clnt->cl_kill_new_tasks));

However ... as it is a counter, it isn't clear that copying the counter
makes sense, and the new counter will never get decremented.
Maybe __rpc_clone_client() should fail if ->cl_kill_new_tasks > 0 ??

Thanks,
NeilBrown


>  	return new;
>=20=20
>  out_err:
> @@ -818,9 +820,6 @@ void rpc_killall_tasks(struct rpc_clnt *clnt)
>  {
>  	struct rpc_task	*rovr;
>=20=20
> -
> -	if (list_empty(&clnt->cl_tasks))
> -		return;
>  	dprintk("RPC:       killing all tasks for client %p\n", clnt);
>  	/*
>  	 * Spin lock all_tasks to prevent changes...
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> index 0cc83839c13c..e70034e19ccd 100644
> --- a/net/sunrpc/sched.c
> +++ b/net/sunrpc/sched.c
> @@ -748,6 +748,9 @@ static void __rpc_execute(struct rpc_task *task)
>  	dprintk("RPC: %5u __rpc_execute flags=3D0x%x\n",
>  			task->tk_pid, task->tk_flags);
>=20=20
> +	if (atomic_read(&task->tk_client->cl_kill_new_tasks))
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

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlonJOEACgkQOeye3VZi
gblR+A//STf7z/Ehri0zE6O0rX2EBjBAhvqART6ZQAP5e7TK3VvZ5arYJ2NRGA8M
AmcUFADRiSMo21dG0AhKSO1qvxH0If+zUSk5kl/DB56ijPp+K2W5Wuhar/xT//z8
2w1qX9Vxk40u2STsKRNQZ5iVEkmco8sOuBgWCQOwg8P04t/CKljehI6UFZebbXEl
1NLQNdD3e5qfjAL7F62tRxdN5NlhQ6xfbaW67mj/A9Uk40QzG0iyuTLe67MB/5dM
qy0Zx+nPRvOYua/kvgU9gaBBo0Q+4W3ImZw4QURuZw5rVpjVYz4sUOZWhE61yC8t
8RzJQKi71f2FnxaLST29PDplZWlXYHXv2wUbJJoyrnXNurjOHNHED3SAdD4CMYWE
XM8Q02AeKz/UHzoacgkiN3lIPs0DSUjYqehFk0IefEJu4zJIohihWIAfTRAVKelp
QLip0gg4soyTtVtlX0QjhDaxOZPv8xpylfj7aOH/odhRLO+4S8GcuKsOIRRPLoIW
s9OThmIc6hpWGMMEGq8AO5mTBz1beqcBX0DKWrC39SpOlVtyTUoEgviiNEi1L8aU
6OQtGTQqD2rYgmphu2SCLRDRij/bhExT1CEJcGQEAZ67VBLr61dIOjjqpebl4Dir
v5yMVrcbECe/Qc7uRpABtq4oWQeitG4s5unOBeGWf2goIoJBSgE=
=LVhc
-----END PGP SIGNATURE-----
--=-=-=--
