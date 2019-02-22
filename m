Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1A01C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 07:52:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 09BB4207E0
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 07:52:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=pks.im header.i=@pks.im header.b="Bht0ZtWG";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="8Uomt/zZ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725860AbfBVHwH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 02:52:07 -0500
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:51167 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725855AbfBVHwH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Feb 2019 02:52:07 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
        by mailout.nyi.internal (Postfix) with ESMTP id 0E93921B55
        for <linux-nfs@vger.kernel.org>; Fri, 22 Feb 2019 02:52:05 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute1.internal (MEProxy); Fri, 22 Feb 2019 02:52:05 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=pks.im; h=date
        :from:to:subject:message-id:references:mime-version:content-type
        :in-reply-to; s=fm3; bh=6V+arGLDNVKIjM+Uad0SKPkjnaBa3vBhAYjTTMhN
        vDI=; b=Bht0ZtWG58v78lxtHEyuiKkZNqDBEiLrxN349RvpZtcIGNKvFstCngIb
        Fule9vts7G4+j9XHffMDscwU9MT1iYEDOEA5y/wQLwiD1jQwvCe+kzG5bkcHI8qk
        E5rfQZ0TJtlzJ4KYGbF4fwYEp9YPhdR3D+++pFFaanG0B6I31MaLP8YA3C56+Zov
        dUy3qHDaetr62NlRALLTBeNFpd394vVYshrNjzOT7kUFZAe6c8wu6jPbnXisblvC
        1epjyXJgWywt7hAERgkTvu5zrYn3P3cQLfyFm73X2d0WtqXPfJ38k9PKhA3o7r9G
        NV4qe2KnGW3qMWB1jBPcj9y/OTcDFQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
        messagingengine.com; h=content-type:date:from:in-reply-to
        :message-id:mime-version:references:subject:to:x-me-proxy
        :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=6V+arG
        LDNVKIjM+Uad0SKPkjnaBa3vBhAYjTTMhNvDI=; b=8Uomt/zZ/RKH+ubA1MB02E
        q/RV/6TGY+TzKNV3WzNyajCM1ngjIGcw7dtiRBinpZo1B1uI6J7Lz59C12etAmYt
        TQ4YXyN7stkDIOUlWyyZ4cVGDEY0ivbuJkCANcW73CqBhdGWC/11N+713B+B4FcT
        WqFdPeOHNhr8I83WF5eqgiH8V99jlzTqAU2WujhE8M0rKQpaTmHEVDtdZU8vg91e
        0jgBtqS8FO9SJGgDN7SH75F1or2hGmPVM+eDokR2eHvLZfAkK158irr9umFyua8b
        6fO1TtRb8HxV3TT7q96mqCyBeu5wtBVAl11dm2NoqDObMGXe7Nl/mgwaEtFWZZxA
        ==
X-ME-Sender: <xms:JKpvXPDCNxCuiRiTnhrGV5sdGGBaW9GJgY7Qp2Uj2xcXd3lxmKcJgg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrtdelgdduuddvucdltddurdegtdelrddttd
    dmucetufdoteggodetrfdotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfquhht
    necuuegrihhlohhuthemuceftddtnecunecujfgurhepfffhvffukfhfgggtuggjsehgtd
    erredttddvnecuhfhrohhmpefrrghtrhhitghkucfuthgvihhnhhgrrhguthcuoehpshes
    phhkshdrihhmqeenucfkphepjeejrdduledurddufeeirdefleenucfrrghrrghmpehmrg
    hilhhfrhhomhepphhssehpkhhsrdhimhenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:JKpvXD47Oi2rZAuPH0YW_WwTzUcIGIDiOu6HGcaSMeYXYIZ6qTIDMg>
    <xmx:JKpvXCr5PEdqq9KSO50Bgl9b_uebyIjyYbYGmS6JZvX8Ct0jjk-qSQ>
    <xmx:JKpvXG9TazMF36blmysVLMdd0k0a0aYS3NpfrOQK5siykKmyy8GKtQ>
    <xmx:JapvXNS-UGvUyKCdM9X8ARNrJkmn5GZqaDgEOOLjk5SUD_FroO_3sQ>
