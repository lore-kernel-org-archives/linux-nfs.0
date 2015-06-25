Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mo4-p05-ob.smtp.rzone.de ([81.169.146.180]:32517 "EHLO
	mo4-p05-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023AbbFYUJf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Jun 2015 16:09:35 -0400
Message-ID: <558C5E7B.6080607@samba.org>
Date: Thu, 25 Jun 2015 22:03:07 +0200
From: "Stefan (metze) Metzmacher" <metze@samba.org>
MIME-Version: 1.0
To: Jeremy Allison <jra@samba.org>,
        Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
CC: linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [RFC v3 00/45] Richacls
References: <cover.1429868795.git.agruenba@redhat.com> <20150523155056.GA2845@jeremy-HP>
In-Reply-To: <20150523155056.GA2845@jeremy-HP>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="A5PE9kND3PJgsSitgC7xQpge8Opra1nQb"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--A5PE9kND3PJgsSitgC7xQpge8Opra1nQb
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

Hi Andreas,

>> here's another update of the richacl patch queue.  The changes since t=
he last
>> posting (https://lwn.net/Articles/638242/) include:
>>
>>  * The nfs client now allocates pages for received acls on demand like=
 the
>>    server does.  It no longer caches the acl size between calls.
>>
>>  * All possible acls consisting of only owner@, group@, and everyone@ =
entries
>>    which are equivalent to the file mode permission bits are now recog=
nized.
>>    This is needed because by the NFSv4 specification, the nfs server m=
ust
>>    translate the file mode permission bits into an acl if it supports =
acls at
>>    all.
>>
>>  * Support for the dacl attribute over NFSv4.1 for Automatic Inheritan=
ce, and
>>    also for the write_retention and write_retention_hold permissions.
>>
>>  * The richacl_compute_max_masks() documentation has been improved.
>>
>>  * Various minor bug fixes.
>>
>> The git version is available here:
>>
>>   git://git.kernel.org/pub/scm/linux/kernel/git/agruen/linux-richacl.g=
it \
>> 	richacl-2015-04-24
>=20
> FYI. I have a mostly (needs test suite adding) working module
> for Samba for Andreas's richacls code.
>=20
> Using it we map incoming Windows ACLs directly to richacls
> using the same mapping as we use for existing ZFS ACLs.

Yes, we need to make sure the code supports everything we require,
proved by working code.

We should avoid the disaster with the mostly unuseable F_SETLEASE
code for kernel oplocks.

Thanks!
metze


--A5PE9kND3PJgsSitgC7xQpge8Opra1nQb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iEYEARECAAYFAlWMXn4ACgkQm70gjA5TCD9YjwCdEItA+0iuWp+gJhJDJenkaadp
0ScAn3A2Rql/M3JwvMGuImj3O23OQ5Zt
=5AB/
-----END PGP SIGNATURE-----

--A5PE9kND3PJgsSitgC7xQpge8Opra1nQb--
