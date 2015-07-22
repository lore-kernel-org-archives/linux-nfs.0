Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51110 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754631AbbGVNqZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jul 2015 09:46:25 -0400
Message-ID: <55AF9EA8.6020102@redhat.com>
Date: Wed, 22 Jul 2015 15:46:16 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH] nfs: avoid swap-over-NFS deadlock
References: <1437552643-18774-1-git-send-email-jmarchan@redhat.com> <CAHQdGtRXhUi+=akuASUWo-tYy0YCWJtUts6fqGnA62fo1Jf5tA@mail.gmail.com>
In-Reply-To: <CAHQdGtRXhUi+=akuASUWo-tYy0YCWJtUts6fqGnA62fo1Jf5tA@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="vxvcjQMNQAkWoeoXVafnunD9cQfXL9h8h"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--vxvcjQMNQAkWoeoXVafnunD9cQfXL9h8h
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 07/22/2015 02:23 PM, Trond Myklebust wrote:
> On Wed, Jul 22, 2015 at 4:10 AM, Jerome Marchand <jmarchan@redhat.com> =
wrote:
>>
>> Lockdep warns about a inconsistent {RECLAIM_FS-ON-W} ->
>> {IN-RECLAIM_FS-W} usage. The culpritt is the inode->i_mutex taken in
>> nfs_file_direct_write(). This code was introduced by commit a9ab5e8406=
69
>> ("nfs: page cache invalidation for dio").
>> This naive test patch avoid to take the mutex on a swapfile and makes
>> lockdep happy again. However I don't know much about NFS code and I
>> assume it's probably not the proper solution. Any thought?
>>
>> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
>=20
> NFS is not the only O_DIRECT implementation to set the inode->i_mutex.
> Why can't this be fixed in the generic swap code instead of adding
> yet-another-exception-for-IS_SWAPFILE?

I meant to cc Mel. Just added him.

AFAIK NFS is the only filesystem that uses swap_activate. Other
swapfiles are handled more or less like block device (divided in a set
of contiguous ranges of disk block called swap extents), so there are
not affected by this possible deadlock.

Also nfs_direct_IO() is special in that it is called only from swap,
nfs_file_direct_write() however has other users.

Jerome
>=20
> Cheers
>   Trond
>=20



--vxvcjQMNQAkWoeoXVafnunD9cQfXL9h8h
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVr56tAAoJEHTzHJCtsuoCuJwH/1Kj2FMWV2a33fQse0hqMyNW
/QgyXHq4YxuFSLhZNCdy9sUIHmpv8PV3o7F33VasqkDQwOR8rjsw6EdTSBYI4rLN
tVuSO2Au/W5PHxOz0aHBzsyMsMxvAUSyjzy6k+4dGBELfY9e466Fjn5tvmDRXkZt
SZWig0d2SKjAFFYSaYYY9RH+qWXw/B/qoeK5xgZ4dQNFmb/beqxERL6taY1Lk8bY
wPZKbKTZvUe8zLFVVb7V872exmKXg8/iPtR60DT2qmtvIRvR3nqgjfiz/PIEz573
NZjkdaiTL0AXeOwm8q1IKLgWqW8Dv1X60qCA8Sz+BTMNTWQ0ujbaJXpf6gPyUcA=
=rvE4
-----END PGP SIGNATURE-----

--vxvcjQMNQAkWoeoXVafnunD9cQfXL9h8h--
