Return-Path: <SRS0=eAd3=PB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7969C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 24 Dec 2018 03:14:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6251921783
	for <linux-nfs@archiver.kernel.org>; Mon, 24 Dec 2018 03:14:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="iSNHmlz9"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726565AbeLXDOB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 23 Dec 2018 22:14:01 -0500
Received: from ozlabs.org ([203.11.71.1]:47273 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726560AbeLXDOB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 23 Dec 2018 22:14:01 -0500
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
        (No client certificate requested)
        by ozlabs.org (Postfix) with ESMTPSA id 43NPTL0yNQz9s3l;
        Mon, 24 Dec 2018 14:13:57 +1100 (AEDT)
Authentication-Results: ozlabs.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
        s=201702; t=1545621238;
        bh=z9qOiTvwb2JmgwxAIwrJlcigkOcbCGSwxjAiyjk+ZIs=;
        h=Date:From:To:Cc:Subject:From;
        b=iSNHmlz9cQBuP+xh0xPFsYO9MQOUOg6yh0dz8BVPyI9hj3bwdMvT3ax+yqZMoGzAq
         XQjV45/aquB5MUJryN0tTp1OF7FhWIrBrDBdMYS4LjZzsmrzY1VPlljw/edTimSbjd
         xWm1tLMtrjaa/KT/99EKkP7ogPCBEyfp4xAdavxRbbMqH7Qx6ucuobCXUGTklfR3bC
         gFe0IgaQnZCNIL+y7isJGAAmNhD9NrHK7Mx09jkvAWlDrTZcU/eTjfbwAuh/+YA2UK
         qvCNqrJUiCAAzp1sGZEcGnqF8bNhE8Igpn2DhxeM3CfndDxeh/6UN3VMmO0EA95LJ1
         nMDeElS3RlOMw==
Date:   Mon, 24 Dec 2018 14:13:52 +1100
From:   Stephen Rothwell <sfr@canb.auug.org.au>
To:     Doug Ledford <dledford@redhat.com>,
        Jason Gunthorpe <jgg@mellanox.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Trond Myklebust <trondmy@gmail.com>,
        NFS Mailing List <linux-nfs@vger.kernel.org>
Cc:     Linux Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Kamal Heib <kamalheib1@gmail.com>
Subject: linux-next: manual merge of the rdma tree with the nfs-anna tree
Message-ID: <20181224141352.461303be@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/ZiqOiSW+DWuqJF10AK2ju+9"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--Sig_/ZiqOiSW+DWuqJF10AK2ju+9
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the rdma tree got a conflict in:

  net/sunrpc/xprtrdma/fmr_ops.c

between commit:

  d31f8deac38d ("xprtrdma: Remove support for FMR memory registration")

from the nfs-anna tree and commit:

  3023a1e93656 ("RDMA: Start use ib_device_ops")

from the rdma tree.

I fixed it up (the former removed the file, so I did that) and can
carry the fix as necessary. This is now fixed as far as linux-next is
concerned, but any non trivial conflicts should be mentioned to your
upstream maintainer when your tree is submitted for merging.  You may
also want to consider cooperating with the maintainer of the conflicting
tree to minimise any particularly complex conflicts.

--=20
Cheers,
Stephen Rothwell

--Sig_/ZiqOiSW+DWuqJF10AK2ju+9
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlwgTvAACgkQAVBC80lX
0GzP5Qf/TSckfmIpZ0ub/Q/xz/cTlbLYXfLcjUR7cFYw/tWmGILGer262rFKyInQ
EkJSJIDlC1J4j8kCyRUn2jXT7XUovFLv1yT6Q+cEpl4PAAsGnTCM+H/FTDAHj3r4
egiVxbJDigkFuFUHAJYlxLw6KUqwZ2QPvpj9fhSG+5TKgeQ97hi9DvGvodh4ABRa
2MkYpa8gEPeh2AdYEeUzJ6EJXxqIDa6QIqhg/uSUcbzKKKxcZAg1r3C3qUOTt/re
6sWb/3H6Lc2iO+pE+ALnOYvsay9Rh1A/LdAICygMklVg04HFKpBKOQy6XR2JPy+8
XPbfaX/PoPd/n9lsBBMDdHbjiQDZ5A==
=e/Po
-----END PGP SIGNATURE-----

--Sig_/ZiqOiSW+DWuqJF10AK2ju+9--
