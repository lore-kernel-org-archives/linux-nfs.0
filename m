Return-Path: <SRS0=dkOU=OZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7F80C43387
	for <linux-nfs@archiver.kernel.org>; Sun, 16 Dec 2018 23:16:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8DB74206C2
	for <linux-nfs@archiver.kernel.org>; Sun, 16 Dec 2018 23:16:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="sLxXMWuo"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730987AbeLPXQe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 16 Dec 2018 18:16:34 -0500
Received: from ozlabs.org ([203.11.71.1]:36979 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730772AbeLPXQe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 16 Dec 2018 18:16:34 -0500
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ozlabs.org (Postfix) with ESMTPSA id 43J0XZ6THnz9sD4;
        Mon, 17 Dec 2018 10:16:30 +1100 (AEDT)
Authentication-Results: ozlabs.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
        s=201702; t=1545002190;
        bh=n9AdQheZgXZvVJlfrUAkO5i4kd9GYRJ7aBd1BHJJhM0=;
        h=Date:From:To:Cc:Subject:From;
        b=sLxXMWuoIE5FhJHdS/kBN9K6MoHKRwwFiijLr36Bj5tDXifVh7NyvFmhmMpqKb7qu
         Xys5eIhHsevISaWPaXoKusar2Dox/A0sCsIsb9O623lKjrH8RHTAC2LZ3D2oYw0GQu
         6mA4juRbIGwTWiEpx1fO6RO9SiKTOMutpEX2Zu0nmMVTVlwbtu/qOlcDh2CPN8fiE7
         kYSq4dU0+b0Ki86+voB+cDOvUOMTi5U+/D1+0+gVgm+dit8DIoVc1Xvh9tNWswZ0b0
         a9X+EgVO40BVydFzL9xE8P8jl0BJ3y8Sq/VtWU/WHE3oeQr23fcDONUV35QNG/zT11
         vofT5pK1+TKIA==
Date:   Mon, 17 Dec 2018 10:16:30 +1100
From:   Stephen Rothwell <sfr@canb.auug.org.au>
To:     Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Trond Myklebust <trondmy@gmail.com>,
        NFS Mailing List <linux-nfs@vger.kernel.org>
Cc:     Linux Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: linux-next: build failure after merge of the nfs-anna tree
Message-ID: <20181217101630.292dd55e@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/b7l4dzBjV_3487Zir6v2ChE"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--Sig_/b7l4dzBjV_3487Zir6v2ChE
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the nfs-anna tree, today's linux-next build (arm
multi_v7_defconfig) failed like this:

/home/sfr/next/next/fs/nfs/nfsroot.c: In function 'root_nfs_data':
/home/sfr/next/next/fs/nfs/nfsroot.c:264:5: error: implicit declaration of =
function 'fmtcheck'; did you mean 'dst_check'? [-Werror=3Dimplicit-function=
-declaration]
     fmtcheck(tmp, "%s", 0), utsname()->nodename);
     ^~~~~~~~
     dst_check

Caused by commit

  66ab6f062d96 ("nfs: use fmtcheck() in root_nfs_data")

For some reason this did not turn up until I was building the
hwmon-staging tree (maybe some Kconfig change casued it to be built now),
so I have just reverted that commit for today.

--=20
Cheers,
Stephen Rothwell

--Sig_/b7l4dzBjV_3487Zir6v2ChE
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlwW3M4ACgkQAVBC80lX
0GyWpgf7BzuNbWNvh4jN36sW2BhM9Xo6BJ5qswIWKQCwJtiEG/CWidEcKMnV0DB/
uIRij9FK45Yh0MgrWRkogTyQOnPTUyQckkBANRIOc6bKAflxT5+CzuqCtFYT263o
KInyRT+KW3kp2V+6CTmpddyiIE9PL5PtPpdtBe63MIwxZHnWkX/t7fKwZI1nV8aW
IX3TmybtKO6UKGYLEfVR9f+GikFhcodgfAzb9tVBBrv8vhr3c/Ifda0roQxHgrDr
8r7sypF0FI6A/SETXjgwy3BwEgVAH/eGjvGW7uhonGaEf9NEWB+L6XztGBQMp9bp
xZIjgZwRVNsrsmf8kosFIUp99viBng==
=O2WA
-----END PGP SIGNATURE-----

--Sig_/b7l4dzBjV_3487Zir6v2ChE--
