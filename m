Return-Path: <SRS0=1UK0=RC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24F1CC43381
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 17:37:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A95F620C01
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 17:37:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=pks.im header.i=@pks.im header.b="WDdfJpr4";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="drECnA7O"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728668AbfB0RhK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 27 Feb 2019 12:37:10 -0500
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:45513 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725854AbfB0RhK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Feb 2019 12:37:10 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
        by mailout.nyi.internal (Postfix) with ESMTP id 1236921F3A;
        Wed, 27 Feb 2019 12:37:10 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute1.internal (MEProxy); Wed, 27 Feb 2019 12:37:10 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=pks.im; h=date
        :from:to:cc:subject:message-id:references:mime-version
        :content-type:in-reply-to; s=fm3; bh=6JIXV4spKtvxpPMK+gO7GfimsSs
        u5NOOOgbKIbBmq+0=; b=WDdfJpr4vG2Zte8PWi50Nmqpq+btrvJl7azuOy83Ygn
        LP0vSQLOTyLg2Z7VnzTBYxMrzJ2NZj+UERTaWLy5Usefgosn1rp4dBz7y72SzAYL
        T6snA0KTWgFKg2zSBMThjbSSy7mCEZIO4NCkpVt4/L7q5WAG7IKSvOkoJo4uxmhc
        cnPfm4Qd/g/KIBI0bESxpEaWdlVAKYrfZazd6LuKexGS2u1jC1TAOba3B0iWfvq5
        B2337ZxNlih3Ez3MzgBZsTL81zwnFC+blZKh7Pjlg8LGX+UiT8NEXtGjYBwtSc8E
        I6EFlK8rcDUhj467sxInEUmGs/CJAX5+X88Q9qhxpMw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
        messagingengine.com; h=cc:content-type:date:from:in-reply-to
        :message-id:mime-version:references:subject:to:x-me-proxy
        :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=6JIXV4
        spKtvxpPMK+gO7GfimsSsu5NOOOgbKIbBmq+0=; b=drECnA7O8WnmFjWroi9zwl
        vXRsqff50zpXkwssmnfogGDbKhXfBj5cyLfmB1g/sKnSqXhiqQk0JjKUgjSrhk+5
        gypNKmUh1rcLznU/qsmf6WDDSIIKnnnSwhKGfsSaF1EhvZqeSYzURT1aWoGaUpzE
        4y+h0BjLYPS9LbucISU249oeJYOSf8W9mRwkHVi/T2+xqq+lW1OuNA8HApiOJcgU
        p+P2djJMZyTKX95NKJk55/wgZq06MdsFYRXkriFqt5SYeioPifSLMwARm4f3zEJu
        nkHaI1ijl5/r+oQrkfYJRA5e1wVD8SMEgr27wI7Ad8lYCSc64ZgGJP8gyq1gKTlw
        ==
X-ME-Sender: <xms:xcp2XNok2mxbaKXPMhaLo6ZzN9CWDLC1BDbwkdoZmy3EaVObyqi_mw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrvddugddutdefucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    cujfgurhepfffhvffukfhfgggtuggjsehgtderredttddvnecuhfhrohhmpefrrghtrhhi
    tghkucfuthgvihhnhhgrrhguthcuoehpshesphhkshdrihhmqeenucfkphepkeelrdduvd
    druddvledruddvgeenucfrrghrrghmpehmrghilhhfrhhomhepphhssehpkhhsrdhimhen
    ucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:xcp2XFPsqA51hQZO-4xBvhmQdwZHi6OhQY6I4oL4i8z0rao7ZZvwzg>
    <xmx:xcp2XDy5FO0DgMpFJoom61LVNP4e8qsWYzwSE-AsIT7KeaOm2WesMg>
    <xmx:xcp2XJwEFTuIJJcqAg9MhicKHoorNAmQYL7-LSacHFqktug7xIV_tA>
    <xmx:xsp2XMl72euefhzMozxXf8o20aEnBOM6JW6PNLnLUlinTNa14YzZBA>
Received: from NSJAIL (x590c817c.dyn.telefonica.de [89.12.129.124])
        by mail.messagingengine.com (Postfix) with ESMTPA id DD980E4484;
        Wed, 27 Feb 2019 12:37:08 -0500 (EST)
