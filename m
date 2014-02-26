Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:54349 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752658AbaBZW7J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Feb 2014 17:59:09 -0500
Date: Thu, 27 Feb 2014 09:58:59 +1100
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Simo Sorce <simo@redhat.com>, Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: What does rpc.mountd dlopen() libnfsjunct.so rather than
 libnfsjunct.so.0
Message-ID: <20140227095859.19ba8a87@notabene.brown>
In-Reply-To: <3A4B7C90-54B8-4373-B751-B02D940199BC@oracle.com>
References: <20140226161646.1520358b@notabene.brown>
	<1393425572.18299.157.camel@willson.li.ssimo.org>
	<3A4B7C90-54B8-4373-B751-B02D940199BC@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/izf07xjuSshaYKdjfJgCyAh"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/izf07xjuSshaYKdjfJgCyAh
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Wed, 26 Feb 2014 08:02:42 -0800 Chuck Lever <chuck.lever@oracle.com> wro=
te:

>=20
> On Feb 26, 2014, at 6:39 AM, Simo Sorce <simo@redhat.com> wrote:
>=20
> > On Wed, 2014-02-26 at 16:16 +1100, NeilBrown wrote:
> >> See $SUBJ
> >>=20
> >> Shared libraries are usually versioned so you can release a new versio=
n with
> >> an incompatible API and gradually transition to it.
> >>=20
> >> A rpc.mountd dlopens libnfsjunct.so with no version it is effectively
> >> prohibited from ever changing the API in an incompatible way.
> >>=20
> >> Both Fedora and openSUSE get upset about packaging a libFOO.so in a non
> >> "-devel" package and so trip over this library which clearly needs to =
be
> >> installed even if you aren't doing 'devel'opment.
> >=20
> > Keep in mind this rule is there only for real shared libraries that are
> > loaded by the the system loader.
> >=20
> > however it is waived for 'modules' that are opened dynamically but are
> > private to the application.
> >=20
> >> I would like to change mountd as per the patch below to use the ".0" f=
ile.
> >> I believe this will not break any installation as the ".so" is install=
ed as a
> >> symlink to the ".0" (or maybe ".0.0.0").
> >>=20
> >> Would this be acceptable?
> >=20
> > It looks to me like this is an internal module for mountd that is not
> > for use by other apps (which is why it is not versioned and can be
> > changed at will as it is deployed at the same time mountd is ?
>=20
> The plug-in API is versioned internally, but maybe I got that wrong, and =
should remove the API version field in favor of having consumers load via a=
 specific .so number.

The problem I see with using the internal versioning is that if the version
is wrong, mountd fails to provide the required service.
So while I don't object to storing the version and performing the test, we
should design work-flows so that the test can only fail if there is a serio=
us
configuration error, not just during a software upgrade.

>=20
> > Or am I wrong here ?
> >=20
> > If I am not wrong I would be against this change personally and would
> > rather move the .so file in a private library dir (if it is not already
> > there) to make it clear it is a private module.
>=20
> rpc.mountd is the only user currently, but it=E2=80=99s not necessarily p=
rivate to mountd.  A generic storage manager tool might use it to resolve N=
FS and FedFS referrals for display, for example.  We could add plug-in API =
functions for creating and removing referrals to enable generic tools to pe=
rform these operations.

This is the answer I was looking for to the question I asked earlier - than=
ks.
(So this is not an 'intimate library' to use Simo's term - it is truly a
shared library).

If, one day, an incompatible ABI change was needed then we could have an
rpc.mountd installed  (or still running) which requires one ABI, and a
generic storage manager tool which requires the other.
So we really need them to be stored in two different files.
e.g. libnfsjunct.so.0 and libnfsjunct.so.1


To put it another way... libnfsjunct really is a shared library.
The *only* reason that rpc.mountd treats it differently to other shared
libraries is so that it can fail gracefully if the library isn't available
(thus removing hard dependencies) - a difference that I am very comfortable
with.
In every other way it should be treated like a shared library
 - it should live in the standard /lib64 or whatever
 - each application determines at compile-time what version it needs and fi=
nds
   it by appending the version number to the base file name
 - the "libfoo.so" file should live in the "-devel" package along with the
   include file(s)


So rather than dlopening "libnfsjunct.so.0" rpc.mountd should probably
use a library name provided by the include file

Thanks,
NeilBrown

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index ca35de28847a..1a8c20492869 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -1139,7 +1139,11 @@ static struct exportent *lookup_junction(char *dom, =
const char *pathname,
 	struct link_map *map;
 	void *handle;
=20
-	handle =3D dlopen("libnfsjunct.so", RTLD_NOW);
+#ifdef JP_LIB_NAME
+	handle =3D dlopen(JP_LIB_NAME, RTLD_NOW);
+#else
+	handle =3D dlopen("libnfsjunct.so.0", RTLD_NOW);
+#endif
 	if (handle =3D=3D NULL) {
 		xlog(D_GENERAL, "%s: dlopen: %s", __func__, dlerror());
 		return NULL;

--Sig_/izf07xjuSshaYKdjfJgCyAh
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUw5xsznsnt1WYoG5AQJq/A//Xa1wDbsRm76uvRi5+9b9p8TZ2TUUI3wN
PMXAOQnpt9SXJVkU71PwNKdkzzDHyB5ppaInMzI1t9OHKbTZPC6EgyQ82Tr6sGPA
w5C+WL4o1PEADf8IeOe/ksajAontf6TmRmH1eP365jdc1bz8P5peuqiNDvGcmQay
Ie4UuSW6V/CQChSIYcPWg7NUJtoO86iD2z85A7s29iDI4lp+KcdeMg3G5XcFujAi
jJf2PSjVIVP3R5Kbjejmw293UIA9QqDIvyTUcLVHZIqMl8TLWq6UPA3kHPGoIEpL
fjZHwO07HTiJ0yjciKLt2GZiGZQcXDU1NMfewCcNlgAWleq9GRjd1FjoelVkqqVt
cSFAp6Q4brRCsZc4AXDxZa6L3Pca2wIeJl+7QY0NXLJ1VRjsgOmN7eHJHkCjBuvO
s5UrHIAov05lnf9nHx93XRxBvwmglsqJlzJpg4DSNtAtFfs9s5FoqGsHCBtck4EB
2FxANktue7bj2qX21qeuk/H3PAG7vA23LHrVM0AG+DSnzoc0viUROn9bSI/wZ8wX
54mJZwxbm1fiVi3uZKcRjJfRRPRR989l9bGy8gcx9oHlL9NI2Ku5JQU+WS+8pCpX
/HrBow4NWDlOQYyPQnlwQb5ALCObJJZ/07vg5v8Hi8HzTrvT5qmUScKjuEtQu0dH
MRWMXx830Gg=
=zkEz
-----END PGP SIGNATURE-----

--Sig_/izf07xjuSshaYKdjfJgCyAh--
