Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:54460 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751027Ab3KNBLX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Nov 2013 20:11:23 -0500
Date: Thu, 14 Nov 2013 12:05:33 +1100
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Charles Edward Lever <chuck.lever@oracle.com>,
        Steve Dickson <SteveD@redhat.com>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_secure_mounts bool
Message-ID: <20131114120533.1df06f5c@notabene.brown>
In-Reply-To: <1384306012.15992.9.camel@leira.trondhjem.org>
References: <1384037221-7224-1-git-send-email-steved@redhat.com>
	<E061C7A8-DC27-49BA-93C2-DC2E9C19EA7B@netapp.com>
	<52811CBB.3070204@RedHat.com>
	<E520DD5F-7E5A-4B6C-9FF6-6B74DA36FD1E@oracle.com>
	<5281290B.6000201@RedHat.com>
	<E0FBCF46-C70F-41E5-BA67-48406253CD7E@oracle.com>
	<20131112161135.25a487da@notabene.brown>
	<F58540AB-00BE-4AC5-B823-7260F30F8D58@netapp.com>
	<20131112161634.GC15060@fieldses.org>
	<20131113112346.3f5f3bd0@notabene.brown>
	<1384302651.15992.3.camel@leira.trondhjem.org>
	<20131113121333.2a16f646@notabene.brown>
	<1384306012.15992.9.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/SuTCoi/+i_ZIqe0I2myv=wG"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/SuTCoi/+i_ZIqe0I2myv=wG
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 13 Nov 2013 01:26:56 +0000 "Myklebust, Trond"
<Trond.Myklebust@netapp.com> wrote:

> On Wed, 2013-11-13 at 12:13 +1100, NeilBrown wrote:
> > On Wed, 13 Nov 2013 00:30:53 +0000 "Myklebust, Trond"
> > <Trond.Myklebust@netapp.com> wrote:
> >=20
> > > On Wed, 2013-11-13 at 11:23 +1100, NeilBrown wrote:
> > > > But back to my problem:  Following Trond's suggestion I've come up =
with the
> > > > following patch.  Does it look right?
> > > >=20
> > > > The "fd =3D -1" is just to stop us trying to close a non-open fd in=
 an error
> > > > path.
> > > >=20
> > > > The change from testing ->servicename to ->prog stops us from repea=
ting the
> > > > failed DNS lookup on every request, not that the failure isn't fata=
l.
> > > >=20
> > > > The last stanza makes sure we always reply to an upcall, with EINVA=
L if
> > > > nothing else seems appropriate.
> > >=20
> > > Wouldn't EACCES be more appropriate as a default?
> > >=20
> >=20
> > Maybe.  And that is what you suggested before and I mis-remembered - so=
rry.
> >=20
> > However EACCES is "Permission denied" which doesn't quite seem right to=
 me.
> > It isn't really "you aren't allowed to do that", but "your question doe=
sn't
> > make sense".
> >=20
> > However I'm not fussed.  If you prefer EACCES, then I'll make it EACCES.
>=20
> If you look at gss_pipe_downcall(), then you'll note that it treats
> EINVAL as a temporary error, and converts it to EAGAIN. That again
> causes call_refreshresult to retry the upcall 2 more times before
> failing with EACCES anyway...
>=20

Yes, I see now, thanks.

I also see a 'BUG()' in there if the error code returned from user-space
isn't in the known list.  I suspect that should at most be a WARN, and
probably removed altogether.

Thanks,
NeilBrown

--Sig_/SuTCoi/+i_ZIqe0I2myv=wG
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUoQh3Tnsnt1WYoG5AQLi+g/7B1S3NnEcwN/k/gVBGYrnRsCP758Ida45
m2xp1MyQ0xn0yq6b1rV9baxAEfQBN3OKu7o3EVSSG6HoyoNkXGuwJACzhKwYOmub
leIplyDbZpdyRp/EULRM2MSJ+/vR2vkEopu976mOmzwWy/bpYykQDQXCJhkdlQA7
P8GCxsCC0D+txJy8f21RZT1FFGy0gj3d8ZXhTPYENaVnan5B6Guh/kpgHICTaeiP
OdiYo/5FQLaWbK8l8SctopEzsvB7i0ai9LGp8z2yscLQ8Cce0NPX2JddT6VU32jv
0QoiYPOPKT9vBAcGpHAs98v2nkfzrJjEDkJsTUmrPUCxpxo/nTIgxjKGSH2bFNpp
xhE57Bx3YZHYncuCya9uYYy/SV2jOZvhx20LRb88KGzjG5GQfDmdw7ul2dwN8h4k
HdEffcZ8zg5tyOed79eI+QQKMrbvsLM5ky2wT5qE5LZ1wB2Bopdd7yMvRg+fyLao
Yv72qtodquak3mRexvmQGrnsSIoGGVoIW+ELhWlaa0tUDNJpBAvavP4xohL9V7d8
DDHBhyI+prduASUJMdkejk4j0uc0aaTQ/2sYHt5tEoKnbqrLv9pxHRqEfMVQ1o3l
M3hg98mhWcUndxr153fcaQ1Db1I1/DbDcoQRWDzfI1ajdm6oD3ez79yoTIu07UMU
RysuIvOBIxI=
=S9hp
-----END PGP SIGNATURE-----

--Sig_/SuTCoi/+i_ZIqe0I2myv=wG--
