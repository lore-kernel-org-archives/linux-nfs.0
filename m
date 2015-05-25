Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:55443 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751548AbbEYCMc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 24 May 2015 22:12:32 -0400
Date: Mon, 25 May 2015 12:12:23 +1000
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Thorsten Kukuk <kukuk@suse.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: New libtirpc vs fedfs-utils.
Message-ID: <20150525121223.0c9d2cd6@notabene.brown>
In-Reply-To: <A2BEDA4A-5064-4715-A49B-ABA7247BF7DB@oracle.com>
References: <20150522135442.048de45d@notabene.brown>
	<A2BEDA4A-5064-4715-A49B-ABA7247BF7DB@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/YAKf1POr4k15dPLt7eejYLr"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/YAKf1POr4k15dPLt7eejYLr
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Fri, 22 May 2015 10:25:20 -0400 Chuck Lever <chuck.lever@oracle.com> wro=
te:

> Hi Neil-
>=20
>=20
> On May 21, 2015, at 11:54 PM, NeilBrown <neilb@suse.de> wrote:
>=20
> >=20
> >=20
> > Hi Chuck / Steve,
> >=20
> > It seems that fedfs-utils doesn't build with the new libtirpc.
> >=20
> > Specifically fedfsd requires symbols
> >=20
> >  svcauth_gss_set_svc_name
> >  svcauth_gss_get_principal
> >=20
> > but libtirpc doesn't expose them any longer - it never included them in=
 .h
> > files or provided documentation.
> >=20
> > As far as I can tell fedfs-utils really does need these interfaces, the=
re is
> > no alternate.
>=20
> fedfs-utils needs to be updated, now that the new rpc_gss API is merged
> into libtirpc, to use rpc_gss_set_svc_name(3t) and rpc_gss_getcred(3t).
> That=E2=80=99s on my to-do list.
>=20
> In the meantime . . .
>=20
> > Would it be appropriate to make them "official" with header and doco su=
pport?
>=20
> A fix for this issue was proposed yesterday on libtirpc-devel.
>=20

Ahh, thanks.  I should have looked in the archives first, shouldn't I ?

I'll go see.

Thanks,
NeilBrown

--Sig_/YAKf1POr4k15dPLt7eejYLr
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVWKFBznsnt1WYoG5AQLdzBAAu89KEGelUUvhmjJOvKDDD7Ew0744qUXu
Bz/bl556iD5cGdnzH7Fg0++0/v7MhudEZG4j4BhbVtkX611oDm9PBHKgFPjsdsDG
SKkt82MeUJxinZhxgzIuWu3PlZixCxPQRJ0buQNHbl8vYbq1IB+/QsS92mABJaZ+
outGaK9A/dJA0aKs9rj7pc9tzQHp3fcaZqLTguHCgKZdfGFUxEkbot/BkuB8ISP5
CXPdWufJ1RsllWPDhDxl29sd9FEEYHWyiwB5a1XmFZX2dfgSik9I4Ztzz7fLDcHw
60FmqhGxQizhB2VC490OJKnaly89nTOMvbFf346ASqvMDuscXFEVa1rtq+r5Ou7e
XIXCf1bEwPBpuPdE23e2Ar9sDrp4YhxyRrJTjQYbDQ+44/U3tsTIfQ9oL05zK4xb
ULHsmPeY0+e76+y0Dwwx9PRdWOIT4DmheDO3rLA6wF6EDeQIh/hwu/doSO+fKDzY
lnLrjPB9w93KpYQsl+UTHVipvxS6Z63kMG+VZK6PildXh3mHlAKxwj5YuZhIm4B0
3WeBhiLabI4jv+dqu02vILPQt9vRsml6Fw1TI6bRjKMT062RAJzGE2NDEFpJvyF0
s1H8lsaccU1fW3ZZdzmRW5v3J0iXoBjzksLezoSZUhEhk14yTY0hXxYUwAuh8Lkb
2quwm9nx95s=
=ak4t
-----END PGP SIGNATURE-----

--Sig_/YAKf1POr4k15dPLt7eejYLr--
