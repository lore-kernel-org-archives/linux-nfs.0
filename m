From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH 002 of 4] Make the initial RPC PING interruptible.
Date: Tue, 24 Oct 2006 16:19:28 -0700
Message-ID: <76bd70e30610241619m545c5a33k4ee4b156464ef41d@mail.gmail.com>
References: <20061024122646.4426.patches@notabene> <1061024024857.4748@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, Chuck Lever <chuck.lever@oracle.com>,
	nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GcVYU-0003hh-9C
	for nfs@lists.sourceforge.net; Tue, 24 Oct 2006 16:19:34 -0700
Received: from ug-out-1314.google.com ([66.249.92.168])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GcVYV-0005xp-0G
	for nfs@lists.sourceforge.net; Tue, 24 Oct 2006 16:19:35 -0700
Received: by ug-out-1314.google.com with SMTP id p27so1483130ugc
	for <nfs@lists.sourceforge.net>; Tue, 24 Oct 2006 16:19:28 -0700 (PDT)
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1061024024857.4748@suse.de>
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

What's the harm in always using SOFT|INTR for doing pings?

I would think this would be a bit cleaner if you just eliminated the
"flags" parameter of rpc_ping() and calculated the correct task flags
inside rpc_ping().

On 10/23/06, NeilBrown <neilb@suse.de> wrote:
>
> If an RPC client is created with CREATE_INTR and not CREATE_NOPING,
> then the ping should be interruptible.  With tcp the PING can take 30
> seconds to time out and not being able to interrupt that can be
> frustrating.
>
> Signed-off-by: Neil Brown <neilb@suse.de>
>
> ### Diffstat output
>  ./net/sunrpc/clnt.c |   10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
>
> diff .prev/net/sunrpc/clnt.c ./net/sunrpc/clnt.c
> --- .prev/net/sunrpc/clnt.c     2006-10-24 09:41:49.000000000 +1000
> +++ ./net/sunrpc/clnt.c 2006-10-24 09:43:48.000000000 +1000
> @@ -221,7 +221,15 @@ struct rpc_clnt *rpc_create(struct rpc_c
>                 return clnt;
>
>         if (!(args->flags & RPC_CLNT_CREATE_NOPING)) {
> -               int err = rpc_ping(clnt, RPC_TASK_SOFT|RPC_TASK_NOINTR);
> +               int tskflags = RPC_TASK_SOFT;
> +               int err;
> +               if ( ! (args->flags & RPC_CLNT_CREATE_INTR))
> +                       tskflags |= RPC_TASK_NOINTR;
> +               /* Note: we keep task_soft even if RPC_CLNT_CREATE_HARDRTRY
> +                * is set.  The whole point of the PING is to check that the
> +                * server is there *now*
> +                */
> +               err = rpc_ping(clnt, tskflags);
>                 if (err != 0) {
>                         rpc_shutdown_client(clnt);
>                         return ERR_PTR(err);
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
