Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:55983 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755009AbaCCWm0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Mar 2014 17:42:26 -0500
Date: Tue, 4 Mar 2014 09:42:16 +1100
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Simo Sorce <simo@redhat.com>, Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: What does rpc.mountd dlopen() libnfsjunct.so rather than
 libnfsjunct.so.0
Message-ID: <20140304094216.0c587480@notabene.brown>
In-Reply-To: <CB870329-4F13-49BC-9D10-A02BD4DDB680@oracle.com>
References: <20140226161646.1520358b@notabene.brown>
	<1393425572.18299.157.camel@willson.li.ssimo.org>
	<3A4B7C90-54B8-4373-B751-B02D940199BC@oracle.com>
	<20140227095859.19ba8a87@notabene.brown>
	<CD047B67-388C-4848-A020-917E51CF3EB5@oracle.com>
	<20140303142113.180679fb@notabene.brown>
	<CB870329-4F13-49BC-9D10-A02BD4DDB680@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/0jh5lWTsZO/Ix+f4DOPMKOf"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/0jh5lWTsZO/Ix+f4DOPMKOf
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Mon, 3 Mar 2014 12:45:55 -0500 Chuck Lever <chuck.lever@oracle.com> wrot=
e:

>=20
> On Mar 2, 2014, at 10:21 PM, NeilBrown <neilb@suse.de> wrote:
>=20
> > On Thu, 27 Feb 2014 08:57:56 -0800 Chuck Lever <chuck.lever@oracle.com>=
 wrote:
> >=20
> >>=20
> >> On Feb 26, 2014, at 2:58 PM, NeilBrown <neilb@suse.de> wrote:
> >>=20
> >>> On Wed, 26 Feb 2014 08:02:42 -0800 Chuck Lever <chuck.lever@oracle.co=
m> wrote:
> >>>=20
> >>>>=20
> >>>> On Feb 26, 2014, at 6:39 AM, Simo Sorce <simo@redhat.com> wrote:
> >>>>=20
> >>>>> On Wed, 2014-02-26 at 16:16 +1100, NeilBrown wrote:
> >>>>>> See $SUBJ
> >>>>>>=20
> >>>>>> Shared libraries are usually versioned so you can release a new ve=
rsion with
> >>>>>> an incompatible API and gradually transition to it.
> >>>>>>=20
> >>>>>> A rpc.mountd dlopens libnfsjunct.so with no version it is effectiv=
ely
> >>>>>> prohibited from ever changing the API in an incompatible way.
> >>>>>>=20
> >>>>>> Both Fedora and openSUSE get upset about packaging a libFOO.so in =
a non
> >>>>>> "-devel" package and so trip over this library which clearly needs=
 to be
> >>>>>> installed even if you aren't doing 'devel'opment.
> >>>>>=20
> >>>>> Keep in mind this rule is there only for real shared libraries that=
 are
