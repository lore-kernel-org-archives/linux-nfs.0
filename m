Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59256 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751373AbcKCAXF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 2 Nov 2016 20:23:05 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>, Thorsten Kukuk <kukuk@suse.de>
Date: Thu, 03 Nov 2016 11:22:57 +1100
Cc: linux-nfs@vger.kernel.org, libtirpc-devel@lists.sourceforge.net
Subject: Re: [Libtirpc-devel] [PATCH - rpcbind] Provide systemd unit files for rpcbind
In-Reply-To: <bf20e38d-6129-688f-42b8-aad97334daea@RedHat.com>
References: <87oa2q14yc.fsf@notabene.neil.brown.name> <8c1fa65d-9efc-462a-b6c8-7ed518f0dfe4@RedHat.com> <87r36vq85k.fsf@notabene.neil.brown.name> <ff5e0322-2f5e-9102-326f-1f23968cb0a8@RedHat.com> <20161102134902.GA6446@suse.de> <34b0c398-c77f-41e3-4719-158f2190661c@RedHat.com> <87a8dhr39t.fsf@notabene.neil.brown.name> <bf20e38d-6129-688f-42b8-aad97334daea@RedHat.com>
Message-ID: <874m3pqun2.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 03 2016, Steve Dickson wrote:
> Yes... basically
>=20=20
> -bin_PROGRAMS =3D rpcbind rpcinfo
> +sbin_PROGRAMS =3D rpcbind rpcinfo

Maybe

=2Doptions like `--bindir=3DDIR' to specify different values for particular
+options like `--sbindir=3DDIR' to specify different values for particular

in INSTALL too??
>
> and that seems to work... all this means the rpm spec file
> will have to be tweaked when a new release is made.
>
> All I'll for checking in these systemd file with the comments
> from the systemd people and the bin=3D>sbin change.
>
> How about a respin?

Attached

Thanks,
NeilBrown


--==-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYGoNhAAoJEDnsnt1WYoG5DXAP/06DV9J7GLkIpx41RFI3Reoy
OzNbQINHRGQwKrdcDmiXWOIo4Qo+U3l1lTrq+c1CmpfVamnNGGQ1CAkcyeAbPKGK
o8uo18NZW03t6choDpbhCSRf+VJDcz/++4dB1ClSaC7KaNyKQYC2bUCeiH5WJqWy
FmBmmUz7/i/mdBHNbsnP/qw5xps1+8m/TLWsNaqAMOAVK4Uo/XtblZDn66dExj6S
M+ZARyBHd5rYb1+Y3P5zgH8mAZy59LKvMYcnGd/2apA90bApujmCI7DrXrw0Z+XE
EvQAkSsOvqCYhgKIgVP9oI8cFWjoh6ZzhDovUwd/Yj8zwx2ad27nXatZwuDFpz70
k3B7EKGWg0mVqTo29QR/QJtwEplNBa1XA3R/V5mJVlMItt6ceyS4jnw3tSI0KbH4
2zjCCKTy8e5rI41fRFKfGZnZbO0TLZ+JHBzSpf0yHXexMaTmL4+782ZIPbV7e3zh
9h1wn815i1gFQgIUAP7iayYJ587qPjcMiS870KMLd/XlIG534fo4MDY59yRrxkWd
GPvSW4y0SfKZ7GiXZftyBS6tHxVVAjT7NwblO0wJJSByUfEnAUVaWv3UWFZXSmTw
lncXSWc+VC1FNpAX4s2nUenyiDBa4Hu1cNTcbrNXUrGCLXXcoqVyRCyWxA7hfKge
hRqRLwI/agYiXDNpHu2X
=8+aa
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=
Content-Type: text/x-patch
Content-Disposition: inline;
 filename=0001-Provide-systemd-unit-files-for-rpcbind.patch


--=-=-=--
