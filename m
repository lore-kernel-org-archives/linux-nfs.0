Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51293 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756647AbcHDMoW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Aug 2016 08:44:22 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 04 Aug 2016 22:06:54 +1000
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/7] Assorted mount/mountd nfs-utils patches - V2
In-Reply-To: <ebff995f-0de7-900f-d240-bd6dfc7d9930@RedHat.com>
References: <146976807524.20186.8871903418718212567.stgit@noble> <ebff995f-0de7-900f-d240-bd6dfc7d9930@RedHat.com>
Message-ID: <87zios3fhd.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 04 2016, Steve Dickson <SteveD@redhat.com> wrote:
>>=20
>> NeilBrown (7):
>>       nfs.man: clarify effect of 'retry' option.
>>       mountd: remove the --exports-file option
>>       mount: don't treat temporary name resolution failure as permanent.
>>       mount: use a public address for IPv6 callback.
>>       mount: fix memory leak in v4root_add_parents
>>       mountd: allow alternate ttl to be specified for dump_to_cache.
>>       mountd: fail nfsd.export lookup for path to unmounted exportpoint
> The patch series committed...=20

Thanks!  Have you any idea when 1.3.4 might be released.  I want
several bits for openSUSE and I'm wondering whether to take them
piece-meal, or to wait for a new release.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXoy/eAAoJEDnsnt1WYoG5ho4P/iGCfLsIFkaWROqYfC9TxLy4
N4/XMUekSjJ+JknLiNzyqSrZ5+QPu8gb4e1BfRvCPpZeeDZHKYnXzHClV7T8QvkC
ra8Ud04fHdgqGHKY36NVG9h69U37x0qeLiH0X6QEID+A9Cf203lAljCRS/UIEPoF
eSwRi94MamNsnTeDQHC6ugF8XmDTzDLE6/akNdAloi4uvMXLgFfm67m6DkeHttS0
0shXIy17KhlyCPebtKw6KK17Dxkm1yuvB5+ch3jJnD8KP6Cl8R/lDuA+KCe85NcH
H4x5zfpJX5hw4eeT3CpNfQVrcUvHoD/mbK21flK9gnR8JpCMvz0dFdu+dzS1rT2L
RobN3C/h3irg3RSdMt7i2RZaJL1HkbDzsnvXCYvuk2kKvpi9faueVdUH/rhVeZPL
SgeWmnFs/I9R/kfu6ihZJZVznrFuZ3irpGyLb9OVz8dIabvO+sfEvGE5tC0DU3nQ
Xn+RmPPJzK0MqsLG5tCCfD5rlnPD6HOeE6nSJvBGYnq6M4valfygeCx4tFbXCkZY
LRskRXY5XFB+PCO+NpiERPkEEc1rh4vteB1eb5+id9ODjERM+wxZOj0dcQ+8iW3y
g2MANhOgTqv7XJj9uZl0hT51lIdJJx/2LvgNJOQTr3JIhpUWbuHvge7eXEjVXbeP
CqXK9E7gv5Vdpu5EX1wt
=OTQ6
-----END PGP SIGNATURE-----
--=-=-=--
