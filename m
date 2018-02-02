Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from srv06.itamservices.de ([78.46.48.226]:60723 "EHLO
        srv06.itamservices.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751544AbeBBVqk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Feb 2018 16:46:40 -0500
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Steven Rostedt <rostedt@goodmis.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
From: Daniel Reichelt <hacking@nachtgeist.net>
Subject: Re: It's back! (Re: [REGRESSION] NFS is creating a hidden port (left
 over from xs_bind() ))
Message-ID: <57220e1f-f81e-b30b-a4ea-39ad74c7c0d6@nachtgeist.net>
Date: Fri, 2 Feb 2018 22:31:26 +0100
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="zvATQcned257m0yRLlQIpf4UvjFrgFcxd"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--zvATQcned257m0yRLlQIpf4UvjFrgFcxd
Content-Type: multipart/mixed; boundary="1VV7miNeqSPmnhaBlJj86XeI56jV6Bky7";
 protected-headers="v1"
From: Daniel Reichelt <hacking@nachtgeist.net>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
 Steven Rostedt <rostedt@goodmis.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>
Message-ID: <57220e1f-f81e-b30b-a4ea-39ad74c7c0d6@nachtgeist.net>
Subject: Re: It's back! (Re: [REGRESSION] NFS is creating a hidden port (left
 over from xs_bind() ))

--1VV7miNeqSPmnhaBlJj86XeI56jV6Bky7
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: quoted-printable

Hi Trond, Steven,

eversince I switched from Debian Jessie to Stretch last summer, I've
been seeing the very same hidden ports on an NFS server as described in
[1], which is a follow-up to [2].

Your patch ([3], [4]) solved the issue back then. Later on, you changed
that fix again in [5], which lead to the situation we're seeing today.

Reverting 0b0ab51 fixes the issue for me.

Let me know if you need more info.



Thanks
Daniel


[1] https://lkml.org/lkml/2016/6/30/341
[2] https://lkml.org/lkml/2015/6/11/803
[3] https://lkml.org/lkml/2015/6/19/759
[4] 4876cc779ff525b9c2376d8076edf47815e71f2c
[5] 4b0ab51db32eba0f48b7618254742f143364a28d


--1VV7miNeqSPmnhaBlJj86XeI56jV6Bky7--

--zvATQcned257m0yRLlQIpf4UvjFrgFcxd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQJLBAEBCAA1FiEEg2wMpOXGvc4nunsZnjl+Rc/8gF8FAlp02K4XHGhhY2tpbmdA
bmFjaHRnZWlzdC5uZXQACgkQnjl+Rc/8gF+HhQ//UCVSqA3wnJ6JZaafDOLPot1c
CiaCsArQPgXzQo8HCulKjBc/TVdvh/LSNslwH2UXSsoUPz15OaJ0Sy915CMxQOl8
zsCZoQdxZS8g2o4ProeU2UKlcGbrC5Zx/d68TaQjUy3dWlhNNULsXK3kmwO8FFWG
5qd7cu6j5YwgL3g795r1g784BC0L9v/isZsTV/jLd+7ULIRBwfS13eiiEyRxPAve
vICENfcj46iWrHuLRlQGnPLjs26gypxneduaSTtDBCWMPltzXuss/UuYTDeFeCFG
bGSCZ/hoDPtqxVbHYs07KsYHU30al22Zt4RIZDGjz2aCOpgvVlMIZ+IrqjtFU9Vc
x4CAti55FFGlinFsquIrdd5gfzyfKpUkK0q/utrybynMnm6cwN/nnwrp35ESIj55
vnVWAR5ptXAUzpTa1uU4CIBAFwBIMEUwYNsRMTNmSPm7x49Hx2Kv4qVT49MyhJko
P/fc2xlFKeq8D8KiLT/6lO/d9ymYk+VKEyLZhCW8eqR4zKKVLJG1QiiuRUQbmMXI
m7BOrMBeHZepe3Pf8SbRVA/yaDSL3UnYhOmKG5z9dzKNpBnAxUqN3EWjsviDSVZ7
Iu94Ueof+I9x/P5b8VXU58QyXB1a5EDr3opFDDBo3du1hMGnvY4ZnRfmh4FI6WGu
X2sL7iKzL9mr1mFSyqU=
=HUpz
-----END PGP SIGNATURE-----

--zvATQcned257m0yRLlQIpf4UvjFrgFcxd--
