From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH 4/9] SUNRPC: Move TCP receive state variables into
	private data structure
Date: Wed, 18 Oct 2006 16:36:29 -0400
Message-ID: <76bd70e30610181336o2d1c3fa2m819b1cf42f074368@mail.gmail.com>
References: <20061012211247.8734.23147.stgit@ingres.dsl.sfldmi.ameritech.net>
	<20061012211512.8734.17617.stgit@ingres.dsl.sfldmi.ameritech.net>
	<1161203440.6095.133.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GaI9X-0004Wz-60
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 13:36:39 -0700
Received: from ug-out-1314.google.com ([66.249.92.171])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GaI9V-0000Fj-Lx
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 13:36:40 -0700
Received: by ug-out-1314.google.com with SMTP id p27so262650ugc
	for <nfs@lists.sourceforge.net>; Wed, 18 Oct 2006 13:36:30 -0700 (PDT)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <1161203440.6095.133.camel@lade.trondhjem.org>
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

Hi Trond-

On 10/18/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Thu, 2006-10-12 at 17:15 -0400, Chuck Lever wrote:
> > Move the TCP receive state variables from the generic rpc_xprt structure to
> > a private structure maintained inside net/sunrpc/xprtsock.c.
> >
> > Also rename a function/variable pair to refer to RPC fragment headers
> > instead of record markers, to be consistent with types defined in
> > sunrpc/*.h.
> >
> > Test plan:
> > Connectathon with NFS over TCP.
> >
> > Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> > ---
> >
> >  include/linux/sunrpc/xprt.h |   14 ----
> >  net/sunrpc/xprtsock.c       |  159 +++++++++++++++++++++++++------------------
> >  2 files changed, 91 insertions(+), 82 deletions(-)
> >
> > diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> > index 4c074a7..3ff8230 100644
> > --- a/include/linux/sunrpc/xprt.h
> > +++ b/include/linux/sunrpc/xprt.h
> > @@ -158,15 +158,6 @@ struct rpc_xprt {
> >                               resvport   : 1; /* use a reserved port */
> >
> >       /*
> > -      * State of TCP reply receive stuff
> > -      */
> > -     __be32                  tcp_recm,       /* Fragment header */
> > -                             tcp_xid;        /* Current XID */
> > -     u32                     tcp_reclen,     /* fragment length */
> > -                             tcp_offset;     /* fragment offset */
> > -     unsigned long           tcp_copied,     /* copied to request */
> > -                             tcp_flags;
> > -     /*
> >        * Connection of transports
> >        */
> >       unsigned long           connect_timeout,
> > @@ -212,11 +203,6 @@ struct rpc_xprt {
> >       char *                  address_strings[RPC_DISPLAY_MAX];
> >  };
> >
> > -#define XPRT_LAST_FRAG               (1 << 0)
> > -#define XPRT_COPY_RECM               (1 << 1)
> > -#define XPRT_COPY_XID                (1 << 2)
> > -#define XPRT_COPY_DATA               (1 << 3)
> > -
> >  #ifdef __KERNEL__
> >
> >  /*
> > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > index 79088e8..363b2fc 100644
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -133,8 +133,28 @@ struct xs_xprt {
> >        */
> >       struct socket *         sock;
> >       struct sock *           inet;
> > +
> > +     /*
> > +      * State of TCP reply receive
> > +      */
> > +     __be32                  tcp_fraghdr,
> > +                             tcp_xid;
> > +
> > +     u32                     tcp_offset,
> > +                             tcp_reclen;
> > +
> > +     unsigned long           tcp_copied,
> > +                             tcp_flags;
> >  };
> >
> > +/*
> > + * tcp_flags
> > + */
> > +#define XS_LAST_FRAG         (1UL << 0)
> > +#define XS_COPY_FRGH         (1UL << 1)
> > +#define XS_COPY_XID          (1UL << 2)
> > +#define XS_COPY_DATA         (1UL << 3)
>
> Why are you renaming these?

Because XPRT_LAST_FRAG is generic.  XS_ is the naming scheme used in
net/sunrpc/xprtsock.c.  These flags are specific to the TCP socket
implementation in xprtsock.c

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