> >>>>> loaded by the the system loader.
> >>>>>=20
> >>>>> however it is waived for 'modules' that are opened dynamically but =
are
> >>>>> private to the application.
> >>>>>=20
> >>>>>> I would like to change mountd as per the patch below to use the ".=
0" file.
> >>>>>> I believe this will not break any installation as the ".so" is ins=
talled as a
> >>>>>> symlink to the ".0" (or maybe ".0.0.0").
> >>>>>>=20
> >>>>>> Would this be acceptable?
> >>>>>=20
> >>>>> It looks to me like this is an internal module for mountd that is n=
ot
> >>>>> for use by other apps (which is why it is not versioned and can be
> >>>>> changed at will as it is deployed at the same time mountd is ?
> >>>>=20
> >>>> The plug-in API is versioned internally, but maybe I got that wrong,=
 and should remove the API version field in favor of having consumers load =
via a specific .so number.
> >>>=20
> >>> The problem I see with using the internal versioning is that if the v=
ersion
> >>> is wrong, mountd fails to provide the required service.
> >>> So while I don't object to storing the version and performing the tes=
t, we
> >>> should design work-flows so that the test can only fail if there is a=
 serious
> >>> configuration error, not just during a software upgrade.
> >>>=20
> >>>>=20
> >>>>> Or am I wrong here ?
> >>>>>=20
> >>>>> If I am not wrong I would be against this change personally and wou=
ld
> >>>>> rather move the .so file in a private library dir (if it is not alr=
eady
> >>>>> there) to make it clear it is a private module.
> >>>>=20
> >>>> rpc.mountd is the only user currently, but it=E2=80=99s not necessar=
ily private to mountd.  A generic storage manager tool might use it to reso=
lve NFS and FedFS referrals for display, for example.  We could add plug-in=
 API functions for creating and removing referrals to enable generic tools =
to perform these operations.
> >>>=20
> >>> This is the answer I was looking for to the question I asked earlier =
- thanks.
> >>> (So this is not an 'intimate library' to use Simo's term - it is trul=
y a
> >>> shared library).
> >>>=20
> >>> If, one day, an incompatible ABI change was needed then we could have=
 an
> >>> rpc.mountd installed  (or still running) which requires one ABI, and a
> >>> generic storage manager tool which requires the other.
> >>> So we really need them to be stored in two different files.
> >>> e.g. libnfsjunct.so.0 and libnfsjunct.so.1
> >>=20
> >> I was hoping this would never happen.  One plug-in library should be a=
ble to serve mountd or any other tool that might need to play with junction=
s.
> >=20
> > Certainly that is the hope.  I think everyone who writes a shared libra=
ry
> > hopes they will get it right first time, and that if a change is ever n=
eeded
> > then all users can be upgraded simultaneously.
> >=20
> > $ ls -l /lib64/lib*.so.1 | grep -c '^-'
> > 4
> > $ ls -l /lib64/lib*.so.1.* | grep -c '^-'
> > 17
> > $ ls -l /lib64/lib*.so.[2-9]* | grep -c '^-'
> > 20
> >=20
> > That seems to happen often, but not always.  That is why we have shared
> > library versioning.
> >=20
> >>=20
> >> Only a crazy developer like me would ever need to have more than one l=
ibrary version at a time, and even then, it=E2=80=99s pretty simple to buil=
d what I need and reinstall, rather than having more than one installed at =
a time.
> >>=20
> >>> To put it another way... libnfsjunct really is a shared library.
> >>> The *only* reason that rpc.mountd treats it differently to other shar=
ed
> >>> libraries is so that it can fail gracefully if the library isn't avai=
lable
> >>> (thus removing hard dependencies) - a difference that I am very comfo=
rtable
> >>> with.
> >>> In every other way it should be treated like a shared library
> >>> - it should live in the standard /lib64 or whatever
> >>> - each application determines at compile-time what version it needs a=
nd finds
> >>>  it by appending the version number to the base file name
> >>> - the "libfoo.so" file should live in the "-devel" package along with=
 the
> >>>  include file(s)
> >>>=20
> >>>=20
> >>> So rather than dlopening "libnfsjunct.so.0" rpc.mountd should probably
> >>> use a library name provided by the include file
> >>=20
> >> I=E2=80=99m dense, I still don=E2=80=99t see why this makes a differen=
ce.  I=E2=80=99ll admit that linker fu is something I=E2=80=99ve left to ot=
hers, so don=E2=80=99t be afraid to spell it out slowly for me.
> >=20
> > I'll try (might make sure I understand it too).
> > The following is based in part on section 3.1.1 of
> > http://tldp.org/HOWTO/Program-Library-HOWTO/shared-libraries.html
> >=20
> > A shared library (like a cat) has three different names.
> >=20
> > 1/ The file name.  This is normally /$LIBDIR/libFOO.so.maj.min.release
> >  (e.g. /usr/lib/libnfsjunct.so.0.0.0), though it can be almost whatever=
 you
> >  like.   It is used by installers to install the library, and by ldconf=
ig.
> >  ldconfig only wants it to start "lib" or "ld-" and to have ".so" somew=
here
> >  in the name.
> >=20
> > 2/ The "soname".  This is /$LIBDIR/libFOO.so.maj (i.e. only major numbe=
r).
> >   ldconfig will create a symlink from this name to the "most recent" li=
brary
> >   found with that SONAME (a field in the shared library:
> >         objdump -x $LIBRARY | grep SONAME
> >   ).
> >   An application which needs to be linked will contain the "soname" of =
each
> >   library that it wants to use. "ldd" lists these and the matching file=
name
> >   for each.  ld.so effective calls "dlopen" on each "soname".
> >=20
> > 3/ The "linker name".  This is the name that is used when you compile c=
ode.
> >   You typically specify "-lFOO" and the linker interprets that at
> >   "$LIBPATH/libFOO.so" and finds a shared library.  It extracts the SON=
AME
> >   from this library and stores that in that generated binary.
> >   Naturally the library version found at the "linker name" must match t=
he
> >   include files describing data structures etc in the library.
> >=20
> > To follow this pattern as closely as possible, and yet allow rpc.mountd=
 to
> > use dlopen() to load the library:
> > - the "soname" should be passed to dlopen(). (That is what ld.so does)
> > - that name should be determined from the compile-time environment. (th=
at is
> >   what 'ld' does).
> >=20
> > i.e. we should pass "libnfsjunct.so.0" to dlopen() (if the current
> > fedfs-utils provides the compile-time environment).  We could determine=
 that
> > string with a little script which runs
> >=20
> >   objdump -x /lib64/libnfsjunct.so | sed -n -e 's/^ *SONAME *//p'
> >=20
> > or we could simply keep it in the include file (which must be in-sync w=
ith
> > the .so).
> >=20
> > Doing this
> > 1/ ensures that we have the full flexibility of shared libraries should=
 we
> >    ever need that.
> > 2/ makes the nfsjunct library look just like any other shared library a=
nd so
> >    avoids confusion for package checkers.
> >=20
> > Does that clarify at all?
>=20
> Thank you Neil, it=E2=80=99s coming into focus for me.
>=20
> We had some conversation about this at Connectathon last week. It seems l=
ike a better design would look like:
>=20
>   o  A separate directory under /usr/lib{64} where fedfs-utils would inst=
all its plug-ins

While I don't object to this I wonder if it is worth the effort.
Using a subdirectory would require rpc.mountd to know exactly what the full
path was, and so would need to know if "64" was needed etc.
 dlopen("fedfs-plugin/libfoo.so.1")
will not follow the standard search path (no search happens at all if a '/'
is present), and
 dlopen("libfoo.so.1")
does not search subdirectories.

When I look in /lib64 on my machine I find, for example

libnss_compat-2.18.so  libnss_files.so.2          libnss_mdns6_minimal.so.2
libnss_compat.so.2     libnss_hesiod-2.18.so      libnss_mdns_minimal.so.2
libnss_db-2.18.so      libnss_hesiod.so.2         libnss_nis-2.18.so
libnss_db.so.2         libnss_mdns.so.2           libnss_nis.so.2
libnss_dns-2.18.so     libnss_mdns4.so.2          libnss_nisplus-2.18.so
libnss_dns.so.2        libnss_mdns4_minimal.so.2  libnss_nisplus.so.2
libnss_files-2.18.so   libnss_mdns6.so.2

which are all 'nss' plugins which a dlopen()ed by nsswitch.  There is also
 libdevmapper-event-*.so*
which are plugins loaded as needed by dmeventd.  So there is clear precedent
for pluggins living directly in /lib64 (or similar).

There are a few directories in /lib64:

32/.  ast/.  device-mapper/.  engines/.  ksh/.  multipath/.  security/.


Of these only 32, ast, and ksh (which is a symlink to ast) contain files wi=
th
"soname" names.

/usr/lib contains a few more directories with soname files:
 sane sasl2 qtcreator
being the largest.

So there is also some precedent for putting plugins in sub-directories.

I had a look at the code for sane, and it duplicates the searching of
LD_LIBRARY_PATH (if set) from ld.so, and requires 'configure' to work out
the correct libdir, to which it appends "/sane".
It looks like a lot of complexity that I would rather avoid myself....



>=20
>   o  Plug-in consumers would dlopen() via the plug-in library's soname to=
 guarantee ABI compatibility
>=20
>   o  The API version field would be deprecated
>=20
>   o  We didn=E2=80=99t discuss how consumers discover the plug-in soname,=
 but if the API is defined in the header and the soname has to match, maybe=
 that=E2=80=99s the way to go
>=20
> I don=E2=80=99t think any of these changes would alter the =E2=80=9Cloose=
-ness=E2=80=9D of current coupling between rpc.mountd and the plug-in libra=
ry (to address Steve=E2=80=99s concern), but they would make a better guara=
ntee that mountd was loading the correct plug-in library version.

All the rest I completely agree with.

>=20
> I=E2=80=99m not sure exactly how to get from point A to point B. Probably=
 fedfs-utils would have to package the plug-in library in the old and new p=
laces until all distributed versions of mountd was changed to find the plug=
-ins in the right place. That would have to be the case to allow nfs-utils =
downgrades for a particular distribution.
>=20

One option would before the next fedfs release to update the major version =
of
libnfsjunct to '1' and to discard the API version field and include the
soname in the include file.

Then nfs-utils can determine at build time whether .0 or .1 is present
(probably via some #define in the include file) and load the appropriate on=
e.
Then distros can install the .0 shared library where it is expected, and
the .1 shared library where that is expected.
There would be no need to install the same version at two different locatio=
ns.
(Distros are already, presumably, quite capable of install multiple versions
of shared libraries).

It would require having two source packages for fedfs, so maybe it would end
up a bit awkward ... not sure.


Thanks,
NeilBrown

>=20
>=20
>=20
> >=20
> > Thanks,
> > NeilBrown
> >=20
> >=20
> >>>=20
> >>> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> >>> index ca35de28847a..1a8c20492869 100644
> >>> --- a/utils/mountd/cache.c
> >>> +++ b/utils/mountd/cache.c
> >>> @@ -1139,7 +1139,11 @@ static struct exportent *lookup_junction(char =
*dom, const char *pathname,
> >>> 	struct link_map *map;
> >>> 	void *handle;
> >>>=20
> >>> -	handle =3D dlopen("libnfsjunct.so", RTLD_NOW);
> >>> +#ifdef JP_LIB_NAME
> >>> +	handle =3D dlopen(JP_LIB_NAME, RTLD_NOW);
> >>> +#else
> >>> +	handle =3D dlopen("libnfsjunct.so.0", RTLD_NOW);
> >>> +#endif
> >>> 	if (handle =3D=3D NULL) {
> >>> 		xlog(D_GENERAL, "%s: dlopen: %s", __func__, dlerror());
> >>> 		return NULL;
> >>=20
> >> --
> >> Chuck Lever
> >> chuck[dot]lever[at]oracle[dot]com
> >>=20
> >>=20
> >=20
>=20
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>=20
>=20


--Sig_/0jh5lWTsZO/Ix+f4DOPMKOf
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUxUFSDnsnt1WYoG5AQJ6wxAAgx6JFS69UKFkBWBiuCt6xsscBrBcEVQ+
i/8/Syj9nEx+KHm7ozHelm/EpiI3/njXMrUmGgYphSM0NjKtexhQTRYJ68pX4Owc
g6PFyu9y4OwA5MHWGyRQUhQ6S8/IBcU3llUZgi+jfNabuFr6uCZ7a3NK4rqJIvYz
JLhtS1C6EDs62FVem6lCCgM/T183v4lFWGq2zUOxO2GCoQQaL1gSn/hdWCK2NQws
K7PkCQix7oT7VswHmlHJpnKLiNjJBI5bq0mWQUIjckhVRnvLXw7BQp+mvZ90QhIN
qHSgCxq1k3PrK19zOlin+qPpBxhdYs3bWPtpNzZNpRxOYsSRbOOAEocev8+sJg/w
/2J4TmofHZ2sj/xw1siIFQp+CE4FhWPRAKzGxQPUDHbYVdAHj0hA6PT4cLDUHNCK
ig1RhE2i+RTfkT1SvO5LB6EjNJX9PtutnA7ZnEvwfSgVL3PLML4V+vUZ8XCmzXug
aECLL7RYgQHXU27nEEt44lwMWMv5oPFAmQr8Dkam8spVpImwQTaKnVbzQz1+woUU
/elAi3jb/Alsvr9Ol3vIherjniGbBZqwuCelg8eyxjZ7ERLjR3uOgMMUqFZKonux
kxmfycBjOc+5ig/i+grOfgtRuUean1+mcztuSKk1X+zmCswaW9Yj++pipRzIXlno
l20sWan1IbQ=
=r3lv
-----END PGP SIGNATURE-----

--Sig_/0jh5lWTsZO/Ix+f4DOPMKOf--
