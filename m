Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:35046 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750712AbaBZFQ6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Feb 2014 00:16:58 -0500
Date: Wed, 26 Feb 2014 16:16:46 +1100
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>
Subject: What does rpc.mountd dlopen() libnfsjunct.so rather than
 libnfsjunct.so.0
Message-ID: <20140226161646.1520358b@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/w+YUM63fnP6pqkwvN1f16Y9"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/w+YUM63fnP6pqkwvN1f16Y9
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


See $SUBJ

Shared libraries are usually versioned so you can release a new version with
an incompatible API and gradually transition to it.

A rpc.mountd dlopens libnfsjunct.so with no version it is effectively
prohibited from ever changing the API in an incompatible way.

Both Fedora and openSUSE get upset about packaging a libFOO.so in a non
"-devel" package and so trip over this library which clearly needs to be
installed even if you aren't doing 'devel'opment.

I would like to change mountd as per the patch below to use the ".0" file.
I believe this will not break any installation as the ".so" is installed as=
 a
symlink to the ".0" (or maybe ".0.0.0").

Would this be acceptable?

There is a bit of a discussion about this here:
  https://bugzilla.redhat.com/show_bug.cgi?id=3D889174

but I either don't understand it or don't agree with it.

Thanks,
NeilBrown


diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index ca35de28847a..f6d78490954f 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -1139,7 +1139,7 @@ static struct exportent *lookup_junction(char *dom, c=
onst char *pathname,
 	struct link_map *map;
 	void *handle;
=20
-	handle =3D dlopen("libnfsjunct.so", RTLD_NOW);
+	handle =3D dlopen("libnfsjunct.so.0", RTLD_NOW);
 	if (handle =3D=3D NULL) {
 		xlog(D_GENERAL, "%s: dlopen: %s", __func__, dlerror());
 		return NULL;

--Sig_/w+YUM63fnP6pqkwvN1f16Y9
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUw14vjnsnt1WYoG5AQLwSRAAm5kYE8FsyFONmXaeTgtyg74sm1SmZhKq
ed3Kvz0yDn5a3IV1M54TTbI/TWr6temJxsw2ceKZ4cno0laVKt36mrrwimBLEmiY
GBrKz/0UJWVqYLiK+CJ5pxBifZawegH+dwgPwl1Qik0pV0uGDwsB194zXMru76+u
3oiBItgtP63KTCOo5ZvFnXBeevPHm0eFvowf0oMOmHK75oNAIrT1/xdNb12ANXa6
tFAS4iC69Wt3ewZ9orLuUzG1X85tcKpzKA9kw03ndMQMcEGkKR/q9PxUa9RyRCZq
Hk8Sgsgdy0d2QuT7YShU2y8clHF3E2eDwjOgl6me7H+5QWQGkshHjakF6OqDURax
oLVsgcgbuyySdum/iUd5/QEyngYqXR84LwPIo8ey024niwPDVbg3iVyNI94TMyc2
q9+zuqWZuz/eF/QHg7cBOQI84eZDkjSk40khhtL+Mapxkn+VwDQehE5bvfsufxjx
fNcKW5BvIC51I5Qjxfn8tTuhaqh3eX8S0WY+uq/v0XlLbpUMP5rV65bQvW0/y3Hv
NWlRRCpg5acdyinBq3c7OnSO9ZE9uv6DQnfqBUc+MARHCVRL3tSIC1ySVIYE4K3z
pZnnBGWnniiouw6JlkM9PoivXdd4MS469STQ2Pp2OIwNLoQXjyOt40CoeMxG6p84
SL9EVLXdNFk=
=Tc/e
-----END PGP SIGNATURE-----

--Sig_/w+YUM63fnP6pqkwvN1f16Y9--
