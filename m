From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH 02/25] SUNRPC: Create a helper to tell whether a
	transport is bound
Date: Wed, 9 Aug 2006 11:27:46 -0400
Message-ID: <76bd70e30608090827i60102c94q1181550469de4af7@mail.gmail.com>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
	<20060809145853.3914.64708.stgit@picasso.dsl.sfldmi.ameritech.net>
	<1155136792.5731.84.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GApyG-00032V-1L
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:27:48 -0700
Received: from wx-out-0506.google.com ([66.249.82.235])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GApyG-0006Ph-0h
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:27:48 -0700
Received: by wx-out-0506.google.com with SMTP id r21so195729wxc
	for <nfs@lists.sourceforge.net>; Wed, 09 Aug 2006 08:27:47 -0700 (PDT)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <1155136792.5731.84.camel@localhost>
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

On 8/9/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Wed, 2006-08-09 at 10:58 -0400, Chuck Lever wrote:
> > diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> > index e8c2bc4..10ba1f6 100644
> > --- a/net/sunrpc/xprt.c
> > +++ b/net/sunrpc/xprt.c
> > @@ -534,7 +534,11 @@ void xprt_connect(struct rpc_task *task)
> >       dprintk("RPC: %4d xprt_connect xprt %p %s connected\n", task->tk_pid,
> >                       xprt, (xprt_connected(xprt) ? "is" : "is not"));
> >
> > -     if (!xprt->addr.sin_port) {
> > +     if (xprt->shutdown) {
> > +             task->tk_status = -EIO;
> > +             return;
> > +     }
>
> Why are you reinstating the test for xprt->shutdown? It was removed
> because it is pretty much useless there. Any task should already have
> been signalled to exit by rpc_shutdown_client()...

That's probably a silent git merge error.  I'll remove that.

> > +     if (!xprt_bound(xprt)) {
> >               task->tk_status = -EIO;
> >               return;
> >       }
> > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > index 441bd53..43b59c2 100644
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -974,6 +974,8 @@ static void xs_set_port(struct rpc_xprt
> >  {
> >       dprintk("RPC:      setting port for xprt %p to %u\n", xprt, port);
> >       xprt->addr.sin_port = htons(port);
> > +     if (port != 0)
> > +             xprt_set_bound(xprt);
>
> Hmm... This looks odd. If port == 0, why not exit immediately?
>
> Furthermore, what if the port is already bound: is it correct to set it
> again? IOW: should it be conditional on test_and_set_bit()?

The portmapper can set the port number to zero in the case of an
rpcbind error.  In that case, the transport should remain unbound.

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
