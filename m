Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:36368 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750717AbaBZHCK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Feb 2014 02:02:10 -0500
Date: Wed, 26 Feb 2014 18:01:58 +1100
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: What does rpc.mountd dlopen() libnfsjunct.so rather than
 libnfsjunct.so.0
Message-ID: <20140226180158.7f7d0e62@notabene.brown>
In-Reply-To: <728AA1BE-98D9-4E63-B415-8CB922AD121C@oracle.com>
References: <20140226161646.1520358b@notabene.brown>
	<728AA1BE-98D9-4E63-B415-8CB922AD121C@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/.EtC9jwHLvtnr4L.O1_5.pw"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/.EtC9jwHLvtnr4L.O1_5.pw
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 25 Feb 2014 22:06:58 -0800 Chuck Lever <chuck.lever@oracle.com> wro=
te:

>=20
>=20
> > On Feb 25, 2014, at 9:16 PM, NeilBrown <neilb@suse.de> wrote:
> >=20
> >=20
> > See $SUBJ
> >=20
> > Shared libraries are usually versioned so you can release a new version=
 with
> > an incompatible API and gradually transition to it.
> >=20
> > A rpc.mountd dlopens libnfsjunct.so with no version it is effectively
> > prohibited from ever changing the API in an incompatible way.
>=20
> There is an API version field that mountd can examine before using the pl=
ug-in.  .so symlinks to whichever library version is the blessed one.

What exactly does "blessed one" mean...

Maybe the question I want to ask is:
 Is libnfsjunct.so something that only rpc.mountd would ever use and it cou=
ld
 not possibly make any sense for anything else to ever use it?

If so, then we probably don't want to install the .so.0 or .so.0.0.0 files
and maybe should give libnfsjunct.so a different suffix because it is not
"shared" in any sense (I wanted to suggest ".lo" for loadable object, but I
think that is already used).

If not, then you could conceivably have two tool installed which use
different version, so it doesn't make sense for either to be "blessed".
The bare ".so" name would be "the version that should be used when building
anything from source".

Does the question have a simple answer?

Thanks,
NeilBrown

--Sig_/.EtC9jwHLvtnr4L.O1_5.pw
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUw2RZjnsnt1WYoG5AQJmHA/9EC7EonEebMQeEa12S3ye20jVNDmX9USH
t3R+kfgPuLwI/rRTngoywq3uhuoU0vS/WM6om//vWyb9IR+/1hNNSjZ4SsKRqrzz
K6nhPByT2XqgPiXXEqroLRWvrRnZRHV7fVch8hn3BYFRNMqNhBY+7nCiE1fvraid
OzZztrBrtRnhcPsQdhaejVRgbPpd9ZWJMCxlQhqKltjIIl8ROgLaaNHYA9XrTAx0
7n2qXQN+VKe0r4AMq+7Qtq39uSw3ZgPAqO5MYbERljROyINYTOWi6GLtDIpWDQ4v
gRboRWOxmHf5ySap1EfmZTWKV5X3kSSdmVTb5Efp0oQvtIT17MONlwkvWXbHPhGD
VOZZrrQITunOkg77MfhX2Q8OQulND6gztp7KwyOH3tZoGMrRFxcmqMPWtI/MUlIg
Ck8qrDRj3PGiuClDu/5edaXYsUtlRnCv3XLcrP9cbR+S6lbnwf2OSl9C8v+77BHj
OgEaRu6ZNZuDUiSVJvrqkSCxgMpQIpbArNFprbiO4upKGyKSpDgqvGrargAmh7pP
cCdYB2VeEbdXf7yBe3sJUZuBSBTF87wKyLTDvIf5Nu5CGtCym8JARpdrAltjV1dQ
g6QYWgx3Me7YZy3ttZUuIjvgPg0sBt+0Kig+l5Q9h5LCJ2CcSu8MX4uTmtSSvn5O
kzVB+agCSQI=
=jVQC
-----END PGP SIGNATURE-----

--Sig_/.EtC9jwHLvtnr4L.O1_5.pw--
