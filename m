Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52392 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755237AbaCEDpO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Mar 2014 22:45:14 -0500
Date: Wed, 5 Mar 2014 14:45:03 +1100
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Simo Sorce <simo@redhat.com>, Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: What does rpc.mountd dlopen() libnfsjunct.so rather than
 libnfsjunct.so.0
Message-ID: <20140305144503.7310db31@notabene.brown>
In-Reply-To: <6259E7ED-5D8C-4E29-A8B3-E0D11F2D6FFB@oracle.com>
References: <20140226161646.1520358b@notabene.brown>
	<1393425572.18299.157.camel@willson.li.ssimo.org>
	<3A4B7C90-54B8-4373-B751-B02D940199BC@oracle.com>
	<20140227095859.19ba8a87@notabene.brown>
	<6259E7ED-5D8C-4E29-A8B3-E0D11F2D6FFB@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/4AHJlHyZb0u67dgIaso_LFv"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/4AHJlHyZb0u67dgIaso_LFv
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Tue, 4 Mar 2014 13:35:09 -0500 Chuck Lever <chuck.lever@oracle.com> wrot=
e:

>=20
> On Feb 26, 2014, at 5:58 PM, NeilBrown <neilb@suse.de> wrote:
>=20
> [ =E2=80=A6 rationale removed =E2=80=A6 ]
>=20
> > So rather than dlopening "libnfsjunct.so.0" rpc.mountd should probably
> > use a library name provided by the include file
> >=20
> > Thanks,
> > NeilBrown
> >=20
> > diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> > index ca35de28847a..1a8c20492869 100644
> > --- a/utils/mountd/cache.c
> > +++ b/utils/mountd/cache.c
> > @@ -1139,7 +1139,11 @@ static struct exportent *lookup_junction(char *d=
om, const char *pathname,
> > 	struct link_map *map;
> > 	void *handle;
> >=20
> > -	handle =3D dlopen("libnfsjunct.so", RTLD_NOW);
> > +#ifdef JP_LIB_NAME
> > +	handle =3D dlopen(JP_LIB_NAME, RTLD_NOW);
>=20
> What I can do now for fedfs-utils 0.10.1 is add a macro to the header fil=
e that defines the library name. I'd like to go with
>=20
> #define JP_NFSPLUGIN_SONAME =E2=80=9Clibnfsjunct.so.0=E2=80=9D
>=20
> unless there are objections.

Perfectly happy with that, thanks.

>=20
> The mountd patch could also remove the API version check in invoke_juncti=
on_ops() when this macro is present.

I'll send a patch to Steve.

Thanks,
NeilBrown

>=20
> > +#else
> > +	handle =3D dlopen("libnfsjunct.so.0", RTLD_NOW);
> > +#endif
> > 	if (handle =3D=3D NULL) {
> > 		xlog(D_GENERAL, "%s: dlopen: %s", __func__, dlerror());
> > 		return NULL;
>=20
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>=20
>=20


--Sig_/4AHJlHyZb0u67dgIaso_LFv
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUxadvznsnt1WYoG5AQJ13Q/+NEYNhvIvB4ePtrRo/ctJ94ud8tOyQhkQ
ewSoL9kbI2Wn88+/y4sSYdrV5vePGAh8OSvycTNs/+Qr4mUv2co7d81I0Yn58BCX
hk9Hhk1z1cqXWk6GYZE5E+GWgR7PKHDutQgytEV4CR9MV6opQh1lCjWRK7QQVun4
vkX3TMnnemC2ckYqJ7v2VfIDlTLdk92md5EWAz+yXGx1MRrybnQe7LZOTuHXq0k1
HNQzAl3wcM4I+eGq53x8y+TLWykQ99TtBXNvOTwm9MqxFoQLKbdjRHAFZ0sjd6+T
/V8KSxVxyszp4n4HseVPKOMkRB+6QNvDDjye77yBf4k2T1LZVJRhdrIXgQUgqvmN
4SI2+1NyZ2ElD2drUX4iP/RT9Wn3RXoSoEzFlHCp3fI3ntcrKIuMdOSsmey+YNtw
SLdqkDrcB0RIHPlNKOGqh4W02/eEbo8EVxVTqlTNgNcVbyMds+dWVnjOxapBBTF+
NbzQVR1yaCpf5G6yJYeshmVnmycqJWlQIYof0dEyVgP4vS+SBxARmYa7i7Kag5IV
fn2d0EHb8oRN+385s2RXdjAiUsyRolvnun53MNKHEdPF1SldAgu1+nBHv0VrMHnB
nVbWlhbZV8E9aZOMMVDYEJGkV7JediJFG/EPA+uXpPRndQrxBX2yQmF45Wnj4DwO
pTmPFy5ofbI=
=Dgvh
-----END PGP SIGNATURE-----

--Sig_/4AHJlHyZb0u67dgIaso_LFv--
