Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:50638 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751424Ab3GOEfi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Jul 2013 00:35:38 -0400
Date: Mon, 15 Jul 2013 14:35:27 +1000
From: NeilBrown <neilb@suse.de>
To: Ben Greear <greearb@candelatech.com>
Cc: Dean <seattleplus@gmail.com>, "J.Bruce Fields" <bfields@citi.umich.edu>,
        Olga Kornievskaia <aglo@citi.umich.edu>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Is tcp autotuning really what NFS wants?
Message-ID: <20130715143527.4eca7283@notabene.brown>
In-Reply-To: <51DD9C5A.3000505@candelatech.com>
References: <20130710092255.0240a36d@notabene.brown>
	<20130710022735.GI8281@fieldses.org>
	<51DD9AD5.1030508@gmail.com>
	<51DD9C5A.3000505@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/g3.94vV3oovgjsBx/2YeQpu"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/g3.94vV3oovgjsBx/2YeQpu
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 10 Jul 2013 10:39:38 -0700 Ben Greear <greearb@candelatech.com> wro=
te:

> On 07/10/2013 10:33 AM, Dean wrote:
> >  > This could significantly limit the amount of parallelism that can be=
 achieved for a single TCP connection (and given that the
> >  > Linux client strongly prefers a single connection now, this could be=
come more of an issue).
> >
> > I understand the simplicity in using a single tcp connection, but perfo=
rmance-wise it is definitely not the way to go on WAN links. When even a mi=
niscule amount
> > of packet loss is added to the link (<0.001% packet loss), the tcp buff=
er collapses and performance drops significantly (especially on 10GigE WAN =
links).  I
> > think new TCP algorithms could help the problem somewhat, but nothing a=
vailable today makes much of a difference vs. cubic.
> >
> > Using multiple tcp connections allows better saturation of the link, si=
nce when packet loss occurs on a stream, the other streams can fill the voi=
d.  Today, the
> > only solution is to scale up the number of physical clients, which has =
high coordination overhead, or use a wan accelerator such as Bitspeed or Ri=
verbed (which
> > comes with its own issues such as extra hardware, cost, etc).
>=20
> I have a set of patches that allows one to do multiple unique mounts to t=
he same server from a single
> client, but the patches are for the client side, so it would not help
> non-Linux clients.  And, the patches were rejected for upstream as not be=
ing
> useful.  But, if you are interested in such, please let me know and I can=
 point
> you to them...

Yes please!

NeilBrown

--Sig_/g3.94vV3oovgjsBx/2YeQpu
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUeN8Dznsnt1WYoG5AQIJnw/+NX2XltL5HwgcZncP9eTGIpPs1hXMxl0L
HjHwlTk5dvN4J8YtVYLVKYswY5DtAtakbM+oYODLTXrnwjB4zS2rghm9M0azgzAH
c8b9o8XoGAQnGnPos+357HqcN7v8/EOyyrFLAzj1h6++XXn9QSpGzhVVq8LBURlu
qc5tjGe5DEf5SnELPZFQ8ZI6hdN0RRfr0X3YzwCzbLiUaC+bIwjYzye3tFLBl5hQ
Io/PWLraR4Jw7bWsuGdPxVyHPs99gHkbUKUmP1tEUVO6pJU3XbWdu+hXJUEFPqYX
ZNRhwkgu2kynuOi1U5XTUlXo7V1SPI9Z5zcOjvmkYY+M1QQNN+t0U/vrDauhu73r
MSu2w/pvHb12ZWV3dhuJxAsJNsWwXh2El1dSpLJGLW1UE287DqPhlTidB+LCdr1y
bZmiNQNCnabdk2fPSJgfEwC9FcrdL7+OlXyHkrQTLoS/61Kr+tNvUfmaY8egIpai
YMLnBalMJMIvPQc46QykNAzZPs5w4gy22pT62+xnQ51Hm1W5anKsv3qez7OvNxg4
CWOcSCMU/dnjm47GUSA7x5UPY24+uVF/gtCrxRSbZxLfpVaAU0FIJuixE9pJKvcn
Yr6UNfLJDotZr5c51St6qagqgOwBGBdfsKWsJAbTvn26jv4w12zK52I0kcguE/xF
+fvwYMmVO0M=
=jyNC
-----END PGP SIGNATURE-----

--Sig_/g3.94vV3oovgjsBx/2YeQpu--
