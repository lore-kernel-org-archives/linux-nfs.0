Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:39716 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750976AbbEUEki (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 May 2015 00:40:38 -0400
Date: Thu, 21 May 2015 14:40:29 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Does NFSv4 need to call inode_permission on every write???
Message-ID: <20150521144029.57f1b33f@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/fV1ZbNMKtW5fhq/soyLO5di"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/fV1ZbNMKtW5fhq/soyLO5di
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



Apologies if this has been answered before, however...

In nfsd_write() we have:

	if (file) {
		err =3D nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry,
				NFSD_MAY_WRITE|NFSD_MAY_OWNER_OVERRIDE);
		if (err)
			goto out;
		err =3D nfsd_vfs_write(rqstp, fhp, file, offset, vec, vlen, cnt,
				stablep);
	} else {

So if a 'file' is already available - because the request came via NFSv4 and
there was a valid state id, and a 'struct file' was associated with that
state - we still call nfsd_permission().

Is that really needed?  The permission check will have been performed at op=
en
- it shouldn't be needed again now.

With NFSv3 we have to check permission at each IO, and this is slightly
different from POSIX semantics.  We shouldn't have to with NFSv4... should =
we?

The particular issue that brought this to my attention is that "chattr +i" -
to make a file immutable - is not supposed to affect current opens, only
future opens.  But a current open over NFSv4 is affected.

Is there some reason that we cannot just remove that nfsd_permission() chec=
k?

Thanks,
NeilBrown

--Sig_/fV1ZbNMKtW5fhq/soyLO5di
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVV1hvTnsnt1WYoG5AQJ7RhAAi3+Jw6k+wiN/jVhPWkMkzih29wMh2t6S
TaC8ytLeASyjTb4JmBJy2x4z4wi/LSlngFD4UJFHEOiqisYwUINcFitKV6tNLKGM
zC8JrJLcRRXTbG+wwWbSzeeKl3QQ67vifJzSLTYWRTaeGeBUO8xWT7RMKhHf0ssX
n+Hrsk12mMdMCYh/Z1H+4HojVenFQ9zk/kKYc4fkyQxA6ruvfPUm7QSYKePpownd
0bcIPoTTt2KPBPkuSP7pqSMWor/3bbS2uCROItCKk+QNCTvQ+eElRpRuRqSO8844
HdHcPOVkKoIcy+hKe4xESn0SYSFvlhbJyQkkJPQMfBhCGiFgFiJrTLE1BxifQzUB
moRs0sAP4v8CNza45dTYg2fT3dBptrQow4G5ITYH+BcNuS0mnLemDS7ZSGtB9j7r
OYdfvuMxNWvqJ+MQtGp9ehr1fSkNtXlcdRMa5N8L+o736qGKVBDupLe2ZIWI+Ca2
O8xI9KyFyYhBYSgNVrlxH+lHD5X/bZFKihNt8tnzcsqsik1ZGXAxGtKYkgYsBcnx
y/b+KgYoqVtWjQwpT/Of63qLkPfRTNUI6sP/zsyDEkTcMq8XSnKprIfDPdO2lpCR
xOR/peMmBm+KUeNVKnKz9jTSr406kImk4ULRTetgBVXjb78hfSmjW8MIybfz1w/Q
GJ9bT23q2ao=
=xUUv
-----END PGP SIGNATURE-----

--Sig_/fV1ZbNMKtW5fhq/soyLO5di--
