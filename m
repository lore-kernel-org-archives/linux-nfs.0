From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH 019 of 19] knfsd: Register all RPC programs with
	portmapper by default
Date: Fri, 1 Sep 2006 11:31:25 -0400
Message-ID: <76bd70e30609010831m9e80cfav514d60718d35e7d5@mail.gmail.com>
References: <20060901141639.27206.patches@notabene>
	<1060901043948.27677@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, Olaf Kirch <okir@suse.de>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GJAzT-0004sG-Q1
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 08:31:31 -0700
Received: from wr-out-0506.google.com ([64.233.184.236])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GJAzU-000736-3O
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 08:31:32 -0700
Received: by wr-out-0506.google.com with SMTP id 57so386081wri
	for <nfs@lists.sourceforge.net>; Fri, 01 Sep 2006 08:31:25 -0700 (PDT)
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1060901043948.27677@suse.de>
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

On 9/1/06, NeilBrown <neilb@suse.de> wrote:
>
> From: Olaf Kirch <okir@suse.de>
>
>   The NFSACL patches introduced support for multiple RPC services
>   listening on the same transport. However, only the first of these
>   services was registered with portmapper. This was perfectly fine
>   for nfsacl, as you traditionally do not want these to show up in a
>   portmapper listing.
>
>   The patch below changes the default behavior to always register
>   all services listening on a given transport, but retains the
>   old behavior for nfsacl services.

I don't like this.  The idea that multiple RPC services are listening
on the same port is a total hack.  What other service might use this
besides NFSACL?

Does the reference implementation (Solaris) behave this way?

> Signed-off-by: Olaf Kirch <okir@suse.de>
> Signed-off-by: Neil Brown <neilb@suse.de>
>
> ### Diffstat output
>  ./fs/nfsd/nfs2acl.c          |    1 +
>  ./fs/nfsd/nfs3acl.c          |    1 +
>  ./include/linux/sunrpc/svc.h |    3 +++
>  ./net/sunrpc/svc.c           |   37 +++++++++++++++++++++++--------------
>  4 files changed, 28 insertions(+), 14 deletions(-)
>
> diff .prev/fs/nfsd/nfs2acl.c ./fs/nfsd/nfs2acl.c
> --- .prev/fs/nfsd/nfs2acl.c     2006-09-01 12:22:10.000000000 +1000
> +++ ./fs/nfsd/nfs2acl.c 2006-09-01 12:22:11.000000000 +1000
> @@ -333,4 +333,5 @@ struct svc_version  nfsd_acl_version2 = {
>                 .vs_proc        = nfsd_acl_procedures2,
>                 .vs_dispatch    = nfsd_dispatch,
>                 .vs_xdrsize     = NFS3_SVC_XDRSIZE,
> +               .vs_hidden      = 1,
>  };
>
> diff .prev/fs/nfsd/nfs3acl.c ./fs/nfsd/nfs3acl.c
> --- .prev/fs/nfsd/nfs3acl.c     2006-09-01 12:22:10.000000000 +1000
> +++ ./fs/nfsd/nfs3acl.c 2006-09-01 12:22:11.000000000 +1000
> @@ -263,5 +263,6 @@ struct svc_version  nfsd_acl_version3 = {
>                 .vs_proc        = nfsd_acl_procedures3,
>                 .vs_dispatch    = nfsd_dispatch,
>                 .vs_xdrsize     = NFS3_SVC_XDRSIZE,
> +               .vs_hidden      = 1,
>  };
>
>
> diff .prev/include/linux/sunrpc/svc.h ./include/linux/sunrpc/svc.h
> --- .prev/include/linux/sunrpc/svc.h    2006-09-01 12:22:10.000000000 +1000
> +++ ./include/linux/sunrpc/svc.h        2006-09-01 12:22:11.000000000 +1000
> @@ -304,6 +304,9 @@ struct svc_version {
>         struct svc_procedure *  vs_proc;        /* per-procedure info */
>         u32                     vs_xdrsize;     /* xdrsize needed for this version */
>
> +       unsigned int            vs_hidden : 1;  /* Don't register with portmapper.
> +                                                * Only used for nfsacl so far. */
> +
>         /* Override dispatch function (e.g. when caching replies).
>          * A return value of 0 means drop the request.
>          * vs_dispatch == NULL means use default dispatcher.
>
> diff .prev/net/sunrpc/svc.c ./net/sunrpc/svc.c
> --- .prev/net/sunrpc/svc.c      2006-09-01 12:22:11.000000000 +1000
> +++ ./net/sunrpc/svc.c  2006-09-01 12:22:11.000000000 +1000
> @@ -644,23 +644,32 @@ svc_register(struct svc_serv *serv, int
>         unsigned long           flags;
>         int                     i, error = 0, dummy;
>
> -       progp = serv->sv_program;
> -
> -       dprintk("RPC: svc_register(%s, %s, %d)\n",
> -               progp->pg_name, proto == IPPROTO_UDP? "udp" : "tcp", port);
> -
>         if (!port)
>                 clear_thread_flag(TIF_SIGPENDING);
>
> -       for (i = 0; i < progp->pg_nvers; i++) {
> -               if (progp->pg_vers[i] == NULL)
> -                       continue;
> -               error = rpc_register(progp->pg_prog, i, proto, port, &dummy);
> -               if (error < 0)
> -                       break;
> -               if (port && !dummy) {
> -                       error = -EACCES;
> -                       break;
> +       for (progp = serv->sv_program; progp; progp = progp->pg_next) {
> +               for (i = 0; i < progp->pg_nvers; i++) {
> +                       if (progp->pg_vers[i] == NULL)
> +                               continue;
> +
> +                       dprintk("RPC: svc_register(%s, %s, %d, %d)%s\n",
> +                                       progp->pg_name,
> +                                       proto == IPPROTO_UDP?  "udp" : "tcp",
> +                                       port,
> +                                       i,
> +                                       progp->pg_vers[i]->vs_hidden?
> +                                               " (but not telling portmap)" : "");
> +
> +                       if (progp->pg_vers[i]->vs_hidden)
> +                               continue;
> +
> +                       error = rpc_register(progp->pg_prog, i, proto, port, &dummy);
> +                       if (error < 0)
> +                               break;
> +                       if (port && !dummy) {
> +                               error = -EACCES;
> +                               break;
> +                       }
>                 }
>         }
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
