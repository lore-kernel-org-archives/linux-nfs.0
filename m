Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46928 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759294AbcLUXEc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Dec 2016 18:04:32 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Date: Thu, 22 Dec 2016 10:04:23 +1100
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: correctly range-check v4.x minor version when setting versions.
In-Reply-To: <20161221214153.GK17617@parsley.fieldses.org>
References: <87bmw6rm7w.fsf@notabene.neil.brown.name> <20161221214153.GK17617@parsley.fieldses.org>
Message-ID: <87k2asriiw.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Thu, Dec 22 2016, J. Bruce Fields wrote:
> Makes sense to me, queueing up for 4.11 (none of this seems urgent).
>

Thanks!  It's a while since I've seen a *less* urgent patch :-)

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhbCncACgkQOeye3VZi
gbnhRw/9G2DrWtodb36nGlHxjtrEm1Sza5aNKf+1l/X1GYhdwGG0G4JYhfp0L84W
YuLjApRRBKZZ67KotT4tYQOuwwgzKwGyg3TpH6LQXqv6X83GGp0rszAagOXFX56P
Zu0VJONDXq/zPt85YxGAWKYYNtl6mQM4OxzNeImBmVz+jjBXaO07MPEEzTGzgNjP
YObawKbe1Bn59E/VjVBkK2dY3N4XE6tadVSK/KQI1KaVx40Qq634iTjNYjwb/Xda
4MsZVzGtYJxZ/h7oq9HylTfLEcjAfJUkbQvMDCG+YyGPQAB7r3Yj8hmk+7aSlq4h
Xt8szQunWuKte3Ojqyyfq5P+26H6CYx7lOkYt01WwQ0nXtLPN2B+nwfK5y1z45mh
ALkOI728X6mJLj9gogEL/OrjCS/V2A4gpI0D+Lni2vgAujSqGZy5qAFWnW9A3OTm
hsEnoZ8FwWmBZomlm2VQdeCDfwCmx9PPrWYo1Hl7ZBAjOeJbFbUKKdTJ0fbPa5v7
J3UJHs/jg2ZF/PQjx0OJigWft5ou3O5ZkUWW/XIgZ0Z9Wm2I/MFo/AWzlGCn7xqk
StxcA7apZ53zFdYWR4Y7R3fCaI75jn6horc8ucjTG5wgrAKXkmiF+1frvi2R2R3w
VvdhK0CGmKoxDqFNiaWhlqqVQiGEHAbOMN6HmsNCGbde+xjryG4=
=0YsG
-----END PGP SIGNATURE-----
--=-=-=--
