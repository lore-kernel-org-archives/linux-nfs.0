Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43312 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752578AbdA3Wns (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 30 Jan 2017 17:43:48 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Tue, 31 Jan 2017 09:28:37 +1100
Cc: Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSDv4: use export cache flushtime for changeid on V4ROOT objects.
In-Reply-To: <20170130153517.GC24786@fieldses.org>
References: <87mve9rs0z.fsf@notabene.neil.brown.name> <20170130153517.GC24786@fieldses.org>
Message-ID: <8737g0rxm2.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Jan 30 2017, J. Bruce Fields wrote:

> On Mon, Jan 30, 2017 at 05:17:00PM +1100, NeilBrown wrote:
>>=20
>> If you change the set of filesystems that are exported, then
>> the contents of various directories in the NFSv4 pseudo-root
>> is likely to change.  However the change-id of those
>> directories is currently tied to the underlying directory,
>> so the clinet may not see the changes in a timely fashion.
>
> Oh, good catch.
>
>> This patch changes the change-id number to be derived from the
>> "flush_time" of the export cache.  Whenever any changes are
>> made to the set of exported filesystems, this flush_time is
>> updated.  The result is that clients see changes to the set
>> of exported filesystems much more quickly, often immediately.
>
> And, a clever solution, as usual....
>
> I wonder if it's completely right yet, though.  Off the top of my head:
> can't the client see the new flush time before it sees the new contents?
> If so, a client that caches both during that window could cache the old
> contents indefinitely.

uhm....
Yes, it could see the new flush time before it sees the new contents.
When it sees that new flush time (i.e. new change attribute), it will
invalidate its cached contents and ask for the contents again.  It will
then definitely get new contents.

Or do you see something that I don't?

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliPvhUACgkQOeye3VZi
gblxqBAAn8NdEulvh84eK7x/4IkA/s5kkL7UB3JDdi35raVG2OK4SA3Ee2PFTr3l
4WT8Jk0v3LSjb4X3rIcrLBpg68qOD9QHK878eUgiZNWLVr2ZZw8tfqLUMjdvnEXi
JmblWl7BjIk4nNSEKMNxpgj2wBwN0jHPj7Gqds+cd6VIA3Jm0VA3RWCASESD+9uf
blbvuGvFXJh6BwV5VoadkQJLvzdOIQeoev8EVSVNNAJqmN+KP0P0TDRjDEJqoFfH
/cIxpgWtjR2GYj6uOFH2gsdLnDZZopLMiFttiavKu6WTcwWK7kvXVExBAHUlPx3s
woZ4m4fH7JiEO3FKwUhA1E1+4cgksEtML4jYwrKnHePW0kXl0bISd5WWSTG97O6d
A3Mb3GO8ERKD6yEr6F4t6sU7eFlpKPaw1IOUeLKhW3CyaUpB4JZsRfr/yDdaWZGH
3IGk0PvD9gzUJ4kLZ6w/L+wBH3yQGHWvD1boKcg10s4TSyk9erTI8mQcJNGJAiCE
qODz7qSEidN5JeUmrSQ1IhsRVAXinU8gLBy0M0klcug69FZvcENVDgcL3z2Lbpv0
D4vI0T6aQrLZAz1P+buJ/v5GvrbrBjlPMkZcR/ewx89hDFYt3Umzt5sTYTEqLHm7
G5Wn7hUopO2p6GUiVKztnKZv3BMgIE3GujVQM994camJbu7Q6vo=
=QFAO
-----END PGP SIGNATURE-----
--=-=-=--
