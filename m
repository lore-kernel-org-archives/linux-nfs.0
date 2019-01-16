Return-Path: <SRS0=vPHX=PY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39278C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Jan 2019 02:35:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0558720859
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Jan 2019 02:35:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="YmygAP8g"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728392AbfAPCf5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 15 Jan 2019 21:35:57 -0500
Received: from ozlabs.org ([203.11.71.1]:47649 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728309AbfAPCf4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 15 Jan 2019 21:35:56 -0500
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
        (No client certificate requested)
        by ozlabs.org (Postfix) with ESMTPSA id 43fWXn0g3Nz9s2P;
        Wed, 16 Jan 2019 13:35:53 +1100 (AEDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
        s=201702; t=1547606153;
        bh=+ck+JoWQUW/h9liz+DG1vGHOmkRd9WBJf5LyPjAkj4I=;
        h=Date:From:To:Cc:Subject:From;
        b=YmygAP8gpzIBq/NQ89k0mjLi5l5AFH1tqCw3Uf0xB0fXcitCvBn4Ilg4ex+MZDVmX
         KjZplrTF0+gBsQ/RoWpRMzPq+55yIBSj0rvff1lGPUxlLBIZ+F60aA+BIuzAor5E0h
         BeaoPT/8lESkoZpaipYV2wKVT/vs5TgVy55uiXwtPRrWlADy+cauJfWa2cRaHbREF2
         vH6zXSicGH32x0D5aNXwthVPFnvtiRI29P4qfxISGxtBMpdJM/hRNTn6iaulv94NBs
         cLWvRFeSLsEFY1rDtVxPvC2XJguSkLx8BQeUp4ZyTWWMYyT88eo9v8XMatLOs140zb
         HOdA4hCDuUEVQ==
Date:   Wed, 16 Jan 2019 13:35:52 +1100
From:   Stephen Rothwell <sfr@canb.auug.org.au>
To:     Jens Axboe <axboe@kernel.dk>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Trond Myklebust <trondmy@gmail.com>,
        NFS Mailing List <linux-nfs@vger.kernel.org>
Cc:     Linux Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Ming Lei <ming.lei@redhat.com>
Subject: linux-next: build failure after merge of the block tree
Message-ID: <20190116133552.37436b9c@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/qYOt_5uLb3ymrivCw=yJuQI"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--Sig_/qYOt_5uLb3ymrivCw=yJuQI
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the block tree, today's linux-next build (arm
multi_v7_defconfig) failed like this:

net/sunrpc/xprtsock.c: In function 'xs_flush_bvec':
net/sunrpc/xprtsock.c:390:2: error: implicit declaration of function 'for_e=
ach_bvec'; did you mean 'for_each_net'? [-Werror=3Dimplicit-function-declar=
ation]
  for_each_bvec(bv, bvec, bi, bi)
  ^~~~~~~~~~~~~
  for_each_net
net/sunrpc/xprtsock.c:390:33: error: expected ';' before 'flush_dcache_page'
  for_each_bvec(bv, bvec, bi, bi)
                                 ^
                                 ;
   flush_dcache_page(bv.bv_page);
   ~~~~~~~~~~~~~~~~~             =20

Caused by commit

  f3effe4c1240 ("block: rename bvec helpers")

interacting with commit

  6a829eb8619f ("SUNRPC: Fix TCP receive code on archs with flush_dcache_pa=
ge()")

from the nfs-anna tree.

[I love API changes :-(]

I have applied the following merge fix patch:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 16 Jan 2019 13:32:59 +1100
Subject: [PATCH] SUNRPC: merge fix for "block: rename bvec helpers"

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/sunrpc/xprtsock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 7754aa3e434f..47f29cc23f27 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -387,7 +387,7 @@ xs_flush_bvec(const struct bio_vec *bvec, size_t count,=
 size_t seek)
 	struct bio_vec bv;
=20
 	bvec_iter_advance(bvec, &bi, seek & PAGE_MASK);
-	for_each_bvec(bv, bvec, bi, bi)
+	for_each_segment(bv, bvec, bi, bi)
 		flush_dcache_page(bv.bv_page);
 }
 #else
--=20
2.20.1

--=20
Cheers,
Stephen Rothwell

--Sig_/qYOt_5uLb3ymrivCw=yJuQI
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlw+mIgACgkQAVBC80lX
0Gzuwwf+La/pohlEBDONJUvWmXyLlrYiTe4dk8pUR+R6ScpuMamN+xMQGOuTCHQj
5GNZuNvy2Rvh2H/r4qO3nGJxhWoJoDf8a1bffEK6Kveh6smUm1Ygfgz5DYyym9zN
CaaqG5cZtWDV02w4ipNiRVGBJqcUSuptKAXIxCZuxY7LYUCVFYv43vBLOKSB4BP9
/LkF53i/CF/cKUUHjqTcNEm61N1CO5lVPbCQHKg36Nrk+D09rYRuAdsS2KQHWSkZ
0UgqJBV5thYlLe43UaMcLAzbi6oUc3/GnP3phG+ocGvL4FIFbuA1GCZqX+7aLQQz
rHZCfdywXSNbL1creWVMxbsEgWudMQ==
=9hhs
-----END PGP SIGNATURE-----

--Sig_/qYOt_5uLb3ymrivCw=yJuQI--
