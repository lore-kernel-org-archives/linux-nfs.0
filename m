Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.162]:8636 "EHLO
        mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933033AbcKJOui (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2016 09:50:38 -0500
Date: Thu, 10 Nov 2016 15:47:21 +0100
From: Olaf Hering <olaf@aepfle.de>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: Jakub Kicinski <kubakici@wp.pl>, Yotam Gigi <yotamg@mellanox.com>,
        Andy Adamson <andros@Netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Yotam Gigi <yotam.gi@gmail.com>, mlxsw <mlxsw@mellanox.com>
Subject: Re: nfs NULL-dereferencing in net-next
Message-ID: <20161110144721.GA30540@aepfle.de>
References: <20161017201943.64529739@jkicinski-Precision-T1700>
 <DB3PR05MB0764DF28BC53A4A4E78A4DD8ACA80@DB3PR05MB0764.eurprd05.prod.outlook.com>
 <817e43c5-d88d-e616-7074-5715de29d319@Netapp.com>
 <DB3PR05MB0764B39F6EDF851A8A52EBACACAB0@DB3PR05MB0764.eurprd05.prod.outlook.com>
 <20161026190840.3d46dad8@jkicinski-Precision-T1700>
 <0ab5021c-84eb-cb9f-c7f5-4d856fdb0f4b@Netapp.com>
 <DB3PR05MB0764F0409AE75E0172ABFE2EACAA0@DB3PR05MB0764.eurprd05.prod.outlook.com>
 <20161031152550.10acb7e0@jkicinski-Precision-T1700>
 <e80aa023-b8e3-c663-1ef4-110f8a1368ab@Netapp.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="azLHFNyN32YCQGCU"
In-Reply-To: <e80aa023-b8e3-c663-1ef4-110f8a1368ab@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--azLHFNyN32YCQGCU
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

On Thu, Nov 03, Anna Schumaker wrote:

> Aww, I was hoping that patch would work.  It still seemed to fix some
> issues for me when mounting multiple servers, so I'm planning to keep
> it.  Unfortunately I'm out of town this week, so I haven't had much of
> a chance to keep poking at this issue.  I should be able to get back
> to it next week!

Is this supposed to be fixed already? I get an oops in
rpc_clnt_xprt_switch_has_addr+0xc/0x40 with 4.9.0-rc4.

Olaf

--azLHFNyN32YCQGCU
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iEYEARECAAYFAlgkiHYACgkQXUKg+qaYNn4YgwCg+PTAiU23ZAl7FDRL4SP8wiBY
jb0AnA3o3qnOV6u347ZO84JlNo6X9mNC
=PFPC
-----END PGP SIGNATURE-----

--azLHFNyN32YCQGCU--
