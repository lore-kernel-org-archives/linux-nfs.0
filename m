Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:56164 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751581AbaCGXmi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Mar 2014 18:42:38 -0500
Date: Sat, 8 Mar 2014 10:42:28 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jim Rees <rees@umich.edu>, Dickson Steve <steved@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] fix intr/nointr to match kernel behavior (ignored)
Message-ID: <20140308104228.4bfcd3d5@notabene.brown>
In-Reply-To: <D65A0AA5-ADF9-43AA-871F-69533C8F2DD7@primarydata.com>
References: <1394143352-26095-1-git-send-email-rees@umich.edu>
	<20140307185937.5852666b@notabene.brown>
	<D65A0AA5-ADF9-43AA-871F-69533C8F2DD7@primarydata.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/nyD0a_/3wkYOKkJLKqgj/Yr"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/nyD0a_/3wkYOKkJLKqgj/Yr
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Fri, 7 Mar 2014 08:13:00 -0500 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

>=20
> On Mar 7, 2014, at 2:59, NeilBrown <neilb@suse.de> wrote:
>=20
> > On Thu,  6 Mar 2014 17:02:32 -0500 Jim Rees <rees@umich.edu> wrote:
> >=20
> >> Signed-off-by: Jim Rees <rees@umich.edu>
> >> ---
> >> utils/mount/nfs.man | 53 ++++++---------------------------------------=
--------
> >> 1 file changed, 6 insertions(+), 47 deletions(-)
> >>=20
> >> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
> >> index ef09a31..2ab369c 100644
> >> --- a/utils/mount/nfs.man
> >> +++ b/utils/mount/nfs.man
> >> @@ -125,6 +125,12 @@ option may mitigate some of the risks of using the
> >> .B soft
> >> option.
> >> .TP 1.5i
> >> +.BR intr " / " nointr
> >> +This option is provided for backward compatibility.
> >> +It is ignored after kernel 2.6.25.
> >> +System calls return EINTR if an in-progress NFS operation is interrup=
ted by
> >> +a signal.
> >=20
> > That isn't correct.
> > "A process that is waiting for a reply for an NFS server can be killed
> > by any signal which would normally kill the process.  If a signal would=
 not
> > normally kill the process (i.e. it is caught or ignored) then that sign=
al
> > will not abort and NFS request".
> >=20
> > This is really a fairly horrible semantic.  It makes perfect sense from=
 an
> > internal implementation perspective and provides good backwards compati=
bility
> > and cross-compatibility with other filesystems (where 'read' and 'write'
> > never ever return EINTR), but it is very hard to document clearly.
> >=20
> Isn=E2=80=99t the documentation in the signal(7) manpage sufficient? We c=
ould simply refer to that=E2=80=A6
>=20

I would certainly be good if we could delegation the documentation.  But I
couldn't find anything in signal(7) that seemed particularly relevant. Which
bit were you thinking of?

Thanks,
NeilBrown

--Sig_/nyD0a_/3wkYOKkJLKqgj/Yr
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUxpZZDnsnt1WYoG5AQIJMA/+IrVJcsuTi0fwCA2NWWX8RRLUCb5o/iU3
Qg1w9y+ivExmhpUEpbSoe/cFjzxzuHj9S5TfFcrsQzeI/M7wutvuaVyqmI8o8CN/
92dBVsUBTr4Vsri3kvGO9ZtH3CoJiwjPRmhI4pV3rXDH/6PPsEHvUbwbfpgdZiJv
rzYHVxserJYU4Razi2RUTdKh2sPix41yvq+c8125oGSRhNGAa+EsCJwu8/Vbu1js
ML4pIMa8HF/JH5S4armLMGzb4MY7fuGPBPkcCP6GJMrNJzn7br6/CYqjqtziPIO9
analHg5stOQ6H2rJu89xhxg++pDs72rvj3657DBmgeiXmL/rs+83cqiTzbC0BBPB
TaYlHNCrb0jTjpyXpp4QP6S8XYoEel+FfOpQ4UNdgtwxkfaVwzM1W6atgZeNLe4+
wpCGd8xRu3dVah8qFOtK6inYnRaNbTOGTQyvCqnZv9KyJab7Yf5dgmCIncWOwVzD
1PDzpb/aOQo8wlTwDomw8RUGqcUFZNl44dkGTwP6Csh/ruMZo8BbsWsiUsXRL/Fa
FralLIgBYvVZPfrCgA0xzuQxbfHZiOBWfxXBnQvN0lIKa/VB0W7TyR+DUepA6mlf
URDrQAKOobEVAl/GG+9BKBpVZLxvmpipms4taM/mlsOy45Anx3DS6tWfpyEJY6Jh
ScZ6m/SP2B0=
=KyFK
-----END PGP SIGNATURE-----

--Sig_/nyD0a_/3wkYOKkJLKqgj/Yr--
