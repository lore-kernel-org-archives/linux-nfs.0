Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:34648 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751327Ab2IYFzK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Sep 2012 01:55:10 -0400
Date: Tue, 25 Sep 2012 15:54:57 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Michael Tokarev <mjt@tls.msk.ru>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] svcrpc: fix svc_xprt_enqueue/svc_recv busy-looping
Message-ID: <20120925155457.44428c06@notabene.brown>
In-Reply-To: <20120820224915.GM5779@fieldses.org>
References: <20120820223746.GL5779@fieldses.org>
	<20120820224915.GM5779@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/TU6CpmIv64VYesfjYGCa7V8"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/TU6CpmIv64VYesfjYGCa7V8
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 20 Aug 2012 18:49:15 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Mon, Aug 20, 2012 at 06:37:47PM -0400, bfields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> >=20
> > The rpc server tries to ensure that there will be room to send a reply
> > before it receives a request.
> >=20
> > It does this by tracking, in xpt_reserved, an upper bound on the total
> > size of the replies that is has already committed to for the socket.
> >=20
> > Currently it is adding in the estimate for a new reply *before* it
> > checks whether there is space available.  If it finds that there is not
> > space, it then subtracts the estimate back out.
> >=20
> > This may lead the subsequent svc_xprt_enqueue to decide that there is
> > space after all.
> >=20
> > The results is a svc_recv() that will repeatedly return -EAGAIN, causing
> > server threads to loop without doing any actual work.
> >=20
> > Cc: stable@vger.kernel.org
> > Reported-by: Michael Tokarev <mjt@tls.msk.ru>
> > Tested-by: Michael Tokarev <mjt@tls.msk.ru>
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  net/sunrpc/svc_xprt.c |    7 ++-----
> >  1 file changed, 2 insertions(+), 5 deletions(-)
> >=20
> > Queuing up for 3.6 absent any objections.--b.
>=20
> By the way, one thing I'm still curious about is how this got
> introduced.  mjt bisected it to f03d78db65085609938fdb686238867e65003181
> "net: refine {udp|tcp|sctp}_mem limits", which looks like it just made
> the problem a little more likely.
>=20
> The last substantive change to has_wspace logic was Trond's
> 47fcb03fefee2501e79176932a4184fc24d6f8ec, but I have a tough time
> figuring out whether that would have affected it one way or the other.
>=20
> As far as I can tell we've always added to xpt_reserved in this way, so
> that svc_recv and svc_xprt_enqueue are comparing different things, and
> surely this was always wrong even if the problem must have been harder
> to trigger before.
>=20
> But some of the wspace logic I don't understand, so cc'ing Neil and
> Trond in case they see any other problem I missed.

Hi Bruce et al.

My guess is that=20
commit 9c335c0b8daf56b9f73479d00b1dd726e1fcca09
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Oct 26 11:32:03 2010 -0400

    svcrpc: fix wspace-checking race

introduced this problem.  It moved the test for 'do we have enough space'
from before we add in the requirements of a new request, to after.

But I think your patch looks good.

Thanks,
NeilBrown


>=20
> --b.
>=20
> >=20
> > diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> > index 0d693a8..bac973a 100644
> > --- a/net/sunrpc/svc_xprt.c
> > +++ b/net/sunrpc/svc_xprt.c
> > @@ -316,7 +316,6 @@ static bool svc_xprt_has_something_to_do(struct svc=
_xprt *xprt)
> >   */
> >  void svc_xprt_enqueue(struct svc_xprt *xprt)
> >  {
> > -	struct svc_serv	*serv =3D xprt->xpt_server;
> >  	struct svc_pool *pool;
> >  	struct svc_rqst	*rqstp;
> >  	int cpu;
> > @@ -362,8 +361,6 @@ void svc_xprt_enqueue(struct svc_xprt *xprt)
> >  				rqstp, rqstp->rq_xprt);
> >  		rqstp->rq_xprt =3D xprt;
> >  		svc_xprt_get(xprt);
> > -		rqstp->rq_reserved =3D serv->sv_max_mesg;
> > -		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
> >  		pool->sp_stats.threads_woken++;
> >  		wake_up(&rqstp->rq_wait);
> >  	} else {
> > @@ -640,8 +637,6 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
> >  	if (xprt) {
> >  		rqstp->rq_xprt =3D xprt;
> >  		svc_xprt_get(xprt);
> > -		rqstp->rq_reserved =3D serv->sv_max_mesg;
> > -		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
> > =20
> >  		/* As there is a shortage of threads and this request
> >  		 * had to be queued, don't allow the thread to wait so
> > @@ -738,6 +733,8 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
> >  		else
> >  			len =3D xprt->xpt_ops->xpo_recvfrom(rqstp);
> >  		dprintk("svc: got len=3D%d\n", len);
> > +		rqstp->rq_reserved =3D serv->sv_max_mesg;
> > +		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
> >  	}
> >  	svc_xprt_received(xprt);
> > =20
> > --=20
> > 1.7.9.5
> >=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Sig_/TU6CpmIv64VYesfjYGCa7V8
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUGFHMTnsnt1WYoG5AQK1Wg//azG96GdLYlULzrtD7wOGp6b4AiAMlhMQ
6xKeTze7cTmKbdq0Ay90ItE498JGvS4DngMhc9zSEHyDWG07GAO9sndY+Ssa5Bq6
FDhio1mKeqeHCZiGkIMNNRFjHPAOZ3bPhBXhHASwisnjPxboXch2NeNVkE8Di2/t
WUt63AKkqurEDd5PXBljWwMS7faCDNX0L11L9x4ymDqZNbH7B5oYmel0l+Nw4uYo
I8t8ydA0NTj6Hlml2LcKDQ+VR5f45X7pRoJSCX/2TuACIQIKZc1li73xdDdauXTF
uJG4dkPcpD4hond3Ujs1fVGS2ZMfEBpJ7XPgSEstxhfT2AYTF+SsE5AIxM8QL5+u
gKFEcL7/2/atmNuC12awGuvdtu0Q1P2JTT1OHxZszmn4E2jWcq4hi7lIf2XVPWas
vTfNiXFvtW+I7HwBXXJAn2HyER2qg9xq5MjGWa9gvhnhMe2CMIFQYGnIpVqKY30D
mxQ8z5imWgwYgsjDgo/IfTEbeNSr/NJKDtlWb/zznROYxN5wgUdcCGwurpJBjAU+
wVkRxer+JKG9tjIlXQDwIA6HxmFRcJtHVPMNnqXiH8bqpZkY6WiudYWDW7uwC9zl
rRmwE4KpVKNiRBVsetuGxyV+wlYWT1i8ilxrN6BULGfi6qB68C+rElj3LPpweSJP
rfOTQjm+Cus=
=rtQ1
-----END PGP SIGNATURE-----

--Sig_/TU6CpmIv64VYesfjYGCa7V8--
