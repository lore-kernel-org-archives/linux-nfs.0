Return-Path: <SRS0=9Ter=N7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14C92C43441
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Nov 2018 05:37:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CB8ED206BB
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Nov 2018 05:37:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="PuT6g85F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB8ED206BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730372AbeKTQFN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Nov 2018 11:05:13 -0500
Received: from mail.kernel.org ([198.145.29.99]:54790 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726883AbeKTQFN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Nov 2018 11:05:13 -0500
Received: from localhost (unknown [77.138.135.184])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id C2C7220685;
        Tue, 20 Nov 2018 05:37:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1542692277;
        bh=7C7qcT0hTA6qABd9XanvxS2yXnrOeweOhvMHa8uvNa0=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=PuT6g85FlTr46xGEJbeed1bVZVVcPtevpsqB4gf0RS5qGcycebMpiKUORwd8IK/Cd
         IyyQ7NgW8bN6ikWia9RNjcm6c5M7+YawdCDJNOMdDrSea0wEsnumj90sZoq3GJEa/N
         ivwkMhtFhSJd+p9CswsekHURUWQ4Eba3p54T7OlI=
Date:   Tue, 20 Nov 2018 07:37:52 +0200
From:   Leon Romanovsky <leon@kernel.org>
To:     Bart Van Assche <bvanassche@acm.org>
Cc:     Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org, oulijun@huawei.com,
        zhongjiang@huawei.com, venkata.s.dhanalakota@intel.com
Subject: Re: [PATCH v1 1/4] xprtrdma: Remove support for FMR memory
 registration
Message-ID: <20181120053752.GF25178@mtr-leonro.mtl.com>
References: <20181119153707.10832.42881.stgit@manet.1015granger.net>
 <20181119154551.10832.5498.stgit@manet.1015granger.net>
 <1542644197.185366.50.camel@acm.org>
 <20181119190913.GC21715@mtr-leonro.mtl.com>
 <1542660730.185366.62.camel@acm.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="TeJTyD9hb8KJN2Jy"
Content-Disposition: inline
In-Reply-To: <1542660730.185366.62.camel@acm.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


--TeJTyD9hb8KJN2Jy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Nov 19, 2018 at 12:52:10PM -0800, Bart Van Assche wrote:
> On Mon, 2018-11-19 at 21:09 +0200, Leon Romanovsky wrote:
> > The more accurate question is "how many customers ... use latest,
> > upstream kernel?"
>
> Hi Leon,
>
> If this would not be clear: I am in favor of removing kernel drivers that
> are no longer in use. Recently I supported a proposal to remove the SCSI
> OSD driver from the kernel tree because that driver
> probably has not been
> used by anyone in the past five years.
>
> But I think that kernel drivers that are still in use should stay in the
> kernel tree, no matter which version is in use. Since the Linux kernel ABI
> is backwards compatible, with every Linux distro it is possible to replace
> the Linux kernel that was provided by the Linux distributor with a more
> recent upstream kernel. I think it would be a very unpleasant surprise for
> people who use one of the RDMA adapters that only support FMR if they would
> test a more recent kernel and if they would notice that its driver has been
> removed.

Bart,

I know the theory behind promises to work on old HW, but the reality
that no one really tests latest kernels on those devices.

This article complains about it too:
https://lwn.net/Articles/769468/


Thanks

>
> Bart.

--TeJTyD9hb8KJN2Jy
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJb852wAAoJEORje4g2clinUpEP/RFjfFMoVbgdszTPT9PC9mSk
7ZpHyeO9vVUD5Oj69io/hV7YFZI4NBmpOVBqXPflguPqyLAg2cOG9rMerSzZdsqU
sJaHbs8GV6kEYJKcLkYyqJIacDzgXb3U9MA+Vucqn5GhrVfkuWcXR6s0Pe4Qnu6h
N5VJTWURe1UARIBVFlKI0B04IQG2zWFABNtUpFX5g4pwRP3KVptKeXbCt307e3F+
tBCPeCIhr6WrjJRCwKot5sYCrjkAbMEWaZDcZqDbPe2ND6Wzd4h3OVzf+34gllu7
kCy+hKvlz9gvKwYydu69Fd/9k8ftl3IjgAcgF/pItK1vKl1Hpt7wuO8uSB67ynFH
+xlgabdhcZnF72HJ4nnFCs0h+Jz1RekdLzhl9+N0HwTazZRTwuRlIkP8XHsO7yIA
ENloEp0Atu1ZToFT+jTda0WagRixjvuaFTtAt+SrwGY2ZUKDfc3eILHewOr5NvL7
+iO4YcPJBkIB3FW2ERSGXQA+f3BKzY4lJdEtKYcjM5Rj9Wx2I6aOclCpvxk+LNOH
aVBuVf55fbutgcFj7XO3V9VmGc7MD9V4WpcKzhwBa8VWcjBvSWczYB6ST3tcstIS
w8Q2Ui1CDjmm2e9HXTJWd4NbooOMoyWeLzjGxrIKiguRzzOe+lN7yn56pyHXJbmz
lpApFMw0gGzzfeoXwL8e
=szkf
-----END PGP SIGNATURE-----

--TeJTyD9hb8KJN2Jy--
