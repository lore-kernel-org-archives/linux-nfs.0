From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 6/6] SUNRPC: Display some debugging information as text
	rather than numbers
Date: Wed, 21 May 2008 15:50:41 -0400
Message-ID: <20080521195041.GC6712@fieldses.org>
References: <20080521180231.3295.84997.stgit@ellison> <20080521181620.3295.2298.stgit@ellison>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:58256 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936661AbYEUTun (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 May 2008 15:50:43 -0400
In-Reply-To: <20080521181620.3295.2298.stgit@ellison>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 21, 2008 at 02:16:20PM -0400, Chuck Lever wrote:
> In rpc_show_tasks(), display the program name, version number, proced=
ure
> name and tk_action as human-readable variable-length text fields rath=
er
> than columnar numbers.
>=20
> Doing the symbol lookup here helps in cases where we have actual
> debugging output from a kernel log, but don't have access to the kern=
el
> image or RPC module that generated the output.
>=20
> Sample output:
>=20
>  -pid- flgs status -client- --rqstp- -timeout ---ops--
>   5608 0001    -11 eeb42690 f6d93710        0 f8fa1764 nfsv3 WRITE a:=
call_transmit_status q:none
>   5609 0001    -11 eeb42690 f6d937e0        0 f8fa1764 nfsv3 WRITE a:=
call_status q:xprt_sending
>   5610 0001    -11 eeb42690 f6d93230        0 f8fa1764 nfsv3 WRITE a:=
call_status q:xprt_sending
>   5611 0001    -11 eeb42690 f6d93300        0 f8fa1764 nfsv3 WRITE a:=
call_status q:xprt_sending
>   5612 0001    -11 eeb42690 f6d93090        0 f8fa1764 nfsv3 WRITE a:=
call_status q:xprt_sending
>   5613 0001    -11 eeb42690 f6d933d0        0 f8fa1764 nfsv3 WRITE a:=
call_status q:xprt_sending
>   5614 0001    -11 eeb42690 f6d93cc0        0 f8fa1764 nfsv3 WRITE a:=
call_status q:xprt_sending
>   5615 0001    -11 eeb42690 f6d93a50        0 f8fa1764 nfsv3 WRITE a:=
call_status q:xprt_sending
>   5616 0001    -11 eeb42690 f6d93640        0 f8fa1764 nfsv3 WRITE a:=
call_status q:xprt_sending
>   5617 0001    -11 eeb42690 f6d93b20        0 f8fa1764 nfsv3 WRITE a:=
call_status q:xprt_sending
>   5618 0001    -11 eeb42690 f6d93160        0 f8fa1764 nfsv3 WRITE a:=
call_status q:xprt_sending
>=20
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>=20
>  net/sunrpc/clnt.c |   29 ++++++++++++++++-------------
>  1 files changed, 16 insertions(+), 13 deletions(-)
>=20
>=20
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 68b08d4..878752c 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -25,6 +25,7 @@
> =20
>  #include <linux/module.h>
>  #include <linux/types.h>
> +#include <linux/kallsyms.h>
>  #include <linux/mm.h>
>  #include <linux/slab.h>
>  #include <linux/smp_lock.h>
> @@ -1527,29 +1528,31 @@ EXPORT_SYMBOL_GPL(rpc_call_null);
>  #ifdef RPC_DEBUG
>  static void rpc_show_header(void)
>  {
> -	printk(KERN_INFO "-pid- proc flgs status -client- -prog- --rqstp- "
> -		"-timeout -rpcwait -action- ---ops--\n");
> +	printk(KERN_INFO "-pid- flgs status -client- --rqstp- "
> +		"-timeout ---ops--\n");
>  }
> =20
>  static void rpc_show_task(const struct rpc_clnt *clnt,
>  			  const struct rpc_task *task)
>  {
>  	const char *rpc_waitq =3D "none";
> -	int proc =3D -1;
> -
> -	if (task->tk_msg.rpc_proc)
> -		proc =3D task->tk_msg.rpc_proc->p_proc;
> +	char *p, action[KSYM_SYMBOL_LEN];
> =20
>  	if (RPC_IS_QUEUED(task))
>  		rpc_waitq =3D rpc_qname(task->tk_waitqueue);
> =20
> -	printk(KERN_INFO "%5u %04d %04x %6d %8p %6d %8p %8ld %8s %8p %8p\n"=
,
> -		task->tk_pid, proc,
> -		task->tk_flags, task->tk_status,
> -		clnt, clnt->cl_prog,
> -		task->tk_rqstp, task->tk_timeout,
> -		rpc_waitq,
> -		task->tk_action, task->tk_ops);
> +	/* map tk_action pointer to a function name; then trim off
> +	 * the "+0x0 [sunrpc]" */
> +	sprint_symbol(action, (unsigned long)task->tk_action);
> +	p =3D strchr(action, '+');
> +	if (p)
> +		*p =3D '\0';
> +
> +	printk(KERN_INFO "%5u %04x %6d %8p %8p %8ld %8p %sv%u %s a:%s q:%s\=
n",
> +		task->tk_pid, task->tk_flags, task->tk_status,
> +		clnt, task->tk_rqstp, task->tk_timeout, task->tk_ops,
> +		clnt->cl_protname, clnt->cl_vers, rpc_proc_name(task),
> +		action, queue);

"net/sunrpc/clnt.c: In function =E2=80=98rpc_show_task=E2=80=99:
 net/sunrpc/clnt.c:1555: error: =E2=80=98queue=E2=80=99 undeclared (fir=
st use in this function)
 net/sunrpc/clnt.c:1555: error: (Each undeclared identifier is reported=
 only once
 net/sunrpc/clnt.c:1555: error: for each function it appears in.)"

Is that last "queue" supposed to be "rpc_waitq"???

--b.

>  }
> =20
>  void rpc_show_tasks(void)
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