Received: from NSJAIL (x4dbf8827.dyn.telefonica.de [77.191.136.39])
        by mail.messagingengine.com (Postfix) with ESMTPA id 2DB6BE425A
        for <linux-nfs@vger.kernel.org>; Fri, 22 Feb 2019 02:52:04 -0500 (EST)
Received: from localhost (10.192.0.11 [10.192.0.11])
        by NSJAIL (OpenSMTPD) with ESMTPSA id d3f62c8e (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256:NO)
        for <linux-nfs@vger.kernel.org>;
        Fri, 22 Feb 2019 07:52:02 +0000 (UTC)
Date:   Fri, 22 Feb 2019 08:52:02 +0100
From:   Patrick Steinhardt <ps@pks.im>
To:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] configure.ac: more carefully detect availability of
 res_querydomain(3)
Message-ID: <20190222075202.GA13960@ncase>
References: <a6f2aaea93c1293e62d5109b10d47a7675a45393.1549290423.git.ps@pks.im>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="x+6KMIRAuhnl3hBn"
Content-Disposition: inline
In-Reply-To: <a6f2aaea93c1293e62d5109b10d47a7675a45393.1549290423.git.ps@pks.im>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 04, 2019 at 03:31:18PM +0100, Patrick Steinhardt wrote:
> Since glibc 2.2, the function res_querydomain(3) is implemented as a
> define to `__res_querydomain`. Due to this implementation detail, using
> `AC_CHECK_LIB` with a symbol name of "res_querydomain" will cause a
> linking failure and thus fail to detect its availability. This is why
> right now, we try to detect availability of `__res_querydomain` instead.
>=20
> Unfortunately, this may break on other platforms where there is no
> `__res_querydomain` but only the function without leading underscores.
> To fix this, we can perform another `AC_CHECK_LIB([resolv],
> [res_querydomain], ...)` call in case where the other one was not found
> and only raise an error if both symbols weren't found.
>=20
> Signed-off-by: Patrick Steinhardt <ps@pks.im>

Is there anything I can do to get this rolling and improve my
patches? Or did I accidentally pick the wrong mailing list for
the userspace part of nfs?

Patrick

--x+6KMIRAuhnl3hBn
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEtmscHsieVjl9VyNUEXxntp6r8SwFAlxvqiIACgkQEXxntp6r
8SwG/A/+P0Qn7LNjT6t/OLPud9K9Ff2Nig3781LulesvSvZX2BSYuhLCfP9dCZQ1
tH8WXx5dxivzPsQ2Wo2CgbwWoKeTNPhWk+fvLSt7i0S5PhM51dU3SShAtpWHYEm1
stB1sYJdlqexEzrBsOWBtWR9fbV2bJjnhmW9BXr9QV79XnbCgf2q6xWQMSvtvLrw
hbBdKK2LI6sXfKE3Us+vhfcYE9tE720usqnBuTiPsw6/EfTQXaHBqxgufKJONLyT
PcuwtyiDmsKbtI3gv4jfM5yE9glN6Fv/pSWIGfh7jLt8VyPaZ8+BFIAg20F5WSLT
g1SiAupHVBsYp8GwmGyG3+8m29OEK67egP+XCeMpA/yN5osIlf6oUUwJ38CFzSY/
QJFBkhR4qV1mKsuJLmofiZ+KEIXnH6b3lwFx2XVwAAYkGDqoXX4di4lBfOsC6pz4
DsnuVFLYETaGi9f5g4homnX5sIwr01NPEQ22R1S6YRz7mQWXFcwWeQmLNg8WZhAe
P1VmysxstgTpI6q9+E3Hcf4wwGGzQXir466EpnxnmRwzwC26oqkFFgFa/+8+s1Yj
Ot3VkUnrCL6DapiwKOvL2f11wFVw11m1XhNQqjOYy3WJbmHJZlpiWxC7jObT9SgD
GK7hJMMxi+1YaTnkPp4sgCFeftYebSMPqBrVN6BInHsttkgKwCY=
=3kDl
-----END PGP SIGNATURE-----

--x+6KMIRAuhnl3hBn--
