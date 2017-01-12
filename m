Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42801 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750796AbdALV3r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 12 Jan 2017 16:29:47 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Fri, 13 Jan 2017 08:29:35 +1100
Cc: andros@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH Version 4] SVCAUTH reap the rsc cache entry on RPC_SS_PROC_DESTROY
In-Reply-To: <20170112210826.GD10501@fieldses.org>
References: <1482428286-33744-1-git-send-email-andros@netapp.com> <1482428286-33744-2-git-send-email-andros@netapp.com> <20170104202634.GA21562@fieldses.org> <8737gymss7.fsf@notabene.neil.brown.name> <20170106210111.GA31401@fieldses.org> <874m1bloyp.fsf@notabene.neil.brown.name> <20170112210826.GD10501@fieldses.org>
Message-ID: <87r348ge68.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Jan 13 2017, J. Bruce Fields wrote:

> On Sat, Jan 07, 2017 at 10:59:26AM +1100, NeilBrown wrote:
>> How about applying
>> >> >  -		rsci->h.expiry_time =3D get_seconds();
>> >> >  +		rsci->h.expiry_time =3D seconds_since_boot();
>>=20
>> first with a Cc: to stable (and a Fixes:), then this patch on top of
>> that without the Cc.
>
> Oh, good idea, thanks.  Results below.

Ferpect.  Thanks!

NeilBrown


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlh39T8ACgkQOeye3VZi
gbldpA//V0sVOBzhLGpJdpicZKJbX/+9vmJgN1rmFI7ER1RmpXUJIAUaNeyYePe8
w/34B+Jc+VnXUUE/ZtedSEqd2zINqsd83/HHAfaSZdZ0uPMyjmovfbRNSFC7Rui4
TzKoPUL9i2x3nqIkPKfEkNsEiREMB4sLEWKdNSOs+fsCMrR1KOqhnDN/vAxiiiPp
LbKq76K+rDKht/wj/2ubLALfTh/rjkdkapG1aj0G+i9pRj9LSv7xJ29AzUPqRGrV
9Hm2PgTT0eaXz5sfMWM2M7tbh8Pbjhuwz05mA3Q2jA8fhNprmkSHSWAOpGveSBpl
MpGfaA3IBv4KYBLxU0s1SY9Vi7Nf1JgdbtlJY37RpNHKQsc8iv+NONZGqH3afiJ3
cYB9Voxi/sesR5m4s+IJc6gxMuVEfTIwYMn3VaQNWahStq3sj53wm1MGn3bSpah0
W9KUlcl4e/SoiPa+Rq/CDUTCqZvlyG63W6LPqPehC6pIpkYH8mcxOvFYYvIyrBpS
5SjAJ6L0mSjCqVUHRCULNPqSaFHKGX9RN0zyOgMVyDVtGAdpBJOHimbaNK04Fjr/
rxp0f/3oYglkrmY5ilr58bL1vcThiNWhcqapAS73lW1G6PBmYWTh/4GGspALlwZ3
1/MIcYUpxE+vaJewB3xste1xBsXlWfUjZpEkkkNsS6iL25jQemc=
=1GgC
-----END PGP SIGNATURE-----
--=-=-=--
