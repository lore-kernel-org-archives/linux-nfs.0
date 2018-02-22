Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:46098 "EHLO
        mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751775AbeBVXK1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Feb 2018 18:10:27 -0500
Date: Fri, 23 Feb 2018 00:10:24 +0100
From: matthias.gerstner@nefkom.net
To: Justin Mitchell <jumitche@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfs-utils: rpc.svcgssd segmentation fault in
 nss_gss_princ_to_ids()
Message-ID: <20180222231015.GA15670@q910.gerrit.home>
References: <20180220224858.GA14972@q910.gerrit.home>
 <1519231741.7497.18.camel@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="R3G7APHDIzY6R/pk"
In-Reply-To: <1519231741.7497.18.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--R3G7APHDIzY6R/pk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello,

> I will run some tests to see if this is isolated to certain compiler
> versions, or if the pragma isnt working as I expected.

I just want to report that I just tested with a more recent gcc 7.3.0 and the
result was the same.

Regards

Matthias

--R3G7APHDIzY6R/pk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEQMifAG+4oyi4OjfMFK1vZXkJcoQFAlqPTd8ACgkQFK1vZXkJ
coQi6RAAmZMwwfVUTfZbtjqMuwn6xKqCqZjhtfgJQg6W9cTeOV+p4N2+juCZ80ro
bPkjcf2OKxIWgyKtrUAKsf0Sf+q0zTHwt8/wSl9yZzUSnH1GT9cVIyo7MYy3c3KY
QMevttz82tL2+Up1jrH7sGnHxxawfpK6IYnWui6+PSarEAPH4nY7Gr/P3puLCUV6
CeSRlU3deluMao+QTOP6vgDNhPr1h/07XQV3Sa/Q8mu5ToCWf1YsxcX972I84z97
fVTFuNhPX3YlhtjsvSDh7QSwIqoVMzveVEIdw6jxzJ1nXZbqSb/eD4Mx5KaZGr7N
mIfOaSmhYROF8k+jKMzIF9XQ6hEU3iCuZK/wVufVlMJacDKtlzPiPaNsZxt3ayyJ
oCNGZ/9xOIpgLqtbHoyZ0FtvKmNjD74mRLqmR5aPs2yRvecnDzLv5J1dkwr0io75
ghS30IwUuaO7AwwCzi2rChiynG0XF6kUdUIsv7+NlGrLMcYLcHUh4bFhxjfnaXi4
AKTVN+fzp73PO/pAO9LUS2kxy+yQ0wgohcZmn7uW5ehOrkPxB2RHuCqT4UIChUT1
eCNvXPuALHPiy3WELMqBM7RBXlvKkpSu+1YFxIzElCzmsPyxAE4Qb9X6CGFIqTMx
axh6M5wEbO3ngeoiVZCEg4mi3Ky/5iZqNX/ZUDLLahFFTkP8bCE=
=urWC
-----END PGP SIGNATURE-----

--R3G7APHDIzY6R/pk--
