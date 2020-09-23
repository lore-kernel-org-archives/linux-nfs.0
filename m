Return-Path: <SRS0=5zCG=DA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CE52C47425
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Sep 2020 15:17:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id D7C592075B
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Sep 2020 15:17:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1600874243;
	bh=/QQofHRADGAYxOtJIce3d38QkMvme+6u661AK0sTIww=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=AAwCIDxxh7YhS+QzjC2fi5JBdF/0DUQuc3ysPimXiCzDvlmKvhxJgfeFURL1RLvGk
	 USqIx1YnKHEY/uhWOkrcGSW/ZpmQ1HVEVJRUWw4HTygC5K23X4EG3cf3Celfdt6eG5
	 C9Ik/AeCZEo16reBz743lqwYgWHHe/8vlDHGCzgk=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726865AbgIWPRQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 23 Sep 2020 11:17:16 -0400
Received: from mail.kernel.org ([198.145.29.99]:60766 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726156AbgIWPRP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 23 Sep 2020 11:17:15 -0400
Received: from localhost (fw-tnat.cambridge.arm.com [217.140.96.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 6077C2075B;
        Wed, 23 Sep 2020 15:17:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1600874234;
        bh=/QQofHRADGAYxOtJIce3d38QkMvme+6u661AK0sTIww=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=qaL+99AxNSM+PUkApT/4Pupcbe3cWXnIOAQs/ZT35oiBfgpa53MHX/m6TMpBock3a
         fQSnODIgnUVdnSkWJ0pBplNyHoTqkHuo7hhaFUgOEQ4u+Awe/y3f+CYmaRRBSsJrRv
         ycipz9I2nQvfISAkNRMDRLNIxu8SAq09SP1ymhKs=
Date:   Wed, 23 Sep 2020 16:16:20 +0100
From:   Mark Brown <broonie@kernel.org>
To:     Rolf Reintjes <lists2.rolf@reintjes.nrw>
Cc:     linux-spi@vger.kernel.org, Julia Lawall <Julia.Lawall@inria.fr>,
        linux-serial@vger.kernel.org, linux-scsi@vger.kernel.org,
        target-devel@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-media@vger.kernel.org, linux-block@vger.kernel.org,
        Yossi Leybovich <sleybo@amazon.com>,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        dmaengine@vger.kernel.org, linux-pci@vger.kernel.org,
        netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
        linux-rdma@vger.kernel.org,
        Dan Williams <dan.j.williams@intel.com>,
        rds-devel@oss.oracle.com
Subject: Re: [PATCH 00/14] drop double zeroing
Message-ID: <20200923151620.GC5707@sirena.org.uk>
References: <1600601186-7420-1-git-send-email-Julia.Lawall@inria.fr>
 <160070750168.56292.17961674601916397869.b4-ty@kernel.org>
 <c3b33526-936d-ffa4-c301-4d0485822be1@reintjes.nrw>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="NU0Ex4SbNnrxsi6C"
Content-Disposition: inline
In-Reply-To: <c3b33526-936d-ffa4-c301-4d0485822be1@reintjes.nrw>
X-Cookie: This report is filled with omissions.
User-Agent: Mutt/1.10.1 (2018-07-13)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


--NU0Ex4SbNnrxsi6C
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Sep 23, 2020 at 05:10:33PM +0200, Rolf Reintjes wrote:
> On 21.09.20 18:58, Mark Brown wrote:

> I do not understand which of the 14 patches you applied. Your mail responds
> to the 00/14 mail.

As the mail you're replying to says:

> > [1/1] spi/topcliff-pch: drop double zeroing
> >        commit: ca03dba30f2b8ff45a2972c6691e4c96d8c52b3b

--NU0Ex4SbNnrxsi6C
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCgAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAl9rZsMACgkQJNaLcl1U
h9AxAgf/UlZBlBEQmArmMghyqM+HNmgNqZcFWWNnNQSmBBrgl8128+pLwAgIeZLw
0l6J3hL0JAr1ozAMpm1RGS/xj2CD8a6QFiRw+9wAgL9eY3DAdognRwtwLJlW6zq3
nj2VF+7+R6LhZGxqub8TnxUZLSdlop3wn9ZuAnTRZjjhPq2iidr4iYPWYsGqo+j5
svVy+eYILC3/Y6X31PpT2OXujQXkrrCGlONZz2ieOMTLSLNQhL8pZh8tkJB9s/F5
U60+SPDeI7yrVh6k5/iCldI5JHQyjXAmHza4R6BzKTc6kgSDvUlzrVOZxw1aaGy+
EFLE4qdwQYEPaeRMZ+XVpSUbf3dGUw==
=Rrao
-----END PGP SIGNATURE-----

--NU0Ex4SbNnrxsi6C--
