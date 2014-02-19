Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:39161 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751100AbaBSWUM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Feb 2014 17:20:12 -0500
Date: Thu, 20 Feb 2014 09:19:48 +1100
From: NeilBrown <neilb@suse.de>
To: Simo Sorce <simo@redhat.com>
Cc: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] rpc-svcgssd.service: removed a the start up
 triggers
Message-ID: <20140220091948.47220660@notabene.brown>
In-Reply-To: <1392825816.22754.158.camel@willson.li.ssimo.org>
References: <1392713329-17979-1-git-send-email-steved@redhat.com>
	<1392713329-17979-2-git-send-email-steved@redhat.com>
	<20140219141712.54cb31a7@notabene.brown>
	<1392825816.22754.158.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/fgG=n.EuOko89SkPGOv9LdS"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/fgG=n.EuOko89SkPGOv9LdS
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 19 Feb 2014 11:03:36 -0500 Simo Sorce <simo@redhat.com> wrote:

> On Wed, 2014-02-19 at 14:17 +1100, NeilBrown wrote:
> > On Tue, 18 Feb 2014 03:48:48 -0500 Steve Dickson <steved@redhat.com> wr=
ote:
> >=20
> > > The file /proc/net/rpc/use-gss-proxy exists whether
> > > gss-proxy is or is not installed. So is existence
> > > can not be used as start up trigger.
> > >=20
> > > Signed-off-by: Steve Dickson <steved@redhat.com>
> > > ---
> > >  systemd/rpc-svcgssd.service | 1 -
> > >  1 file changed, 1 deletion(-)
> > >=20
> > > diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
> > > index 6bd4588..8e10b98 100644
> > > --- a/systemd/rpc-svcgssd.service
> > > +++ b/systemd/rpc-svcgssd.service
> > > @@ -7,7 +7,6 @@ PartOf=3Dnfs-utils.service
> > > =20
> > >  After=3Dgssproxy.service
> > >  ConditionPathExists=3D|!@localstatedir@/run/gssproxy.pid
> > > -ConditionPathExists=3D|!/proc/net/rpc/use-gss-proxy
> > >  ConditionPathExists=3D/etc/krb5.keytab
> > > =20
> > >  [Service]
> >=20
> > This is testing for non-existence, not existence.
> >=20
> > We need rpc-svcgssd unless gssproxy can perform that task for us, in wh=
ich
> > case we don't want rpc-svcgssd.
> >=20
> > gssproxy can only perform the task for us if:
> >  1/ it is running (hence the test on the pid file)
>=20
> could be stale

Agreed.  But it is the best we have.  Systemd doesn't support
   ConditionUnitActive
or similar.

>=20
> >  2/ the kernel knows how to talk to it (hence the test on use-gss-proxy)
>=20
> use-gss-proxy is always available whether gss-proxy is being used or not
> as it is the interface used by gss-proxy to tell the kernel it is in
> use.

It is not available in linux 3.9 or earlier.

>=20
> > With you version, if gssproxy were running on a kernel which did not in=
clude
> > support for nfsd talking to gssproxy, then rpc-svcgssd would fail to st=
art,
> > which isn't what we want.
>=20
> True the right way to handle this would probably be to
> make /proc/net/rpc/use-gss-proxy readable and start rpc.svcgssd if the
> value is 0 ?

Pity systemd doesn't have

   ConditionPathIsFileContaining

Even udev has that!


>=20
> > This may be an unusual configuration but unless it is an impossible
> > configuration I would rather the code remained as it was.
> > (This should work on *all* distros, not just sane distros).
>=20
> I agree with the sentiment.

Thanks,

NeilBrown



>=20
> Simo.
>=20


--Sig_/fgG=n.EuOko89SkPGOv9LdS
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIUAwUBUwUuEDnsnt1WYoG5AQKBog/3TPqfqyf7R/lyj9eXcafX07fQCWjnwNJt
iwi3h7SKuLZDy48CNbJX85gdX8pWO4h8DvilDcIzzxI9c3OQ1ocgaUXnodqwTDPL
hNAxYPVnfNs5R15RShZMmrDLrVTScvVgNOvpnetKk5WqlxRP+mhoV6srcAOkZpS/
wfM/Vx5dqlmRNDlszaIlktdhaWvhMsFN6qQUlLphJUSwhb1YkXvfhIhW9qjn/Nh1
f6XVIlMrX/AAUtoJMLTqDL2Xha7EJHL3y0q8mYHkvowzUiTC0ATIU51BfESzWFyT
uGGeu1zI9EZOAIbM+mWy24Fe8b5o+57cagv+YAL+GBlZfvxhlY8yEn6mCcW35o6Y
3+sRTdL/NKtLFih8qTz6nJu3L2utZ5Zh1lv7uEL04D8dFDwmEYYlFyDOTJ3XhbDc
T2SekmiLJcHl9uUAIhQ7zbsgdk50D6qSab7C8EEL6b7XMm7MvLfJ0497nFRPgyk+
fzCXo1vlTO61i8LphZlC3xSf3LTdKVuQlfKcFQSh5P/9Y++NtS9DXUH3u2Ryi0/J
X+p7wEKltmf0+K4qX5at+ZjvXPpb+iwpEI7OqnAUvSK5aTrpj8kFuLiF/YGmOCnv
YBNPqbvtt7yoMV4ItEYCMSNKF9yidylZiIV9hoOD6o2EI9P+On+bO61kU0gPVJS4
qg1pTFaiDA==
=VCZH
-----END PGP SIGNATURE-----

--Sig_/fgG=n.EuOko89SkPGOv9LdS--
