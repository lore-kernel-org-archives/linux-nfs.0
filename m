Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:41014 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750695Ab3GPEAd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Jul 2013 00:00:33 -0400
Date: Tue, 16 Jul 2013 14:00:21 +1000
From: NeilBrown <neilb@suse.de>
To: "J.Bruce Fields" <bfields@citi.umich.edu>
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: Is tcp autotuning really what NFS wants?
Message-ID: <20130716140021.312b5b07@notabene.brown>
In-Reply-To: <20130716015803.GA5271@fieldses.org>
References: <20130710092255.0240a36d@notabene.brown>
	<20130710022735.GI8281@fieldses.org>
	<20130710143233.77e35721@notabene.brown>
	<20130710190727.GA22305@fieldses.org>
	<20130715143203.51bc583b@notabene.brown>
	<20130716015803.GA5271@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/JD5GR40J/Wb1gTIHsR3_XRW"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/JD5GR40J/Wb1gTIHsR3_XRW
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 15 Jul 2013 21:58:03 -0400 "J.Bruce Fields" <bfields@citi.umich.edu>
wrote:

> On Mon, Jul 15, 2013 at 02:32:03PM +1000, NeilBrown wrote:
> > On Wed, 10 Jul 2013 15:07:28 -0400 "J.Bruce Fields" <bfields@citi.umich=
.edu>
> > wrote:
> >=20
> > > On Wed, Jul 10, 2013 at 02:32:33PM +1000, NeilBrown wrote:
> > > > On Tue, 9 Jul 2013 22:27:35 -0400 "J.Bruce Fields" <bfields@citi.um=
ich.edu>
> > > > wrote:
> > > >=20
> > > > > On Wed, Jul 10, 2013 at 09:22:55AM +1000, NeilBrown wrote:
> > > > > >=20
> > > > > > Hi,
> > > > > >  I just noticed this commit:
> > > > > >=20
> > > > > > commit 9660439861aa8dbd5e2b8087f33e20760c2c9afc
> > > > > > Author: Olga Kornievskaia <aglo@citi.umich.edu>
> > > > > > Date:   Tue Oct 21 14:13:47 2008 -0400
> > > > > >=20
> > > > > >     svcrpc: take advantage of tcp autotuning
> > > > > >=20
> > > > > >=20
> > > > > > which I must confess surprised me.  I wonder if the full implic=
ations of
> > > > > > removing that functionality were understood.
> > > > > >=20
> > > > > > Previously nfsd would set the transmit buffer space for a conne=
ction to
> > > > > > ensure there is plenty to hold all replies.  Now it doesn't.
> > > > > >=20
> > > > > > nfsd refuses to accept a request if there isn't enough space in=
 the transmit
> > > > > > buffer to send a reply.  This is important to ensure that each =
reply gets
> > > > > > sent atomically without blocking and there is no risk of replie=
s getting
> > > > > > interleaved.
> > >=20
> > > By the way, it's xpt_mutex that really guarantees non-interleaving,
> > > isn't it?
> >=20
> > Yes.  I had the two different things confused.  The issue is only about
> > blocking on writes and consequently tying up nfsd threads.
> >=20
> > >=20
> > > I think of the svc_tcp_has_wspace checks as solving a problem of
> > > fairness between clients.  If we only had one client, everything would
> > > work without them.  But when we have multiple clients we don't want a
> > > single slow client to be able to tie block every thread waiting for t=
hat
> > > client to receive read data.  Is that accurate?
> >=20
> > It agrees with my understanding - yes.
> >=20
> >=20
> > >=20
> > > > > > The server starts out with a large estimate of the reply space =
(1M) and for
> > > > > > NFSv3 and v2 it quickly adjusts this down to something realisti=
c.  For NFSv4
> > > > > > it is much harder to estimate the space needed so it just assum=
es every
> > > > > > reply will require 1M of space.
> > > > > >=20
> > > > > > This means that with NFSv4, as soon as you have enough concurre=
nt requests
> > > > > > such that 1M each reserves all of whatever window size was auto=
-tuned, new
> > > > > > requests on that connection will be ignored.
> > > > > >
> > > > > > This could significantly limit the amount of parallelism that c=
an be achieved
> > > > > > for a single TCP connection (and given that the Linux client st=
rongly prefers
> > > > > > a single connection now, this could become more of an issue).
> > > > >=20
> > > > > Worse, I believe it can deadlock completely if the transmit buffer
> > > > > shrinks too far, and people really have run into this:
> > > > >=20
> > > > > 	http://mid.gmane.org/<20130125185748.GC29596@fieldses.org>
> > > > >=20
> > > > > Trond's suggestion looked at the time like it might work and be d=
oable:
> > > > >=20
> > > > > 	http://mid.gmane.org/<4FA345DA4F4AE44899BD2B03EEEC2FA91833C1D8@s=
acexcmbx05-prd.hq.netapp.com>
> > > > >=20
> > > > > but I dropped it.
> > > >=20
> > > > I would probably generalise Trond's suggestion and allow "N" extra =
requests
> > > > through that exceed the reservation, when N is related to the numbe=
r of idle
> > > > threads.  squareroot might be nice, but half is probably easiest.
> > > >=20
> > > > If any send takes more than 30 seconds the sk_sndtimeo will kick in=
 and close
