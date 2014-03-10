Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:51291 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751846AbaCJAKf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Mar 2014 20:10:35 -0400
Date: Mon, 10 Mar 2014 11:10:27 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/4] nfsd: add -r and --rdma options to request rdma
 service.
Message-ID: <20140310111027.6d6a280f@notabene.brown>
In-Reply-To: <531B3530.4060704@RedHat.com>
References: <20140220063616.6548.42556.stgit@notabene.brown>
	<20140220063648.6548.10041.stgit@notabene.brown>
	<531B3530.4060704@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/y20F1OEmcROqYtNxyIMrIoA"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/y20F1OEmcROqYtNxyIMrIoA
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sat, 08 Mar 2014 10:20:16 -0500 Steve Dickson <SteveD@redhat.com> wrote:

> Hey Neil,
>=20
> This part did not apply cleanly=20
>=20
> On 02/20/2014 01:36 AM, Neil Brown wrote:
> > void
> >  nfssvc_setvers(unsigned int ctlbits, int minorvers[])
> >  {
> > diff --git a/utils/nfsd/nfssvc.h b/utils/nfsd/nfssvc.h
> > index 2bbd3d30f92a..bb7fccee7c19 100644
> > --- a/utils/nfsd/nfssvc.h
> > +++ b/utils/nfsd/nfssvc.h
> > @@ -24,5 +24,6 @@ void	nfssvc_mount_nfsdfs(char *progname);
> >  int	nfssvc_inuse(void);
> >  int	nfssvc_set_sockets(const int family, const unsigned int protobits,
> >  			   const char *host, const char *port);
> > +int	nfssvc_set_rdmaport(const char *port);
> >  void	nfssvc_setvers(unsigned int ctlbits, int minorvers4[]);
> ^^^ this interface is different that the one I have in my tree
>=20
> The one I have is=20
> void    nfssvc_setvers(unsigned int ctlbits, unsigned int minorvers4, uns=
igned int minorvers4set);

The patch which changed that interface to the new one predates my patch by 7
days, so maybe I didn't pull before I did the development.
(I was doing that in my systemd-devel branch which I hadn't rebased recentl=
y).

Thanks,
NeilBrown


>=20
> No biggie but I'm just wandering if I'm missing a patch...=20
>=20
> steved.
> >  int	nfssvc_threads(unsigned short port, int nrservs);


--Sig_/y20F1OEmcROqYtNxyIMrIoA
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUx0C8znsnt1WYoG5AQLnyQ//QGDeIvCxXhhr236tWzofhWn/XoAXm053
rsoBfQZ8HRCbqeZep829FVxMtaidP+69FMZ7p9a1wg6iHeYdGxbcqqpvVGFdnSqO
sLM3QlFy4B6ksOHFZ8dgDvjptFjUJUWKESjL0RszIwT6mZMhjZNZvwQjx5ctP5ig
cSPmIaYTeq12GBOC48oZyNKFt3SDWthV6nChbiECYmNcfy5Ff+5asbNj8bxPvMOX
ZQJpror/Znw1WzWrKFHVtX591xRmPeXu6PttFjrRa7W2NhStJ8rIfKQKDSA0mofT
J5iZLPFLAAPesw0Qa4ohK30wZmicPz9+CKdtL3uI8gsB4YFAk21QWSW01Lx1/eqt
a2i0c2paLmNCgKaxq+O3az7DemoC1CFsHPcd4XzF6QVaw82pv0CBo0bV39i+uGIv
5NzcO01uoUe4pTAXJB2YRJFOAxA/snScynIRzmaPAqXcgLogdBQqno2BuqZXZXg3
SaMi4rGmOSQowMhrBoiKbN6QiVJruiEFmT5C8vks9TSKONYxD4QCnT6Dd1XGtp3v
h/5/upw/DNRAdlmiX90bg1fBOVchPCKEDcW3f+8kHrqYkx0MNGVCJ98EK0cuOrk9
QWgTSNHk4YTLqDsoxnEYTNW7hOunWf3vIpfqcZrUEY0qBMxkT+kco24dZQK9odjT
nP1elwFnQA4=
=44L9
-----END PGP SIGNATURE-----

--Sig_/y20F1OEmcROqYtNxyIMrIoA--
