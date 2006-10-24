From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH 003 of 4] Make RPC 'ping' requests fail more
	quickly.
Date: Tue, 24 Oct 2006 16:37:22 -0700
Message-ID: <76bd70e30610241637p52268ecctb5957932289fef40@mail.gmail.com>
References: <20061024122646.4426.patches@notabene> <1061024024903.4760@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, Chuck Lever <chuck.lever@oracle.com>,
	nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GcVpm-0005MJ-Cv
	for nfs@lists.sourceforge.net; Tue, 24 Oct 2006 16:37:26 -0700
Received: from ug-out-1314.google.com ([66.249.92.170])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GcVpm-0002yl-Rq
	for nfs@lists.sourceforge.net; Tue, 24 Oct 2006 16:37:27 -0700
Received: by ug-out-1314.google.com with SMTP id p27so1485930ugc
	for <nfs@lists.sourceforge.net>; Tue, 24 Oct 2006 16:37:22 -0700 (PDT)
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1061024024903.4760@suse.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On 10/23/06, NeilBrown <neilb@suse.de> wrote:
>
> Sometimes when an RPC client is created, an initial 'PING' is sent to
> the RPC/NULL procedure to make sure the server is running.
> This is always done as a 'soft' call so a major timeout will be fatal.
>
> We change semantics so that if portmap reports that the service does
> not exist, or if a ECONNREFUSED error is returned we abort early
> rather than persist for the full timeout.
>
> The core mechanism is a new flag RPC_TASK_ACCEPT_NO which tell the rpc
> client to accept a 'no' answer rather than retrying.

This doesn't seem like a per task thing.... It maybe should be a
client option, like AUTOBIND is.  RPC_CREATE_BIND_ONE_SHOT, perhaps?

Is the local statd case the only one where an immediate timeout is desirable?

> This patch also causes lockd clients to *not* do the initial 'ping'
> otherwise a lock request could fail due to a missing server, even on a
> hard mount.

It's a small change, but maybe it's worth splitting this into a
separate patch.  This seems a worthy change, but the other stuff I
still don't quite grok.


> ### Diffstat output
>  ./fs/lockd/host.c              |    1 +
>  ./include/linux/sunrpc/sched.h |    4 ++++
>  ./net/sunrpc/clnt.c            |   14 +++++++++++---
>  ./net/sunrpc/pmap_clnt.c       |    4 +++-
>  4 files changed, 19 insertions(+), 4 deletions(-)
>
> diff .prev/fs/lockd/host.c ./fs/lockd/host.c
> --- .prev/fs/lockd/host.c       2006-10-24 10:09:41.000000000 +1000
> +++ ./fs/lockd/host.c   2006-10-24 11:48:05.000000000 +1000
> @@ -236,6 +236,7 @@ nlm_bind_host(struct nlm_host *host)
>                         .version        = host->h_version,
>                         .authflavor     = RPC_AUTH_UNIX,
>                         .flags          = (RPC_CLNT_CREATE_HARDRTRY |
> +                                          RPC_CLNT_CREATE_NOPING |
>                                            RPC_CLNT_CREATE_AUTOBIND),
>                 };
>
>
> diff .prev/include/linux/sunrpc/sched.h ./include/linux/sunrpc/sched.h
> --- .prev/include/linux/sunrpc/sched.h  2006-10-24 11:35:21.000000000 +1000
> +++ ./include/linux/sunrpc/sched.h      2006-10-24 11:46:25.000000000 +1000
> @@ -133,6 +133,10 @@ struct rpc_call_ops {
>  #define RPC_TASK_KILLED                0x0100          /* task was killed */
>  #define RPC_TASK_SOFT          0x0200          /* Use soft timeouts */
>  #define RPC_TASK_NOINTR                0x0400          /* uninterruptible task */
> +#define RPC_TASK_ACCEPT_NO     0x0800          /* Accept a 'no' such as
> +                                                * -ECONNREFUSED or '0' from
> +                                                * portmap, to be reliable.
> +                                                */
>
>  #define RPC_IS_ASYNC(t)                ((t)->tk_flags & RPC_TASK_ASYNC)
>  #define RPC_IS_SWAPPER(t)      ((t)->tk_flags & RPC_TASK_SWAPPER)
>
> diff .prev/net/sunrpc/clnt.c ./net/sunrpc/clnt.c
> --- .prev/net/sunrpc/clnt.c     2006-10-24 09:43:48.000000000 +1000
> +++ ./net/sunrpc/clnt.c 2006-10-24 11:45:54.000000000 +1000
> @@ -221,7 +221,7 @@ struct rpc_clnt *rpc_create(struct rpc_c
>                 return clnt;
>
>         if (!(args->flags & RPC_CLNT_CREATE_NOPING)) {
> -               int tskflags = RPC_TASK_SOFT;
> +               int tskflags = RPC_TASK_SOFT | RPC_TASK_ACCEPT_NO;
>                 int err;
>                 if ( ! (args->flags & RPC_CLNT_CREATE_INTR))
>                         tskflags |= RPC_TASK_NOINTR;
> @@ -868,6 +868,8 @@ call_bind_status(struct rpc_task *task)
>         case -EACCES:
>                 dprintk("RPC: %4d remote rpcbind: RPC program/version unavailable\n",
>                                 task->tk_pid);
> +               if (task->tk_flags & RPC_TASK_ACCEPT_NO)
> +                       break;
>                 rpc_delay(task, 3*HZ);
>                 goto retry_timeout;
>         case -ETIMEDOUT:
> @@ -941,6 +943,8 @@ call_connect_status(struct rpc_task *tas
>         switch (status) {
>         case -ENOTCONN:
>         case -EAGAIN:
> +               if (task->tk_flags & RPC_TASK_ACCEPT_NO)
> +                       break;
>                 task->tk_action = call_bind;
>                 if (!RPC_IS_SOFT(task))
>                         return;
> @@ -1044,8 +1048,12 @@ call_status(struct rpc_task *task)
>                 break;
>         case -ECONNREFUSED:
>         case -ENOTCONN:
> -               rpc_force_rebind(clnt);
> -               task->tk_action = call_bind;
> +               if (task->tk_flags & RPC_TASK_ACCEPT_NO)
> +                       rpc_exit(task, status);
> +               else {
> +                       rpc_force_rebind(clnt);
> +                       task->tk_action = call_bind;
> +               }
>                 break;
>         case -EAGAIN:
>                 task->tk_action = call_transmit;
>
> diff .prev/net/sunrpc/pmap_clnt.c ./net/sunrpc/pmap_clnt.c
> --- .prev/net/sunrpc/pmap_clnt.c        2006-10-24 09:33:08.000000000 +1000
> +++ ./net/sunrpc/pmap_clnt.c    2006-10-24 11:51:32.000000000 +1000
> @@ -139,7 +139,9 @@ void rpc_getport(struct rpc_task *task)
>                 goto bailout;
>
>         status = -EIO;
> -       child = rpc_run_task(pmap_clnt, RPC_TASK_ASYNC, &pmap_getport_ops, map);
> +       child = rpc_run_task(pmap_clnt,
> +                            RPC_TASK_ASYNC | (task->tk_flags & RPC_TASK_ACCEPT_NO),
> +                            &pmap_getport_ops, map);
>         if (IS_ERR(child))
>                 goto bailout;
>         rpc_release_task(child);
>
> -------------------------------------------------------------------------
> Using Tomcat but need to do more? Need to support web services, security?
> Get stuff done quickly with pre-integrated technology to make your job easier
> Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
> http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
