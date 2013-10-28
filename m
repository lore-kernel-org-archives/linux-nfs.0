Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:50097 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754546Ab3J1Djh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 27 Oct 2013 23:39:37 -0400
Date: Mon, 28 Oct 2013 14:39:22 +1100
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>, tasleson@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] exportfs: Return non-zero exit value on error
Message-ID: <20131028143922.2131237d@notabene.brown>
In-Reply-To: <AE4061A2-B0F8-4B1D-9381-873E7322FA54@oracle.com>
References: <1380756584-13335-1-git-send-email-tasleson@redhat.com>
	<20131022092519.4f4683a8@notabene.brown>
	<52669862.6030409@redhat.com>
	<20131023124444.65ace6e3@notabene.brown>
	<52680917.4010509@redhat.com>
	<20131024091811.34b06e71@notabene.brown>
	<D9521932-DDAA-47D2-996F-62D2A37BA5B0@oracle.com>
	<52694336.9050303@RedHat.com>
	<AE4061A2-B0F8-4B1D-9381-873E7322FA54@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/lxrD/2S6XFvt4EYkjgFSOdk"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/lxrD/2S6XFvt4EYkjgFSOdk
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 24 Oct 2013 12:05:35 -0400 Chuck Lever <chuck.lever@oracle.com> wro=
te:

>=20
> On Oct 24, 2013, at 11:56 AM, Steve Dickson <SteveD@redhat.com> wrote:
>=20
> >=20
> >=20
> > On 23/10/13 19:31, Chuck Lever wrote:
> >>=20
> >> On Oct 23, 2013, at 6:18 PM, NeilBrown <neilb@suse.de> wrote:
> >>=20
> >>> On Wed, 23 Oct 2013 12:36:23 -0500 Tony Asleson <tasleson@redhat.com>=
 wrote:
> >>>=20
> >>>> On 10/22/2013 08:44 PM, NeilBrown wrote:
> >>>>> On Tue, 22 Oct 2013 10:23:14 -0500 Tony Asleson <tasleson@redhat.co=
m> wrote:
> >>>>>> The reason I chose to return values was to make sure requested ope=
ration
> >>>>>> actually completed requested operation.  Unexporting a non-existent
> >>>>>> export is not considered an error and returns no indication you did
> >>>>>> absolutely nothing.
> >>>>>=20
> >>>>> Hi,
> >>>>> thanks makes sense - I had missed that (even though you explained i=
t in the
> >>>>> patch description :-( )
> >>>>>=20
> >>>>> With your patch, if asked to unexport something that wasn't exporte=
d it
> >>>>> would not report any error, but would exit with an error status.  I=
s that
> >>>>> correct?  I think I would rather have a message printed if there is=
 an error.
> >>>>=20
> >>>> Correct, I only made changes for the exit status.  I was trying to m=
ake
> >>>> changes that would be mostly invisible to end users.  I have no conc=
erns
> >>>> adding a printed error output too, but others may.
> >>>>=20
> >>>> Changing the behavior of any command line tool is potentially
> >>>> problematic when scripted.
> >>>>=20
> >>>>> So would something like this (on top of my patch) address you need,=
 or was
> >>>>> there something else I missed?
> >>>>=20
> >>>> Yes, this should work for the unexport fs case.
> >>>>=20
> >>>> However, the reason my patch was a little more invasive was to ensure
> >>>> that both the export and unexport paths were covered.
> >>>>=20
> >>>> For example, if the strdup call fails in function client_init, we fa=
il
> >>>> the operation and return exit value of 0.  Unlikely, but just the fi=
rst
> >>>> example I stumbled across.
> >>>=20
> >>> I think it is a lot closer to "impossible" than just "unlikely".
> >>> malloc doesn't fail in this sort of context, the OOM killer kills som=
ething
> >>> off instead.
> >>> My personal preference is to replace all malloc/calloc/strdup calls w=
ith
> >>> the xmalloc, xstrdup etc calls in support/nfs/xcommon.c.
> >>> If you are worried about malloc failing, I'd much prefer to see a pat=
ch which
> >>> changes nfs-utils to use those uniformly.
> >>>=20
> >>> There might be a question over the best behaviour for daemons like mo=
untd
> >>> and  gssd.  However as we move towards having systemd manage those, t=
hey will
> >>> be restarted if they ever exit, and they are mostly stateless so that=
 is
> >>> quite safe.
> >>>=20
> >>> Does anyone else have thoughts on this?
> >>=20
> >> Yes.  My thought is "xmalloc is an abomination."  :-)
> >>=20
> >> We really do not want any of these tools exiting left if there's a mem=
ory allocation failure. =20
> >> For a user, that's no better than a segfault.
> > I the past I have agreed with this... But as Neil points out, we now li=
ve in
> > a systemd world were daemons are restarted, so maybe it does make sense=
 to=20
