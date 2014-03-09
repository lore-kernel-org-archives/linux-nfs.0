Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:51098 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751455AbaCIXVJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Mar 2014 19:21:09 -0400
Date: Mon, 10 Mar 2014 10:21:02 +1100
From: NeilBrown <neilb@suse.de>
To: David Heidelberger <david.heidelberger@ixit.cz>
Cc: linux-nfs@vger.kernel.org
Subject: Re: DNOTIFY to INOTIFY migration
Message-ID: <20140310102102.3c886726@notabene.brown>
In-Reply-To: <b59b1e4ede0b1d0a476c85465d480c8a@ixit.cz>
References: <b59b1e4ede0b1d0a476c85465d480c8a@ixit.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/C+tHlCF3gz=YUHIGLms6eZ2"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/C+tHlCF3gz=YUHIGLms6eZ2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 07 Mar 2014 21:30:34 +0100 David Heidelberger
<david.heidelberger@ixit.cz> wrote:

> Hello,
>=20
> in linux kernel is DNOTIFY actually marked as deprecated, with superior=20
> replacement INOTIFY.

Where is it marked as deprecated?  I would be very surprised if dnotify
wasn't supported indefinitely.

(I have no opinion on whether rpc.idmapd should be changed to use inotify,
except based on the "if it ain't broke, don't fix it" principle).

NeilBrown

>=20
> Is any plan to migrate rpc.idmapd to INOTIFY? As I looked, it's just one=
=20
> file.
>=20
> If there is some on-going porting, I'd like to test/report bugs/send=20
> patches, otherwise I'd like to try port it.
>=20
> Thank you for answer
> David Heidelberger (okias)
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Sig_/C+tHlCF3gz=YUHIGLms6eZ2
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUxz3Xjnsnt1WYoG5AQI/tBAAnihWm4AoepVGchN1drq3iFmef9AUyEaH
wNavNx+MGOnr8CZuXIbXtBNVRyp1UXlxGDj5Wt4abSyErhugQ/t923zieibWnX5O
Unyu7ULGO9EKs7H7hMl80TuBPcVocw5GiUNn2YrJSG2PQjm/QWwWK5A3uPEQiftf
qnx0z9PhwqgCifCiYz+yvQa6nV+I1e4Wi+ev4NijwDwt60GyOgz+BTl1643j0iMz
F350k9rmVjk8R6UbK/gH3m8LyDDpUh4v/8JUoFsiD/9ujGYlbSuePGCS6WB7gH40
jmmEyxFpfR4omFcYvG73FHcsQ8V2m9JgcUqHzM6d4UpPanKctaZDB6Z8ciNMUvI6
apSnw5WQaA3sjOHODuEDigOxoB6juOx6J7kV3QdAbk1GYOh1TOsEj8sSevF/zsO9
8I3DkHbT8CIP3oQbdXMjapQaz4ep0GaNxL2nKCV5A8+FsYVAtTZGrSJ4qoSSi/gv
rYv+t4zu42vnDENXALgIXYzKJXMrom4xwKYo/W+nB/0sQ0RdnJiFOTU2/w8FMZfx
Z6K4bh4JmqNXjasoo0i6UeMGtp17SdgiowQSZP0oVrrp1PENYjUuvrL0CrAVfFfS
jVyBAe42QISVJKZ/Ja0d8GgJLN5t9TmyptoWNRwmMG+5pqbSr1Y+rhxtU4gq5zqz
3gQpqq7NxvI=
=irV3
-----END PGP SIGNATURE-----

--Sig_/C+tHlCF3gz=YUHIGLms6eZ2--
