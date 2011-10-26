Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:41240 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932308Ab1JZHgM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Oct 2011 03:36:12 -0400
Date: Wed, 26 Oct 2011 18:36:13 +1100
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "NFS" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS/sunrpc: don't use a credential with extra groups.
Message-ID: <20111026183613.3970dc6b@notabene.brown>
In-Reply-To: <00de01cc93af$bc3812cc$d25f630a@hq.netapp.com>
References: <00de01cc93af$bc3812cc$d25f630a@hq.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Qb.8tIFdZJVu9ALDWyYXkpq"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Qb.8tIFdZJVu9ALDWyYXkpq
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 26 Oct 2011 01:30:34 +0200 "Myklebust, Trond"
<Trond.Myklebust@netapp.com> wrote:

> Hi Neil
>=20
> I queued this patch up for linux-next testing earlier this morning. I cou=
ld have included it in the pull I sent to Linus, but I'm trying to be a bit=
 more strict about integration testing prior to pushing.
>=20
> I also added a Cc: stable@kernel.org. I'm assuming that was appropriate.

Thanks.
I was in two minds about -stable as it requires special care to trigger the
bug.  I am certainly not against it though.

(and I fully support your more strict approach to integration testing!  I'll
take it as an example to aspire to).

Thanks,
NeilBrown

--Sig_/Qb.8tIFdZJVu9ALDWyYXkpq
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBTqe4bTnsnt1WYoG5AQJmpQ//et5KA9ogDD51bJZvphuyCAH9AZ3Av6ct
uee08ephnvK3DBEgicHfP1iU7V7lBq+PZdMqpIUoVpAO09gUscFc+wJZYLYry/6p
ip/ZVoQfYzHhFqnNpT9Rcsr4KMeB9e3WttL6xBUyb0I1fS4c+HJ8NEFeQhR0uH7y
/FKlrbGB7QA8oOtOEhbIcsRwaKMf2TExfoqKyD56pZEqYevGNHOaVRiEMWb34mAc
WZ9lRK8xCpS8+XQHGedCjF3f1X5aL7fCMYnKFkN1FuFeYd+RaFRj9i2uXJpAA3mv
6BW3xJFL2Y92q7q1t1gx8cWtBFvULaHHV9bK0CDz600TMNocmfHHXxMrcA1HKTSI
a37Ndw1ZFr8O40I8C7aBJ0Rwbs/HU7UMS9Mwq1S+llrkIF4axrCDSTbK21ZQTJ84
cW2N8XkI/CExgbLPgdDmw0l1HyPtPdDDJJqHPYgyz9S11Qcq9d0ETCjYP8smaFdh
Yvo2VMGIgPC82dpjFIw0p/DTgNuwlHp0NiSfP8jEljn0XGucZMxEXAtAkzWhWWA+
TK+bxipeoUNMkKbZeJPsLwP703mgIcU0aCL0MbjMsUtsAEE3izChUgyaTZRQj+tP
VT699FghKtw5IIHoLnIqdO9DmEcsCyuSGHcmhKDlwnozAJVe6yE+Zi1mBnPGytQ/
3WKwg8704Ss=
=qCk3
-----END PGP SIGNATURE-----

--Sig_/Qb.8tIFdZJVu9ALDWyYXkpq--
