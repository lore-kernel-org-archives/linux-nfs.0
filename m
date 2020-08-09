Return-Path: <SRS0=XJYd=BT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.1 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PULL_REQUEST,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 710BFC433DF
	for <linux-nfs@archiver.kernel.org>; Sun,  9 Aug 2020 23:03:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 4A220206A2
	for <linux-nfs@archiver.kernel.org>; Sun,  9 Aug 2020 23:03:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="U+UoGNrq"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726472AbgHIXDx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 9 Aug 2020 19:03:53 -0400
Received: from bilbo.ozlabs.org ([203.11.71.1]:60825 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726323AbgHIXDw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 9 Aug 2020 19:03:52 -0400
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
        (No client certificate requested)
        by mail.ozlabs.org (Postfix) with ESMTPSA id 4BPvm621Mgz9sRN;
        Mon, 10 Aug 2020 09:03:50 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
        s=201702; t=1597014230;
        bh=8+FYoUMfOB2DGkg2rvx7MSZ+VDwo2cGk6z7z/iLJ1CY=;
        h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
        b=U+UoGNrqw4BQbq28RXKC6vYf6dKXOa44/GxpVkjbk0HoFQ9yWnhVVVofNtwBXaZCI
         HCmh2dsvAEwj7EkPAbZd9dlXMIxHoKP5OS1/wgohcIafTRNlDZBrmrYxP+9HobD7CS
         GcxuVub/yYVaNsEzbO6IsdQdIofSGd/OOuHBhyPuFUhJ/fIDAzgM4Aw0m1a6yPeijL
         XeQZ14QsonCmkQtmTu5SMu+1hkRQnUBaPqZLoDvP8fqW25GhLfkmyDf17uPAQkKeip
         PYGaAK8l53LNe3tSJ2scQz7qNfGIgVAlftsT8hQRqnGP9NkPJgAF8zyV3jJzFbgWpj
         82ipXZesc4++A==
Date:   Mon, 10 Aug 2020 09:03:49 +1000
From:   Stephen Rothwell <sfr@canb.auug.org.au>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>,
        Trond Myklebust <trondmy@gmail.com>
Subject: Re: Please pull NFS server updates for v5.9
Message-ID: <20200810090349.64bce58f@canb.auug.org.au>
In-Reply-To: <F9B8940D-9F7B-47F5-9946-D77C17CF959A@oracle.com>
References: <F9B8940D-9F7B-47F5-9946-D77C17CF959A@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="Sig_/tsh/2wjsP/ZVCBtHdm.gcwh";
 protocol="application/pgp-signature"; micalg=pgp-sha256
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--Sig_/tsh/2wjsP/ZVCBtHdm.gcwh
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Chuck,

On Sun, 9 Aug 2020 11:44:15 -0400 Chuck Lever <chuck.lever@oracle.com> wrot=
e:
>
> The following changes since commit 11ba468877bb23f28956a35e896356252d63c9=
83:
>=20
>   Linux 5.8-rc5 (2020-07-12 16:34:50 -0700)
>=20
> are available in the Git repository at:
>=20
>   git://git.linux-nfs.org/projects/cel/cel-2.6.git tags/nfsd-5.9
>=20
> for you to fetch changes up to b297fed699ad9e50315b27e78de42ac631c9990d:
>=20
>   svcrdma: CM event handler clean up (2020-07-28 10:18:15 -0400)

Despite you having a branch included in linux-next, only one of these
commits has been in linux-next :-( (and that via Trond's nfs tree)

--=20
Cheers,
Stephen Rothwell

--Sig_/tsh/2wjsP/ZVCBtHdm.gcwh
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAl8wgNUACgkQAVBC80lX
0GzUNgf/VEb6yo8no0+KOY97aSywexi39rsxt1uSY65fs1slhdub5ENU/7S2cXDc
xeG4cj0GihL8VPEg7gAo+okayHNTK5uI/7gRU227AOPOfaGfomAoqWd6XyTANyi4
9plvlCne/AYVbykYuq9jka0l/bfgTpcgzv7KgAfl0ZtKicilpuoQyMKewv2kGiXl
7naDhkhbhwMdCK30sjLPg7OzL0EGZ3y/NekG+rX8QwHW9L3dHexf2lMLTqPDmqow
VpFWTAOoiT7GOiuUgWkaJ7Awog13W1ZKA3MnTJ0zPpzciX2PpXuNhsFVSw7BBYA+
qPyKWwM5PfuK6Sf9qqo0wYsHbQ0idw==
=C5Y9
-----END PGP SIGNATURE-----

--Sig_/tsh/2wjsP/ZVCBtHdm.gcwh--
