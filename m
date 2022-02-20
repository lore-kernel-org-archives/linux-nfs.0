Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D86CC433F5
	for <linux-nfs@archiver.kernel.org>; Sun, 20 Feb 2022 10:01:23 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S236719AbiBTKBD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 20 Feb 2022 05:01:03 -0500
Received: from mxb-00190b01.gslb.pphosted.com ([23.128.96.19]:42904 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231245AbiBTKAg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Feb 2022 05:00:36 -0500
Received: from jabberwock.ucw.cz (jabberwock.ucw.cz [46.255.230.98])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 983BC546B5;
        Sun, 20 Feb 2022 02:00:11 -0800 (PST)
Received: by jabberwock.ucw.cz (Postfix, from userid 1017)
        id 57F381C0B7D; Sun, 20 Feb 2022 11:00:10 +0100 (CET)
Date:   Sun, 20 Feb 2022 11:00:09 +0100
From:   Pavel Machek <pavel@denx.de>
To:     Sasha Levin <sashal@kernel.org>
Cc:     linux-kernel@vger.kernel.org, stable@vger.kernel.org,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH AUTOSEL 4.19 09/11] NFSD: Fix offset type in I/O trace
 points
Message-ID: <20220220100009.GA7321@amd>
References: <20220215153104.581786-1-sashal@kernel.org>
 <20220215153104.581786-9-sashal@kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="YiEDa0DAkWCtVeE4"
Content-Disposition: inline
In-Reply-To: <20220215153104.581786-9-sashal@kernel.org>
User-Agent: Mutt/1.5.23 (2014-03-12)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> [ Upstream commit 6a4d333d540041d244b2fca29b8417bfde20af81 ]
>=20
> NFSv3 and NFSv4 use u64 offset values on the wire. Record these values
> verbatim without the implicit type case to loff_t.

AFAICT this is already in 4.19.X-stable queue, so it can be dropped
=66rom AUTOSEL.

Best regards,
							Pavel
						=09
--=20
DENX Software Engineering GmbH,      Managing Director: Wolfgang Denk
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany

--YiEDa0DAkWCtVeE4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAmISESgACgkQMOfwapXb+vL3RgCfYl6Y0dPlg1mLsL4bxhh9kapu
720AnRifTTpgTIgvZlVg6ld8dHogiv2I
=5v1A
-----END PGP SIGNATURE-----

--YiEDa0DAkWCtVeE4--
