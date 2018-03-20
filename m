Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42825 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751390AbeCTWM6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Mar 2018 18:12:58 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Wed, 21 Mar 2018 09:12:48 +1100
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH - v2] NFSv4: handle EINVAL from EXCHANGE_ID better.
In-Reply-To: <20180320214821.GF4288@fieldses.org>
References: <87bmfoc3yi.fsf@notabene.neil.brown.name> <878tasc3ag.fsf@notabene.neil.brown.name> <20180320214821.GF4288@fieldses.org>
Message-ID: <87o9ji8kgv.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Mar 20 2018, J. Bruce Fields wrote:

> On Fri, Mar 16, 2018 at 10:44:23AM +1100, NeilBrown wrote:
>>=20
>> nfs4_proc_exchange_id() can return -EINVAL if the server
>> reported NFS4INVAL (which I have seen in a packet trace),
>
> Can you say which server this was?  (One we can fix?)

Unfortunately not - all I know is that it is a bit old and isn't SUSE
(which doen't really narrow it down at all).
I've asked for more details and will pass on anything I discover.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlqxh2AACgkQOeye3VZi
gbmerw//bTM0+TOtomsw2+OZNrGnz01JGxXsWm8GumFUUPx9LsDkkzC/tL4Dkihh
1XbMQmqPqehteSs7XAVBmWsJb9atNnIKAltriotjece0wOB3Pw3qUSPluGbWPrUp
Yfjld8hMdotb4GGCDftjK+jti7e0fmz0mAVApMMjy4qORV3izc9SWPRjFbVLUjbz
S106bFVbwxWGQeN2tYIwr/6HiGmPMKQMhRiK2hG5TpMYwVh878DZUktPsO2LmdDb
/crEKFDkqw3etnijd4uOVexKUNC+Dq1NUoxXEaK7XnH3jorf/nLRDhgGkA/rrQj1
Pvayn2GdefIGGUcLKoT+861teGaGDQhbDKNg7fMwdPcAjR5mZ2LBzO6k501tPEDx
WVbnx67w6t0jXpNQRVzJtJbTSQTVzbU6Qx+FLWKSakP39DMOXLoWER4lNEpGdh1j
m45AT/PEuqqFmy1bbNlc6AlUjR5jrlA9WXRQukdeepNyXPpOPK5F/X2k280R0s5g
z7+kXulgYS5u2GdSitmCdAx/zMYMBxMNfIIa0cvHQ/MHuOcH+0hlj/LAe4zr5j0K
VSRpFGP/qZarDnXr/xPq+em7meYCXQyLU7Uppr60+e3ieAoBnQI6FXwkfDvl4/cc
VUySTIyhBZY8v9HVk54opfioabODZmC3v3rxNkNqXrJhKhSuvqs=
=NJzo
-----END PGP SIGNATURE-----
--=-=-=--