Received: from localhost (10.192.0.12 [10.192.0.12])
        by NSJAIL (OpenSMTPD) with ESMTPSA id 135487e4 (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256:NO);
        Wed, 27 Feb 2019 17:37:07 +0000 (UTC)
Date:   Wed, 27 Feb 2019 18:37:36 +0100
From:   Patrick Steinhardt <ps@pks.im>
To:     Steve Dickson <SteveD@RedHat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] svc_socket: fix use of undefined macro
 HAVE_GETRPCBYNUMBER_R
Message-ID: <20190227173736.GA1893@xps>
References: <a6f2aaea93c1293e62d5109b10d47a7675a45393.1549290423.git.ps@pks.im>
 <5e9826aa52e17d30d7cfee0d3828c5dbecdbfc41.1549290423.git.ps@pks.im>
 <b4f940b5-d073-7aff-7f20-0644a6e57be4@RedHat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="5mCyUwZo2JvN/JJP"
Content-Disposition: inline
In-Reply-To: <b4f940b5-d073-7aff-7f20-0644a6e57be4@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


--5mCyUwZo2JvN/JJP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Feb 27, 2019 at 12:16:18PM -0500, Steve Dickson wrote:
>=20
>=20
> On 2/4/19 9:31 AM, Patrick Steinhardt wrote:
> > The macro HAVE_GETRPCBYNUMBER_R is set based on whether the
> > `getrpcbynumber_r` function was found by autoconf or not. While another
> > location correctly checks whether it is set by using `#ifdef`,
> > `getservport()` instead wrongly uses `#if HAVE_GETRPCBYNUMBER_R`. This
> > may cause a compilation error with gcc with "-Werror=3Dundef" if the ma=
cro
> > has not been defined.
> >=20
> > Fix the error by using `#ifdef` instead.
> >=20
> > Signed-off-by: Patrick Steinhardt <ps@pks.im>
> Committed...
>=20
> BTW... If the future, feel free to ping me it appears=20
> patches slide off my radar... like these did... ;-(=20
>=20
> steved.

Will do. I know from my own experience that it's hard to keep
track and be able to always respond in time :)

So thanks for your review and for committing them.

Patrick

--5mCyUwZo2JvN/JJP
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEtmscHsieVjl9VyNUEXxntp6r8SwFAlx2yuAACgkQEXxntp6r
8SxTUg//SyiVeQKPiPyvHoXNGUJCNNoVt7R4wUdWCbTMjBl0LX5XTPu9KYze40jp
Q6HJizzwhU+6+mrOm5MTuXykKslPKx9ZkAoLoihzOcHeLQoeuhQhrWJbv8rDzzmj
gxFoSz6zCsCWSGMgJUKZFArdP28SnMVP6NpURvt/WCnV+wOUm2Fhomf1tfOB8Idj
WVl5/ui5qzwNloLI/HIjjzuJUl9e1anCfmssjLIbJ5eSHiPfzACE1cHHkjIR86Gs
YiuIdhGA+eOCO3DpSLN7MeFRFYjC7j7+pocViUtbF1Sj6pF05Re/Kca/ZzAPfrjf
QMwpfVh9gQNZHOVIdIe3ew1wCJ8vyREFUSYhYPLDQgw5Y+f65ayvtAfYsLnnBlj0
6XkUMH1F9So2AFrAipMN6LXMbkw0+Q2JSgXNgr2or6E7PglQX4w0EN7mYTRt7/iF
aF1+xFw5/cfFPXdz8AqEk38AaYOjBMCJ89BbG5rRXpM7rqY11We1382u05p2QwCW
e4T2d45HqXqrV5EI22THSKW7qX/y58iPHe4Vub+XhIXMSFQSic7uoL10o1fOBe1Z
UEIWR8kOmP9il1XswQGlwLvYwj5snflwocINbjE0yFMRDmNIUwSzpnQ4oPWXxWKr
T3Ouj6osWZDI/N0XI5j8UlUOKMDgalwiZ2bJkLu9ssYau428gj0=
=hNAS
-----END PGP SIGNATURE-----

--5mCyUwZo2JvN/JJP--
