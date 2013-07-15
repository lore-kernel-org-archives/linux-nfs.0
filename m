Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:50587 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751566Ab3GOEcQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Jul 2013 00:32:16 -0400
Date: Mon, 15 Jul 2013 14:32:03 +1000
From: NeilBrown <neilb@suse.de>
To: "J.Bruce Fields" <bfields@citi.umich.edu>
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: Is tcp autotuning really what NFS wants?
Message-ID: <20130715143203.51bc583b@notabene.brown>
In-Reply-To: <20130710190727.GA22305@fieldses.org>
References: <20130710092255.0240a36d@notabene.brown>
	<20130710022735.GI8281@fieldses.org>
	<20130710143233.77e35721@notabene.brown>
	<20130710190727.GA22305@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/0MaPkKT83s7tkRIGQDfwsDU"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/0MaPkKT83s7tkRIGQDfwsDU
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 10 Jul 2013 15:07:28 -0400 "J.Bruce Fields" <bfields@citi.umich.edu>
wrote:

> On Wed, Jul 10, 2013 at 02:32:33PM +1000, NeilBrown wrote:
> > On Tue, 9 Jul 2013 22:27:35 -0400 "J.Bruce Fields" <bfields@citi.umich.=
edu>
> > wrote:
> >=20
> > > On Wed, Jul 10, 2013 at 09:22:55AM +1000, NeilBrown wrote:
> > > >=20
> > > > Hi,
> > > >  I just noticed this commit:
> > > >=20
> > > > commit 9660439861aa8dbd5e2b8087f33e20760c2c9afc
> > > > Author: Olga Kornievskaia <aglo@citi.umich.edu>
> > > > Date:   Tue Oct 21 14:13:47 2008 -0400
> > > >=20
> > > >     svcrpc: take advantage of tcp autotuning
> > > >=20
> > > >=20
> > > > which I must confess surprised me.  I wonder if the full implicatio=
ns of
> > > > removing that functionality were understood.
> > > >=20
> > > > Previously nfsd would set the transmit buffer space for a connectio=
n to
> > > > ensure there is plenty to hold all replies.  Now it doesn't.
> > > >=20
> > > > nfsd refuses to accept a request if there isn't enough space in the=
 transmit
> > > > buffer to send a reply.  This is important to ensure that each repl=
y gets
> > > > sent atomically without blocking and there is no risk of replies ge=
tting
> > > > interleaved.
>=20
> By the way, it's xpt_mutex that really guarantees non-interleaving,
> isn't it?

Yes.  I had the two different things confused.  The issue is only about
blocking on writes and consequently tying up nfsd threads.

>=20
> I think of the svc_tcp_has_wspace checks as solving a problem of
> fairness between clients.  If we only had one client, everything would
> work without them.  But when we have multiple clients we don't want a
> single slow client to be able to tie block every thread waiting for that
> client to receive read data.  Is that accurate?

It agrees with my understanding - yes.


>=20
> > > > The server starts out with a large estimate of the reply space (1M)=
 and for
> > > > NFSv3 and v2 it quickly adjusts this down to something realistic.  =
For NFSv4
> > > > it is much harder to estimate the space needed so it just assumes e=
very
> > > > reply will require 1M of space.
> > > >=20
> > > > This means that with NFSv4, as soon as you have enough concurrent r=
equests
> > > > such that 1M each reserves all of whatever window size was auto-tun=
ed, new
> > > > requests on that connection will be ignored.
> > > >
> > > > This could significantly limit the amount of parallelism that can b=
e achieved
> > > > for a single TCP connection (and given that the Linux client strong=
ly prefers
> > > > a single connection now, this could become more of an issue).
> > >=20
> > > Worse, I believe it can deadlock completely if the transmit buffer
> > > shrinks too far, and people really have run into this:
> > >=20
> > > 	http://mid.gmane.org/<20130125185748.GC29596@fieldses.org>
> > >=20
> > > Trond's suggestion looked at the time like it might work and be doabl=
e:
> > >=20
> > > 	http://mid.gmane.org/<4FA345DA4F4AE44899BD2B03EEEC2FA91833C1D8@sacex=
cmbx05-prd.hq.netapp.com>
> > >=20
> > > but I dropped it.
> >=20
> > I would probably generalise Trond's suggestion and allow "N" extra requ=
ests
> > through that exceed the reservation, when N is related to the number of=
 idle
> > threads.  squareroot might be nice, but half is probably easiest.
> >=20
> > If any send takes more than 30 seconds the sk_sndtimeo will kick in and=
 close
