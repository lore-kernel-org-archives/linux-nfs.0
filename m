From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH 001 of 4] Copy intr and soft flags to portmap-bind
	client
Date: Tue, 24 Oct 2006 16:05:03 -0700
Message-ID: <76bd70e30610241605x13ae0bamdd306aee2f67d4e1@mail.gmail.com>
References: <20061024122646.4426.patches@notabene> <1061024024851.4734@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, Chuck Lever <chuck.lever@oracle.com>,
	nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GcVKS-0002Qw-Fe
	for nfs@lists.sourceforge.net; Tue, 24 Oct 2006 16:05:04 -0700
Received: from ug-out-1314.google.com ([66.249.92.175])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GcVKS-0003IA-S4
	for nfs@lists.sourceforge.net; Tue, 24 Oct 2006 16:05:05 -0700
Received: by ug-out-1314.google.com with SMTP id p27so1480377ugc
	for <nfs@lists.sourceforge.net>; Tue, 24 Oct 2006 16:05:03 -0700 (PDT)
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1061024024851.4734@suse.de>
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

Looking at this has forced me to actually think about it  ;-)

Since portmapper is always a child task, I think it is safe and
reasonable to use a "hard,intr" RPC client all the time.  The parent
task will timeout automatically if it is a soft mount, right?  The RPC
client should terminate the child if the parent dies.

In any event, I think the NONPRIVPORT and NO_PING flags should be
managed entirely within pmap_create().  No need to clutter the callers
with that.

On 10/23/06, NeilBrown <neilb@suse.de> wrote:
>
> When an RPC request needs to make a subordinate RPC request to portmap
> to find the port number to communicate with, the 'soft' and 'intr'
> flags should be copied from the original request to the subordinate request
> to ensure consistent handling.
>
> Currently the pmap client defaults to soft,nointr, so while it is
> certain to timeout, it could still be 30 seconds without being
> interruptible.
>
> Note that copying the 'hard' flag down is not essential as if the pmap
> request aborts, the parent request - being hard - will retry it
> indefinitely.  However copying it is more obviously right.
>
> Signed-off-by: Neil Brown <neilb@suse.de>
>
> ### Diffstat output
>  ./net/sunrpc/pmap_clnt.c |   22 +++++++++++++++-------
>  1 file changed, 15 insertions(+), 7 deletions(-)
>
> diff .prev/net/sunrpc/pmap_clnt.c ./net/sunrpc/pmap_clnt.c
> --- .prev/net/sunrpc/pmap_clnt.c        2006-10-24 09:23:13.000000000 +1000
> +++ ./net/sunrpc/pmap_clnt.c    2006-10-24 09:33:08.000000000 +1000
> @@ -34,7 +34,8 @@ struct portmap_args {
>  };
>
>  static struct rpc_procinfo     pmap_procedures[];
> -static struct rpc_clnt *       pmap_create(char *, struct sockaddr_in *, int, int);
> +static struct rpc_clnt *       pmap_create(char *, struct sockaddr_in *,
> +                                           int, unsigned long);
>  static void                    pmap_getport_done(struct rpc_task *, void *);
>  static struct rpc_program      pmap_program;
>
> @@ -93,6 +94,7 @@ void rpc_getport(struct rpc_task *task)
>         struct rpc_clnt *pmap_clnt;
>         struct rpc_task *child;
>         int status;
> +       unsigned long create_flags;
>
>         dprintk("RPC: %4d rpc_getport(%s, %u, %u, %d)\n",
>                         task->tk_pid, clnt->cl_server,
> @@ -125,7 +127,13 @@ void rpc_getport(struct rpc_task *task)
>         map->pm_xprt = xprt_get(xprt);
>
>         rpc_peeraddr(clnt, (struct sockaddr *) &addr, sizeof(addr));
> -       pmap_clnt = pmap_create(clnt->cl_server, &addr, map->pm_prot, 0);
> +       create_flags = RPC_CLNT_CREATE_NONPRIVPORT;
> +       if ( ! RPC_IS_SOFT(task))
> +               create_flags |= RPC_CLNT_CREATE_HARDRTRY;
> +       if ( ! RPC_TASK_UNINTERRUPTIBLE(task))
> +               create_flags |= RPC_CLNT_CREATE_INTR;
> +       pmap_clnt = pmap_create(clnt->cl_server, &addr, map->pm_prot,
> +                               create_flags);
>         status = PTR_ERR(pmap_clnt);
>         if (IS_ERR(pmap_clnt))
>                 goto bailout;
> @@ -178,7 +186,7 @@ int rpc_getport_external(struct sockaddr
>                         NIPQUAD(sin->sin_addr.s_addr), prog, vers, prot);
>
>         sprintf(hostname, "%u.%u.%u.%u", NIPQUAD(sin->sin_addr.s_addr));
> -       pmap_clnt = pmap_create(hostname, sin, prot, 0);
> +       pmap_clnt = pmap_create(hostname, sin, prot, RPC_CLNT_CREATE_NONPRIVPORT);
>         if (IS_ERR(pmap_clnt))
>                 return PTR_ERR(pmap_clnt);
>
> @@ -257,7 +265,7 @@ int rpc_register(u32 prog, u32 vers, int
>         dprintk("RPC: registering (%u, %u, %d, %u) with portmapper.\n",
>                         prog, vers, prot, port);
>
> -       pmap_clnt = pmap_create("localhost", &sin, IPPROTO_UDP, 1);
> +       pmap_clnt = pmap_create("localhost", &sin, IPPROTO_UDP, 0);
>         if (IS_ERR(pmap_clnt)) {
>                 error = PTR_ERR(pmap_clnt);
>                 dprintk("RPC: couldn't create pmap client. Error = %d\n", error);
> @@ -277,7 +285,8 @@ int rpc_register(u32 prog, u32 vers, int
>         return error;
>  }
>
> -static struct rpc_clnt *pmap_create(char *hostname, struct sockaddr_in *srvaddr, int proto, int privileged)
> +static struct rpc_clnt *pmap_create(char *hostname, struct sockaddr_in *srvaddr,
> +                                   int proto, unsigned long create_flags)
>  {
>         struct rpc_create_args args = {
>                 .protocol       = proto,
> @@ -292,8 +301,7 @@ static struct rpc_clnt *pmap_create(char
>         };
>
>         srvaddr->sin_port = htons(RPC_PMAP_PORT);
> -       if (!privileged)
> -               args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
> +       args.flags |= create_flags;
>         return rpc_create(&args);
>  }
>
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
