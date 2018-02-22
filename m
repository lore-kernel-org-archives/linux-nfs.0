Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:34091 "EHLO
        mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752535AbeBVIRM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Feb 2018 03:17:12 -0500
Date: Thu, 22 Feb 2018 09:17:08 +0100
From: Matthias Gerstner <matthias.gerstner@nefkom.net>
To: Steve Dickson <SteveD@RedHat.com>
Cc: linux-nfs@vger.kernel.org, Justin Mitchell <jumitche@redhat.com>
Subject: Re: nfs-utils: rpc.svcgssd segmentation fault in
 nss_gss_princ_to_ids()
Message-ID: <20180222081708.GA883@q910.gerrit.home>
References: <20180220224858.GA14972@q910.gerrit.home>
 <849cf544-ba0a-c218-020d-93f973ba7ab6@RedHat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="FCuugMFkClbJLl1L"
In-Reply-To: <849cf544-ba0a-c218-020d-93f973ba7ab6@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

thanks for your reply.

> It is... But in the future please in line your
> patch (which I have a the bottom of this reply)
> instead attaching it.. I just makes it easier=20
> to review.

I will do so.

> Also note, at least with Fedora, we no longer use rpc.svcgssd
> instead we use gssproxy to access GSSAPI credentials

Okay. I have been running this NFS setup for years without touching much.
It looks like I should invest some time to check if everything is still up =
to
date.

> By moving this pragama statement both the no_strip=20
> and reformat_group are also being exposed as=20
> global variables in the libnfsidmap, correct?
> I'm not sure we want to do that, if that is the case.

I was not suggesting to accept this as a patch. I just wanted to make clear
what "helped" in my case.

I will try some more experiments when I have time. Maybe I can find a suita=
ble
patch. Getter/Setter functions instead of the extern declared variables mig=
ht
help.

Regards

Matthias

--FCuugMFkClbJLl1L
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEQMifAG+4oyi4OjfMFK1vZXkJcoQFAlqOfIQACgkQFK1vZXkJ
coRSDxAAhzka3UZ9PKCY8f8zrGM4MGrI42FdINoMBO81UL332gwf1jE1NDeHZWZO
wfjqqN2mnShMrOF1HeMAbvwGFtxJBGVmnbBDjsqkuFf4BpX2XJZZ5Bq2JFzD/Kga
YPRBqZNcd0H2L04gn3OIJarXgj/KhHz6zdEDRoY+h46Y1e69reDCkYA5ieEzAjeX
wvlVfCWJOs07D12Pe2JcT5aWRDAHvTjaJwf5AnDGsdqlUh8B6b40h7K9QFbRbtyn
RNxXDF6CU7302GzOIW+7FLI7/sibhCn0Y4k+nN4o5/9ieqzqjsilX+9ewioT5cV5
W5wZCsmCNSvHjFdV7L75fdVufDIWKk1l3Vr7bqze0fvofK6ektJjgl3C0ejBtwKa
/5GJdbgUoC735XeekTl7vPQUXlWOtRayBDfN+Ov6VUJhA0morvrkl1t7G8PsyOvi
SQGL7Ws7DphhC4LAGYAUNj3o8Gy63ctYVy3epZIVLNcrUCXplcE8b+T5LwfogRbT
K+h86e3hoPbWcQiec62H82zRMbN+SI+zJyzYp2qjGYNZdrPrMAEPSBUm0MX/0HcT
lGrfiH2/rrw2gEFj49kXBV32wkle1QzTxtP/sR89dJsdkYDFR9T9hNFyiNtOOvxA
LPflId2MkXRi8/otjIISzz74Vsr9LBKctPDX3I3p+g90JSkFwa4=
=xg1t
-----END PGP SIGNATURE-----

--FCuugMFkClbJLl1L--