> > the connection so a really bad connection won't block threads indefinit=
ely.
> >=20
> >=20
> > And yes - a nice test case would be good.
> >=20
> > What do you think of the following (totally untested - just for comment=
)?
>=20
> In cases where the disk is the bottleneck, there aren't actually going
> to be idle threads, are there?  In which case I don't think this helps
> save a stuck client.

Do we care about the disk being a bottleneck?  We don't currently try to
handle that situation at all - if the disk is slow, everything slows down.
Unless you have to separate clients using two separate devices, then I think
that is the right think to do.  Limiting each filesystem to some number of
threads might be interesting but I don't think there would be much call for
it.

The present issue is when a client or network is slow and could thereby
interfere with the response to other clients.

Certainly the deadlock that can happen if write buffer space drops below 1M=
eg
would be an issue when very few clients are active.


>=20
> Trond's suggestion doesn't have the same limitation, if I understand it
> correctly.

I think I missed the "hand off to a workqueue" bit the first time.

I guess something like changing the "mutex_lock" in svc_send to
"mutex_try_lock" and if that fails, punt to a work-queue. We would need to
split the buffer space off the rqstp and attach it to the work struct.
Each rqstp could have a small array of work_structs and that sets the limit
on the number of requests that can be accepted when there is no wspace.

We probably don't even need a workqueue.  After completing a send, svc_send
can check if another reply has been queued and if so, it starts sending it -
if there is enough wspace.  If no wspace just do nothing.  The wspace
callback can queue the socket, and svc_xprt_enqueue can queue up an nfsd
thread if there is write work to do.  svc_handle_xprt() can do the actual
send.

This would require modifying all the xpo_sendto routines and the routines
they call to take an index into the list of send buffers per socket.  Or
maybe a pointer to a "delayed reply" structure.


For each delayed reply we would need:
 - struct xdr_buf  - to hold the reply
 - struct page *[RPCSVC_MAXPAGES]  - to hold the pages so we can free them
                                     when done
 - struct sockaddr_storage         - to hold source address for UDP reply
 - struct sockaddr_storage         - to hold the dest address for UDP
 - maybe something else for RDMA?  - svc_rdma_sendto uses rqstp->rq_arg - n=
ot
                                     sure why.

We could possible allocate these as needed.  If the kmalloc fails, just use
"mutex_lock" instead of "mutex_trylock" and block for a while.

Note that while this structure would be smaller than "struct svc_rqst", it =
is
not completely trivial.  It might be just as easy to allocate a new "svc_rq=
st"
structure.  Or fork new nfsd threads.


I think the key issue is really to allow some nfsd threads to block on
writing the reply, but to firmly limit the number which do.  This is what my
patch tried to do.
Punting to a work queue might allow a little less memory to be allocated
to end up with the same number of spare threads, but would require a lot mo=
re
code churn.

I wonder if it is time to revisit dynamic sizing of the nfsd thread pool.

NeilBrown


--Sig_/0MaPkKT83s7tkRIGQDfwsDU
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUeN7Qznsnt1WYoG5AQLfJw/+O99Mpj98xj3DjilRNT3+A1riZj1efXht
I9+6n5SALbfHu/+n3jsigzOUh8cw4qQ/KH45uG9RNIFKjbXwRPPLBqeKnwVO7JBd
b8N8hty5AGd1vmEIAV40KefVNeJpPoEZovTHG8W093QG52rIfW56uvztB3edhSOU
qMJ1frWtj4fXWJ8LqwuSARBhP0p0YSrvVqD6YX60ozHemvzPodxJEhlya/32EBQN
HaLpAbELra6cjzw+T+6fPAxOKZC1HrqOj50quQogUIcVFJRB5SbG4ZL3PK0NdKgG
I5I18voFo11Iy5gd0KqTqRcnGstEJvyhAb2SUAgAFjEbB3eYHrqbx7ADR/14lYJn
VwLLbYA7Gx+UyBPOxIktkD0QoP8IS0j8Q3Q/GT67Qqoy8Nsw/oPOFAvbVkS87NJm
S5ocBwHK47MYIMhssI6tsFnkFl1TSpndeZuK0S4dLpGlTj93BSMHT+Kk7IUGYoRn
7mDL+AHdQvOShmismbEyE9L8Q8wq9UzI/k8Xgh/uWP2uGgEcmgwcmbNSEaD4zzhr
lROkEgEHKu3XsKBzydYcyNzaEvb3JknmscQUJOxMBUXT7HME7A1txnJyTAN8Ahhk
BFz4aBRAIXSEtOglhFTh7KlITjT5wlYn+q5BnwwM6bCNDlEDsPT6lGCF0Q4ICKTV
uItMxD5GOJE=
=7jUe
-----END PGP SIGNATURE-----

--Sig_/0MaPkKT83s7tkRIGQDfwsDU--
