Return-Path: <SRS0=V3X6=Q4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 683D3C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 23:23:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 364B02077B
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 23:23:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="WPQacMIq"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726237AbfBUXXo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Feb 2019 18:23:44 -0500
Received: from ozlabs.org ([203.11.71.1]:47553 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726035AbfBUXXn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 21 Feb 2019 18:23:43 -0500
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
        (No client certificate requested)
        by ozlabs.org (Postfix) with ESMTPSA id 4459Wx1Fn6z9s1B;
        Fri, 22 Feb 2019 10:23:40 +1100 (AEDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
        s=201702; t=1550791421;
        bh=TxfOWlom4PJ1Y4jJNP7AyzsHwRzU05PaFCwuM5nUqbo=;
        h=Date:From:To:Cc:Subject:From;
        b=WPQacMIqkLK3Oc74fp3JssNb8tO7pvU09y7ipVWY3yv/RBXFo8jy+4OuJIk9MJhg7
         nXpGb0h3ivBk8yQt8sktDEg8+TBhjy3ZKAOxZXeFCuD0aTOhnERdUN2Cbd1Ei79jRC
         u9rn6A3qRJK/m/Fnm9bCG2DZOd/eISYblCGmflXW8yIjXoqDsE60Aavx2p6O3KOX31
         2WBxrzs5AAEZMju8yxwFv86rUfWwbxmjtCVZklfCUE0CCPaCx4HCMycukGI0Jal32+
         VTyOda7yo2tbPqgBkPvxXsvq3quFtf97X5tAlr1QAi2VxioIbTLZWGrl4FdK8ngJ2U
         PuFIt4agjZ9tw==
Date:   Fri, 22 Feb 2019 10:23:40 +1100
From:   Stephen Rothwell <sfr@canb.auug.org.au>
To:     Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Trond Myklebust <trondmy@gmail.com>,
        NFS Mailing List <linux-nfs@vger.kernel.org>
Cc:     Linux Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: linux-next: manual merge of the nfs-anna tree with the nfs tree
Message-ID: <20190222102340.3298742c@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/8y0o.51I1gOnmRaJ+ngAOPT"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--Sig_/8y0o.51I1gOnmRaJ+ngAOPT
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the nfs-anna tree got a conflict in:

  fs/nfs/pagelist.c

between commit:

  df3accb84960 ("NFS: Pass error information to the pgio error cleanup rout=
ine")

from the nfs tree and commit:

  7517d01d20e1 ("FS: Pass error information to the pgio error cleanup routi=
ne")

from the nfs-anna tree.

I fixed it up (I just use the former version (since there are
other changes to this file in that tree)) and can carry the fix as
necessary. This is now fixed as far as linux-next is concerned, but any
non trivial conflicts should be mentioned to your upstream maintainer
when your tree is submitted for merging.  You may also want to consider
cooperating with the maintainer of the conflicting tree to minimise any
particularly complex conflicts.

There are a few common patches (as differetn commits) in these 2 trees,
so one should be cleaned up, please.

--=20
Cheers,
Stephen Rothwell

--Sig_/8y0o.51I1gOnmRaJ+ngAOPT
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlxvMvwACgkQAVBC80lX
0GxtXwf/R9n7ATjU16gHD2JUuETP140yf0RXsfcAR5m/W8fecSuKyPbPyD6DKJLs
mHRseG32w/pBZl+chE2gNGE0FgxHbzuBT2iE4iYx664jJ2AscdPoL0MU9FpbTRNu
Bk4njvTgBlR6hVsy2ttM9jUkWyT/UYQxhDm8oCtAZb37GDTOrvEE4HSNdI0iAXqD
YZfEm+f+NIXwnkoZkJfUNNqMEzEItFXdJKjdimQlnsAERE7U1B7tbGMwZDNwrL+o
g5/+GgZmBXd8dYx0xBZIwT+l2FRjqRNm1I2zovpPYZz7mj7VuWvaq3GLzsV7YVv6
NfAFIxGu60kCIIamYYppapYRqvCAKA==
=sBbd
-----END PGP SIGNATURE-----

--Sig_/8y0o.51I1gOnmRaJ+ngAOPT--
