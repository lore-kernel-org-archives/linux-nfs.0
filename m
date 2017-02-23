Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43424 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934641AbdBWA1A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 22 Feb 2017 19:27:00 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        bfields@fieldses.org
Date: Thu, 23 Feb 2017 11:13:05 +1100
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/2] Fix up nfsd to enable NFSv4.x without NFSv4.0
In-Reply-To: <20170222233533.23845-1-trond.myklebust@primarydata.com>
References: <20170222233533.23845-1-trond.myklebust@primarydata.com>
Message-ID: <87y3wxrcha.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Feb 22 2017, Trond Myklebust wrote:

> This patch series was intended as a standalone series. However it now
> aims to fix up a few issues with Neil's initial patch:
>
> 1) When the user turns off all minor versions of NFSv4, then that should
>    be equivalent to turning off NFSv4 support, and so when someone tries
>    to mount, we should return RPC_PROG_MISMATCH.
> 2) Allow the user to use either '4.0' or '4' in order to enable or disable
>    minor version 0. Other minor versions remain enabled/disabled using the
>    '4.x' format.

If I understand you and the code correctly, then this change means that
if I run

   rpc.nfsd -N 4

the nfs server will continue to server v4.1 and v4.2 requests, only v4.0
will be disabled (Assuming a kernel which defaults to serving v4.0, v4.1
and v4.0).

Is that really what we want?

The text in the man page for rpc.nfsd could be read as allowing this
interpretation, though it isn't explicit.
I've always used "NFSv4" to mean any or all for 4.0, 4.1, 4.2, ...

Thanks,
NeilBrown


> 3) Fix up the display of the minor versions so that we don't add '4.0'.
>    Previous kernels have always assumed the '4' means 'minor version 0',
>    so there should be no need to have both.
>
> v2: Make incremental to Neil's patch
>     Fix up display of the version string
>
> Trond Myklebust (2):
>   nfsd: Allow enabling NFSv4.x without also requiring NFSv4.0
>   nfsd: Fix display of the version string
>
>  fs/nfsd/nfsctl.c | 72 ++++++++++++++++++++++++++------------------------=
------
>  fs/nfsd/nfssvc.c | 14 +++++++++++
>  2 files changed, 48 insertions(+), 38 deletions(-)
>
> --=20
> 2.9.3

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliuKREACgkQOeye3VZi
gbl5jw//Qc4QD6XxSJAEl7/BrAXW6c1954+vsil6rKCMoYA1f7mAwB2xISV0E91k
1/kffci3ULf/JDN2oqQL66ehxklRA5N8pGQPOoQ440xlxpYdw4jT5V+nIMSSZj0+
5EnSMJaa3k+qyZxXqtjauYNR8tvknJlGNO0G7nAR+gWg3jSkKRkgiZM1p4ELv/Sf
EX4zB8QLDh0pmD8Hq2fkLGxUVtITQ5AUHT6aTrZ9bU6CHzF/Ycvd1+T1McSVh7Eg
zSR35xbaNsfNDIH/uaUNUHZkmSGa8Whlk3/ZCRNsNeJov6hSsCceu81wx+gHeog5
kLXuK1/vRR90ZUOflzE9wGhxEHheIN6m0lmJZk4o293O5mEnVthcJQBMwKXige9Z
XS8umqZVk7/PTzrZYGBQJDzMFbj38buG76JJ0e6UvnyNTbT7SkQ0v5RYbNVCRmiM
rPWbimv/6p4YtZ5SJOg9Dpg6ymBAjbekbIuaL8BOHI0TtoS57AXjlx8zgwKHVwu7
B7dwssg90DJewipiCo0JTE5O8SbHBXRTd3lJnBOSaNnbMZmHTiFu7GTYGOA9b8Ir
bY2VA4/2pu4TzOw7RuqrT8xcv+5J5Dx5Co14LIhG51Z9Hw4xpge8iYUVeT5E/W5H
pgF/nEcQL2qunv/IMEqkrBz3hTMC8aBNtGpkvy8OJINEOfanusM=
=Mfox
-----END PGP SIGNATURE-----
--=-=-=--
