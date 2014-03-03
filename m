Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:38230 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751452AbaCCDVX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 2 Mar 2014 22:21:23 -0500
Date: Mon, 3 Mar 2014 14:21:13 +1100
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Simo Sorce <simo@redhat.com>, Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: What does rpc.mountd dlopen() libnfsjunct.so rather than
 libnfsjunct.so.0
Message-ID: <20140303142113.180679fb@notabene.brown>
In-Reply-To: <CD047B67-388C-4848-A020-917E51CF3EB5@oracle.com>
References: <20140226161646.1520358b@notabene.brown>
	<1393425572.18299.157.camel@willson.li.ssimo.org>
	<3A4B7C90-54B8-4373-B751-B02D940199BC@oracle.com>
	<20140227095859.19ba8a87@notabene.brown>
	<CD047B67-388C-4848-A020-917E51CF3EB5@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/o4EeRswe3u34EOj7=N0VQP1"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/o4EeRswe3u34EOj7=N0VQP1
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Thu, 27 Feb 2014 08:57:56 -0800 Chuck Lever <chuck.lever@oracle.com> wro=
te:

>=20
> On Feb 26, 2014, at 2:58 PM, NeilBrown <neilb@suse.de> wrote:
>=20
> > On Wed, 26 Feb 2014 08:02:42 -0800 Chuck Lever <chuck.lever@oracle.com>=
 wrote:
> >=20
> >>=20
> >> On Feb 26, 2014, at 6:39 AM, Simo Sorce <simo@redhat.com> wrote:
> >>=20
> >>> On Wed, 2014-02-26 at 16:16 +1100, NeilBrown wrote:
> >>>> See $SUBJ
> >>>>=20
> >>>> Shared libraries are usually versioned so you can release a new vers=
ion with
> >>>> an incompatible API and gradually transition to it.
> >>>>=20
> >>>> A rpc.mountd dlopens libnfsjunct.so with no version it is effectively
> >>>> prohibited from ever changing the API in an incompatible way.
> >>>>=20
> >>>> Both Fedora and openSUSE get upset about packaging a libFOO.so in a =
non
> >>>> "-devel" package and so trip over this library which clearly needs t=
o be
> >>>> installed even if you aren't doing 'devel'opment.
> >>>=20
> >>> Keep in mind this rule is there only for real shared libraries that a=
re
> >>> loaded by the the system loader.
> >>>=20
> >>> however it is waived for 'modules' that are opened dynamically but are
> >>> private to the application.
> >>>=20
> >>>> I would like to change mountd as per the patch below to use the ".0"=
 file.