> > > > the connection so a really bad connection won't block threads indef=
initely.
> > > >=20
> > > >=20
> > > > And yes - a nice test case would be good.
> > > >=20
> > > > What do you think of the following (totally untested - just for com=
ment)?
> > >=20
> > > In cases where the disk is the bottleneck, there aren't actually going
> > > to be idle threads, are there?  In which case I don't think this helps
> > > save a stuck client.
> >=20
> > Do we care about the disk being a bottleneck?  We don't currently try to
> > handle that situation at all - if the disk is slow, everything slows do=
wn.
>=20
> Right, that's fine, it's just that:
>=20
> Suppose you have a fast network, several fast clients all continuously
> reading, and one slow disk.
>=20
> Then in the steady state all the threads will be waiting on the disk,
> and the receive buffers will all be full of read requests from the
> various clients.  When a thread completes a read it will immediately
> send the response, pick up the next request, and go back to waiting on
> the disk.
>=20
> Suppose the send buffer of one of the clients drops below the minimum
> necessary.
>=20
> Then aftert that point, I don't think that one client will ever have
> another rpc processed, even after your proposed change.

That would be because I only allowed extra requests up to half the number of
idle threads, and there would be zero idle threads.

So yes - I see your point.

I now think that it is sufficient to just allow one request through per
socket.  While there is high memory pressure, that is sufficient.  When the
memory pressure drops, that should be enough to cause sndbuf to grow.

We should be able to use xpt_reserved to check if this is the only request
or not:=20


diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 80a6640..5b832ef 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -331,7 +331,8 @@ static bool svc_xprt_has_something_to_do(struct svc_xpr=
t *xprt)
 	if (xprt->xpt_flags & ((1<<XPT_CONN)|(1<<XPT_CLOSE)))
 		return true;
 	if (xprt->xpt_flags & ((1<<XPT_DATA)|(1<<XPT_DEFERRED)))
-		return xprt->xpt_ops->xpo_has_wspace(xprt);
+		return xprt->xpt_ops->xpo_has_wspace(xprt) ||
+			atomic_read(&xprt->xpt_reserved) =3D=3D 0;
 	return false;
 }
=20
@@ -730,7 +731,8 @@ static int svc_handle_xprt(struct svc_rqst *rqstp, stru=
ct svc_xprt *xprt)
 		newxpt =3D xprt->xpt_ops->xpo_accept(xprt);
 		if (newxpt)
 			svc_add_new_temp_xprt(serv, newxpt);
-	} else if (xprt->xpt_ops->xpo_has_wspace(xprt)) {
+	} else if (xprt->xpt_ops->xpo_has_wspace(xprt) ||
+		   atomic_read(&xprt->xpt_reserved) =3D=3D 0) {
 		/* XPT_DATA|XPT_DEFERRED case: */
 		dprintk("svc: server %p, pool %u, transport %p, inuse=3D%d\n",
 			rqstp, rqstp->rq_pool->sp_id, xprt,


Thoughts?

I tried testing this, but xpo_has_wspace never fails for me, even if I remo=
ve
the calls to svc_sock_setbufsize (which probably aren't wanted for TCP any
more).

>=20
> Am I missing anything?

Not as far as I can see - thanks!

NeilBrown


--Sig_/JD5GR40J/Wb1gTIHsR3_XRW
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUeTFVTnsnt1WYoG5AQK4hQ//fppL2A6DeixYfn4O/cZTSPbK+ERjLqet
vXFTZF0Jlw/3SOG71+p4vq3+VUazLYk9Lyg5nhf0kXGnuPMou02UIcemmX9oTxTa
1cxYngOcx+ioYInDAqkgiHTPByTsA36yXR9Aqa0He5OO0gKqibxRSN03yzyixegM
GpyMJObQCpGx/gRIZrT8zrDvt8+aC3Fb5axp7Hvs3EweExgGpCm/iEqy4+QOreV5
49f1MgtWMrUF8d2v0u8Uf3audph1YP/7aRA6LNWOzfltkdDftIOoHhggLP3cmBuz
PazeTCu9rkD6a8165ryOLzxE5g2CzYsvZvw0uPqXL3PG/sgbFvnIFR+uAEnyouUq
OE8kmMt/wi/WLpOjLlomU9ddcy2SrOnv6qglVkZrrPhM1hltvFb8OX2PjxY2DFcD
XPUAXyhu/WJHYIldc6NJY9SMBGeOjTX0DlqiqTzonM8hkL9LGEEeO8mAldUmShYW
hFrGTu/RIRdybusMBNAHTr8zPVI+aE5S9BM/Z9tee0UoBrgT6Drt10/Ugyt8OZGy
sqGwoWvXR0dM1b+493eRhwdrcSGG6Ku4HWStL6cCza7RzdJ80fCIJXYs9sRBIGk7
YkIa0oVbO46rQrsuZOXw+JI+aj7dk5lTTK2ag7hwaGgasI15BZVG9vjAa9lgzflk
8HokKDso9GM=
=PHZU
-----END PGP SIGNATURE-----

--Sig_/JD5GR40J/Wb1gTIHsR3_XRW--
