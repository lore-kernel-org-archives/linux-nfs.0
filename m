From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 8/8] SUNRPC: Display symbolic function addresses in
	rpc_show_tasks
Date: Tue, 20 May 2008 17:11:32 -0400
Message-ID: <1211317892.26809.8.camel@localhost>
References: <20080520202108.3851.7464.stgit@ellison.1015granger.net>
	 <20080520203018.3851.21166.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45725 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758346AbYETVMr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 May 2008 17:12:47 -0400
In-Reply-To: <20080520203018.3851.21166.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-05-20 at 16:30 -0400, Chuck Lever wrote:
> For each running RPC task, rpc_show_tasks displays the hex address of=
 the
> call_foo function that the task is running.  To make debugging slight=
ly
> nicer, let's display the call_foo function name instead.
>=20
> Sample output:
>=20
>  -pid- flgs status -client- --rqstp- -timeout ---ops--
>  27915 0001      0 ee84a460 eedf00d0    60000 f8fa677c nfs3 COMMIT ac=
t:status wq:xprt_pending
>  27918 0080      0 ee84a460 eedf0000    60000 f8d527a8 nfs3 SETATTR a=
ct:status wq:xprt_pending
>=20
>  -pid- flgs status -client- --rqstp- -timeout ---ops--
>  60859 0001      0 ee84a460 eedf00d0        0 f8fa66c8 nfs3 READ act:=
status
>  60860 0080      0 ee84a460 eedf0000        0 f8d527a8 nfs3 GETATTR a=
ct:status
>=20
>=20
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>=20
>  include/linux/sunrpc/sched.h |    1 +
>  net/sunrpc/clnt.c            |   52 ++++++++++++++++++++++++++++++++=
+++++++---
>  net/sunrpc/sched.c           |    2 +-
>  3 files changed, 50 insertions(+), 5 deletions(-)
>=20
>=20
> diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sche=
d.h
> index d1a5c8c..108342e 100644
> --- a/include/linux/sunrpc/sched.h
> +++ b/include/linux/sunrpc/sched.h
> @@ -212,6 +212,7 @@ struct rpc_wait_queue {
>  struct rpc_task *rpc_new_task(const struct rpc_task_setup *);
>  struct rpc_task *rpc_run_task(const struct rpc_task_setup *);
>  void		rpc_put_task(struct rpc_task *);
> +void		rpc_prepare_task(struct rpc_task *);
>  void		rpc_exit_task(struct rpc_task *);
>  void		rpc_release_calldata(const struct rpc_call_ops *, void *);
>  void		rpc_killall_tasks(struct rpc_clnt *);
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index c33d727..ec9c072 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1510,24 +1510,68 @@ struct rpc_task *rpc_call_null(struct rpc_cln=
t *clnt, struct rpc_cred *cred, int
>  EXPORT_SYMBOL_GPL(rpc_call_null);
> =20
>  #ifdef RPC_DEBUG
> +/*
> + * To make it easier to tell what action each running RPC task
> + * is executing, use a table to map the content of tk_action to
> + * a human-readable name.  This uses a little extra memory, but
> + * causes no additional run-time overhead per RPC request.
> + */
> +typedef void   (*rpc_task_action)(struct rpc_task *);
> +
> +static struct {
> +	rpc_task_action		action;
> +	const char		*name;
> +} rpc_action_table[] =3D {
> +	{ rpc_prepare_task,		"prepare"		},
> +	{ call_start,			"start"			},
> +	{ call_reserve,			"reserve"		},
> +	{ call_reserveresult,		"reserveresult"		},
> +	{ call_allocate,		"allocate"		},
> +	{ call_bind,			"bind"			},
> +	{ call_bind_status,		"bindstatus"		},
> +	{ call_connect,			"connect"		},
> +	{ call_connect_status,		"connectstatus"		},
> +	{ call_transmit,		"transmit"		},
> +	{ call_transmit_status,		"transmitstatus"	},
> +	{ call_status,			"status"		},
> +	{ call_timeout,			"timeout"		},
> +	{ call_decode,			"decode"		},
> +	{ call_refresh,			"refresh"		},
> +	{ call_refreshresult,		"refreshresult"		},
> +	{ rpc_exit_task,		"exit"			},
> +	{ NULL,				"null"			},
> +};
>
> +
> +static const char *rpc_show_action(rpc_task_action action)
> +{
> +	unsigned int i;
> +
> +	for (i =3D 0; i <=3D ARRAY_SIZE(rpc_action_table); i++)
> +		if (rpc_action_table[i].action =3D=3D action)
> +			return rpc_action_table[i].name;
> +
> +	return "unknown";
> +}

=EF=BB=BF
NACK. Maintaining tables like the above in the long run is a nightmare.
What's more, by eliminating the printout of the actual pointer you are
potentially replacing useful information that could otherwise easily be
looked up using /proc/kallsyms with "unknown".

The above translation could easily be done using a simple script in
userspace instead.


--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