> >>>> I believe this will not break any installation as the ".so" is insta=
lled as a
> >>>> symlink to the ".0" (or maybe ".0.0.0").
> >>>>=20
> >>>> Would this be acceptable?
> >>>=20
> >>> It looks to me like this is an internal module for mountd that is not
> >>> for use by other apps (which is why it is not versioned and can be
> >>> changed at will as it is deployed at the same time mountd is ?
> >>=20
> >> The plug-in API is versioned internally, but maybe I got that wrong, a=
nd should remove the API version field in favor of having consumers load vi=
a a specific .so number.
> >=20
> > The problem I see with using the internal versioning is that if the ver=
sion
> > is wrong, mountd fails to provide the required service.
> > So while I don't object to storing the version and performing the test,=
 we
> > should design work-flows so that the test can only fail if there is a s=
erious
> > configuration error, not just during a software upgrade.
> >=20
> >>=20
> >>> Or am I wrong here ?
> >>>=20
> >>> If I am not wrong I would be against this change personally and would
> >>> rather move the .so file in a private library dir (if it is not alrea=
dy
> >>> there) to make it clear it is a private module.
> >>=20
> >> rpc.mountd is the only user currently, but it=E2=80=99s not necessaril=
y private to mountd.  A generic storage manager tool might use it to resolv=
e NFS and FedFS referrals for display, for example.  We could add plug-in A=
PI functions for creating and removing referrals to enable generic tools to=
 perform these operations.
> >=20
> > This is the answer I was looking for to the question I asked earlier - =
thanks.
> > (So this is not an 'intimate library' to use Simo's term - it is truly a
> > shared library).
> >=20
> > If, one day, an incompatible ABI change was needed then we could have an
> > rpc.mountd installed  (or still running) which requires one ABI, and a
> > generic storage manager tool which requires the other.
> > So we really need them to be stored in two different files.
> > e.g. libnfsjunct.so.0 and libnfsjunct.so.1
>=20
> I was hoping this would never happen.  One plug-in library should be able=
 to serve mountd or any other tool that might need to play with junctions.

Certainly that is the hope.  I think everyone who writes a shared library
hopes they will get it right first time, and that if a change is ever needed
then all users can be upgraded simultaneously.

$ ls -l /lib64/lib*.so.1 | grep -c '^-'
4
$ ls -l /lib64/lib*.so.1.* | grep -c '^-'
17
$ ls -l /lib64/lib*.so.[2-9]* | grep -c '^-'
20

That seems to happen often, but not always.  That is why we have shared
library versioning.

>=20
> Only a crazy developer like me would ever need to have more than one libr=
ary version at a time, and even then, it=E2=80=99s pretty simple to build w=
hat I need and reinstall, rather than having more than one installed at a t=
ime.
>=20
> > To put it another way... libnfsjunct really is a shared library.
> > The *only* reason that rpc.mountd treats it differently to other shared
> > libraries is so that it can fail gracefully if the library isn't availa=
ble
> > (thus removing hard dependencies) - a difference that I am very comfort=
able
> > with.
> > In every other way it should be treated like a shared library
> > - it should live in the standard /lib64 or whatever
> > - each application determines at compile-time what version it needs and=
 finds
> >   it by appending the version number to the base file name
> > - the "libfoo.so" file should live in the "-devel" package along with t=
he
> >   include file(s)
> >=20
> >=20
> > So rather than dlopening "libnfsjunct.so.0" rpc.mountd should probably
> > use a library name provided by the include file
>=20
> I=E2=80=99m dense, I still don=E2=80=99t see why this makes a difference.=
  I=E2=80=99ll admit that linker fu is something I=E2=80=99ve left to other=
s, so don=E2=80=99t be afraid to spell it out slowly for me.

I'll try (might make sure I understand it too).
The following is based in part on section 3.1.1 of
http://tldp.org/HOWTO/Program-Library-HOWTO/shared-libraries.html

A shared library (like a cat) has three different names.

1/ The file name.  This is normally /$LIBDIR/libFOO.so.maj.min.release
  (e.g. /usr/lib/libnfsjunct.so.0.0.0), though it can be almost whatever you
  like.   It is used by installers to install the library, and by ldconfig.
  ldconfig only wants it to start "lib" or "ld-" and to have ".so" somewhere
  in the name.

2/ The "soname".  This is /$LIBDIR/libFOO.so.maj (i.e. only major number).
   ldconfig will create a symlink from this name to the "most recent" libra=
ry
   found with that SONAME (a field in the shared library:
         objdump -x $LIBRARY | grep SONAME
   ).
   An application which needs to be linked will contain the "soname" of each
   library that it wants to use. "ldd" lists these and the matching filename
   for each.  ld.so effective calls "dlopen" on each "soname".

3/ The "linker name".  This is the name that is used when you compile code.
   You typically specify "-lFOO" and the linker interprets that at
   "$LIBPATH/libFOO.so" and finds a shared library.  It extracts the SONAME
   from this library and stores that in that generated binary.
   Naturally the library version found at the "linker name" must match the
   include files describing data structures etc in the library.

To follow this pattern as closely as possible, and yet allow rpc.mountd to
use dlopen() to load the library:
 - the "soname" should be passed to dlopen(). (That is what ld.so does)
 - that name should be determined from the compile-time environment. (that =
is
   what 'ld' does).

i.e. we should pass "libnfsjunct.so.0" to dlopen() (if the current
fedfs-utils provides the compile-time environment).  We could determine that
string with a little script which runs

   objdump -x /lib64/libnfsjunct.so | sed -n -e 's/^ *SONAME *//p'

or we could simply keep it in the include file (which must be in-sync with
the .so).

Doing this
 1/ ensures that we have the full flexibility of shared libraries should we
    ever need that.
 2/ makes the nfsjunct library look just like any other shared library and =
so
    avoids confusion for package checkers.

Does that clarify at all?

Thanks,
NeilBrown


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


--Sig_/o4EeRswe3u34EOj7=N0VQP1
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUxP1KTnsnt1WYoG5AQL7tRAAhbSULB0IMzYDQ+kMk+8L9Nz3RgJxQ6kQ
aSKQ0cOfpkJf2xftR0Frl0yzGm98X2kCWgveekKxQ/9Kp3FrOcie/isUmMuSkCI9
kj+2dUysnEdb/mN/iIYHh5NiyJAQ2NEsTJ1s7guDreDH2pO4LFAPvtO7A0JAM7xN
skF2/miKvr1Q0bQPIVdisZZOFU0Zml44JMzXhQ6ScN1edxIHQh1bviaPQbSRh1mU
aeUzAUkoVX8BNpB6NlQ9gMgZnLd3tVdOpyZec9ESVFWOTi3I9MYXPJa8A3tKfbZd
WtVJhuipjbvCIyr3rbsFPIivthMUqSUakn9KqayWt72Lm8FwmxipOPHWDt2JEMge
gKlarZouB+Du1UEvuj2Jz4WxSg3a2uZGunqAEB9nDEWidcUWRAq0JXU0vmPFXu0f
e+ahtSRpZkptk1j9tbjZtIzG1mbX6mL9wmlXkpBEbx7OFjNlQ8JSSEfam/hX3BC9
ArX3Uplbs9Y728P1BQ/ZljQZf/ahpjt108LWTTxS+gHBdx2SvaURun+dKcQjLKsC
ue7mDQ2NNART54zoJwCbhgGBO9OulD2n9phUIpQJaX4s3nKtMaEgYCpb6maQ122L
oyVZjQtwpxtoszjLd3AUYRS1ul5yJ6aKSPUVqnn/9pCn7tR1SM+lQQd9LI4rvwdF
tyDqWRjKHIY=
=PUvP
-----END PGP SIGNATURE-----

--Sig_/o4EeRswe3u34EOj7=N0VQP1--
