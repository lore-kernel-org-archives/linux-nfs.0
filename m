Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:37330 "EHLO smtp.gentoo.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754187AbcKNTMg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 14 Nov 2016 14:12:36 -0500
Date: Mon, 14 Nov 2016 11:12:34 -0800
From: Mike Frysinger <vapier@gentoo.org>
To: NeilBrown <neilb@suse.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc-devel@lists.sourceforge.net
Subject: Re: [Libtirpc-devel] [PATCH rpcbind] Move default state-dir to
 /run/rpcbind
Message-ID: <20161114191234.GV21655@vapier.lan>
References: <877f8almcf.fsf@notabene.neil.brown.name>
 <20161111210034.GM21655@vapier.lan>
 <87polzj7sx.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="iAb4HJL2YUi6ElHq"
In-Reply-To: <87polzj7sx.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--iAb4HJL2YUi6ElHq
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 14 Nov 2016 10:09, NeilBrown wrote:
> On Sat, Nov 12 2016, Mike Frysinger wrote:
> > On 11 Nov 2016 14:36, NeilBrown wrote:
> >> rpcbind can save state in a file to allow restart without forgetting
> >> about running services.
> >>=20
> >> The default location is currently "/tmp" which is an over-used
> >> directory that isn't really suitable for system files.
> >> The modern preferences would be a subdirectory of "/run", which can
> >> be selected with a ./configure option.  That subdirectory would still =
need
> >> to be created by something.
> >
> > the portable path is /var/cache instead of /run.  i don't think libtirpc
> > should be configuring itself to assume Linux by default.
>=20
> In principle I agree.  But is /var/cache really a good choice?
> We don't want the state files to persist over a reboot, and I strongly
> suspect that /var/cache is designed to do exactly that.
>=20
> Are there agree standards that are broader than Linux that we can look
> to?
> FHS defines /var/run (or even /run) but I suspect it is linux-only.

/var/run should work across systems i believe.  at least BSD's support it.
-mike

--iAb4HJL2YUi6ElHq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJYKgyiAAoJEEFjO5/oN/WB/YMP/0hKDoblw61+5S0ad1RR/qSh
QAcxEtmC5prbfHu0pB2X0gBZFjL+KMqz0OjJfiKFeYlYWbi7oTsDO3qjUNF0lcuZ
kEihHTXlD/gmelox2fY7Si2tWG34yqcooYjhjnrxuSdMTd8Z2mGJxMWn8tO1MCTZ
9Ss/dlzT0SGQX7q2X1rrfDFzGKRRABmw5S/5McSIRgBbEBHWXWyLweQFnCO9e9V+
D0qduaQyLZCGueZBqy+KNUH0c7P/WyzsQuS/bZWTpwtVidTtg/KKdmYp8pcPG0sl
66THxFKfvximQuGF8MjOTyGG5gfSmT5Vnl8Cl/6FPR+8JCVap2hAjhEDkSwekkpA
gzwf7mL4ryCIazkNJsC/0nYxLuCMEGWx7Pb8etL2OaliLO/NxnB6abH8RKN7SVBV
qDP0aIin+vGgBG2ljazEYCYt1ndwOzjhTmdTqYLcUZshdSSDjgUSwoXJ8loM1nin
Qr68X2xNvY+tJmO61GBVzjIRP89AF2lM+QH4+AC5qAS1dHAIKci3EItxRAOoOzeI
IPysLN9YLFwrUF+kihXsOwKok8j5ApQx9yG6WgoFL9gaX2TASHwUF+SEku1ydZFE
N5lVA+5mzbfEJeL3xRDBIAmQJMs3DK7Krt6+ovQGYBR6fnov0/hmuqVrihs+Q1Ej
8Ot4lGqblTOnn9aP1jBz
=H316
-----END PGP SIGNATURE-----

--iAb4HJL2YUi6ElHq--