> > exit on these types of failures. With daemons like mountd there is=20
> > really no state that would be lost....=20
>=20
> Neil's arguments are very practical, but ...
>=20
> There are other reasons that malloc() can fail.  Software bugs are high o=
n that list.  It can also fail if user input (or network input) is used to =
determine the requested allocation size.
>=20
> In addition, rpmlint/fedpkg-lint complain if there's an exit(2) call in y=
our linked libraries.  They would frown on xmalloc() invoking exit (they al=
so aren't happy with xlog).
>=20
> Whether or not it's OK for daemons, I still maintain that for administrat=
ive tools run directly by users like exportfs, we want to be more careful. =
 Since the daemons share the same libraries as the user tools, that means x=
malloc and friends should be avoided everywhere, IMO.

I don't follow this argument.  Why do we need to be more careful for
administrative tools?

Tools should always be written to be crash-proof, and I believe exportfs is.
It writes to a temp file and then performs an atomic rename when the new fi=
le
is ready.  If anything goes wrong it is perfectly safe to simply exit, and
the important files will be unchanged.

The memory allocation failures that we are talking about here are for a doz=
en
bytes or so and are extremely are.  I would be a lot more confident in 'exi=
t'
doing the right thing, than in multiple untested error paths carrying the
error up and making sure not to write out the file if the malloc error might
result in it having the wrong value.

(On the question of 'exit' in libraries, I'm ambivalent).

NeilBrown

>=20
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>=20
>=20


--Sig_/lxrD/2S6XFvt4EYkjgFSOdk
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUm3cajnsnt1WYoG5AQLxMw//WZpXzDQ93ZHsCbwCCMmjdpm2rKzvjPJE
WQzazFZljS+by77j8Uud9ww3PnXJdPIQwN0ObC/DR8IQpRkA8z7Jk3ioSLyUjpuV
sYt9I+feO73li6g5Cxf0Lm/xxlw/1ya33mXnLKDF4Aimru2f96LfpeM1ftGSLVDg
EX3YSQWAP0/wqKlsp0z+RoesNoUrkpdQmVxkPa07bNZwR6bWt2iNodzRr5DRsgUM
d5xpidImcQfmtoC86am5WK6MeJbL2HEcAhdsrFuCv5Md2Am9Zlmug8Jb0T7MMwUf
lIiwGzF5wWoJM6f1mrzUpPulGUlNJEKXJzgRPKHTlVZovxltaTVZK5M4t7EzEDL8
6INwmyzCjl6kUlIGMahAsw/m94sJ9tXXj80/V0X/PDff0jpBP1AtlvE7vyWtoic5
jkSAkDYr/seTQG1xlc4woosuKWFhFQBfed07WgefXQR3cjRWohhVSjsu+ypklgqD
nD9pwT96UQkSiteirIFgEq50L2mQvBJeMeMrXqdk22C34eMVb5YPbN4oWzs8GLfC
mqO27QakRw56o9gC515ZLLRAkszZO1fzGubDPO8TSkWFl+MeozdpIFxXhAzAI39V
ebYcngHlqCJ42eXHnLEkVKK8isZCLZlzF2ImQYPo7txG5MQ+LiNaLDJ749/MTIpt
kmIxhzLdmCs=
=womE
-----END PGP SIGNATURE-----

--Sig_/lxrD/2S6XFvt4EYkjgFSOdk--
