Return-Path: <SRS0=dkOU=OZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A237C43387
	for <linux-nfs@archiver.kernel.org>; Sun, 16 Dec 2018 06:19:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 240E92084D
	for <linux-nfs@archiver.kernel.org>; Sun, 16 Dec 2018 06:19:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="tqgFYWmG"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729784AbeLPGTi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 16 Dec 2018 01:19:38 -0500
Received: from ozlabs.org ([203.11.71.1]:39093 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729709AbeLPGTi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 16 Dec 2018 01:19:38 -0500
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ozlabs.org (Postfix) with ESMTPSA id 43HYzC0lB2z9s5c;
        Sun, 16 Dec 2018 17:19:34 +1100 (AEDT)
Authentication-Results: ozlabs.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
        s=201702; t=1544941175;
        bh=fwwniTExdShjFng6gIJTj8vHWpO3lZ9o85AbDaqPdD8=;
        h=Date:From:To:Cc:Subject:From;
        b=tqgFYWmGrWSWnGAMpvrT+dxyldtH3gD4UWsFL8Mr5eBkmHm7PM91yre0ZQ/M7Nm+K
         cjcLLpivTiypRlW0eI9H0jeU3hglGA/mFXYbDW7ukcnIL5C3zYIYO7i9yh1823siob
         7qnbBWZq35mvwKhSy0Fm89hR64HOSd9fb5I04wohN3iDNZkOK71sQYlsG2KlFX78in
         p+4oivKpPMvVzQ22xl7FfV8NzOQ19KJbWVDElT02YISlXG5FR+U3kucRuD5uA16+Lt
         UBA7jguEHfbpMX5COP/R0CPiLRwPHP74n9RxIclZRFJvIWaPDrjsbQnVEhbWVAPyKI
         F2kOy7B+R9buw==
Date:   Sun, 16 Dec 2018 17:19:33 +1100
From:   Stephen Rothwell <sfr@canb.auug.org.au>
To:     Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Trond Myklebust <trondmy@gmail.com>,
        NFS Mailing List <linux-nfs@vger.kernel.org>
Cc:     Linux Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Chris Perl <cperl@janestreet.com>
Subject: linux-next: Signed-off-by missing for commit in the nfs-anna tree
Message-ID: <20181216171933.2e4f5be6@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/3RT=MiBclA4Q8w.HQBO/OP5"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--Sig_/3RT=MiBclA4Q8w.HQBO/OP5
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,
Commit

  748d6fd8d297 ("NFS: nfs_compare_mount_options always compare auth flavors=
.")

is missing a Signed-off-by from its author.

--=20
Cheers,
Stephen Rothwell

--Sig_/3RT=MiBclA4Q8w.HQBO/OP5
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlwV7nUACgkQAVBC80lX
0GxgzggAj4BfOFuDIGpEioPZalfdSnSFZUK89ecT2XXBpxTEYkFlW/NrFdC/elLq
zafRFImRNlUA/YmmPWQvykv6BkLA9OZU+00zp++Kw5Mbz4AegRe35OzUh5UOFf6B
2C1kA0bYMFab3240ovKIyuJHjrN6cWXT/e8xW0y0+HeBbqN1N5YJkpp1mdAMnIlN
z7053xnhRgiJrtFpxfR5e2yuqC25nDmwuF3qW49LycxbkeWFrjtzUZ75tF/k/JJu
tGV994g1fwW3PjkegGx35Xp8M1jl+CoApIsPRMRpkme1jloFl85GFoicbveYhijK
sCd5TUFhegTnCtCojXm4V8nvbUkxGA==
=tj8C
-----END PGP SIGNATURE-----

--Sig_/3RT=MiBclA4Q8w.HQBO/OP5--
