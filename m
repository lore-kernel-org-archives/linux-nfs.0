Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6B47F353A98;
	Wed, 19 Aug 2026 14:27:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787149673; cv=none; b=eJ5e2HwldPAbQubY8wPZEvE7YDovK3K1QuDIEjFXtf6O8FyszwnQZEBRiP6YGq9/nBHiax1klJZtUjB6SSO6r9wJiPwrtcZV1dO8L6PGuGTadDBHblI7VYewz4N2WFGjgJWoeUsuhh4JzBANmGGNsbnp4mCWcYY8IxWpyUmXyew=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787149673; c=relaxed/simple;
	bh=NHoUbGjcO2PvF2La8kqB4+59XvTXISg0J8YbFOlwcx4=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=twQLFBPq7jO/ulDTSwBOzsw9FGq71ICi5bwSCLAt4JSPKXKhhgdbrjtTTxKTAYXe2Jiz2rI8Isab0N4DjKM4B3d8/JfjfF9oTwP1CmzRZ+O9xBfLFqaslEzXGP+uSkxS6DnBP9lHDGin0qKxNG8YikLtdnZty1r7nrXToI2Fn/s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=M/9Jm1qK; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="M/9Jm1qK"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 781EA1F00A3D;
	Wed, 19 Aug 2026 14:27:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787149662;
	bh=EcDuSayj2m9qHiZorQeDqQh33qvlrFcDpLCoPmkp2l4=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=M/9Jm1qKWk8JpAJGHwfxz7qiVSo0vAv8BkrOHbtfxW7PZJmx3v2UR/xG64aRQJ2ew
	 GV+Nqja+OR0KaADKKiJdQ9O4eQvcSSRAEUeKVBZSSplhQIsd0pm7DJqJVrmYC4IIK0
	 0+PwXdA+c6p1XgqhZW+2wlSeQpxJQZysPPWd3NnbKaKCguSrje5YRYQSVATiS7HDqk
	 WmqdmiEbwiAbXCMWKzMzggm+D0gwQdLPPjiH/7CoTO3DBLpjvWsxUh6T/AXIIuOHSF
	 iZbJAzPuf4iopROGK0SPG2BxIdIXkadO6ig3z4Oc3RXNOlEnCbkuMI7vGTKEFSoyMI
	 63ij5m3wDgBNA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id AD3B6F40068;
	Wed, 19 Aug 2026 10:27:41 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 19 Aug 2026 10:27:41 -0400
X-ME-Sender: <xms:Xb2FaqRLQLymeKEeS9B1C8rheCwHXUu1aiQgptdu6Nx7pQtUO_KuBA>
    <xme:Xb2FaqlgFLoKssxtJg5I8dLyTwWESmDLNo-fHCHILQqXeaeHNkf5tV1Ax_P8I0d3w
    oX8AEPSH1M0F0oR8x9vN_BQ9vv1rTupnVChbcOT3-PkLqMsReGxqw>
X-ME-Proxy-Cause: dmFkZTEObOTn4lioDOQKpwlAvb1nU/ped5RnpitX3ia030x7hA6/8N+cz7Y/wMhJH59b1J
    5/EtQkGFO6NU3IOACNgnpYus5YXAYRSBumtE0hxydhH0qrX/+eOgL7Q82uAfkEpy+Sp/Xo
    f73/JNoB4WN5daFgEeluA870XMKosxR46d1Th/JhOq+lianQmh6iP5O0nIO99hIVfBiP6r
    ls1nii09H+fCi1VBNql0JSNxxSohcgkO8R4/30shXucjXwt4B1M1r65Qqo43x2GcBaWd5O
    cIOV8qTolqcc8IYLQwmQO8BK6JzDKzDRTly22lQ3nS/1CwIGuf/HSxjbcjz+t/enwaQ+HO
    c4sWocKSJ9yMcsqAnGAjWvmaWUPG3V7gYgExSKZz2eUi3GgojzEHR0XHCj7MCbkoib8Vmt
    0EdJyp4soDIFIf3C2yarJsc6iVlmVJBiG1Pv4Y+cICP0VZH4xccJYGU7GfzcFsKgHP2qHW
    mPQPPQlqGfOS8JBFKnYY6T6oTWdbZFFAyLjD6Ec+8J8qSOOJ3j4FKn8lgT3htveo7Tz0OV
    yC3olf9ex9JQzXBFu8S+X2WU2EgOaCMsn9jJ6qYtly05sevHgq4UNCh4xhkcIOx1jokGkC
    wsRqmMFLDGEa6IG/3eCiPzczEi7RkXLtL/HrcOCXb2/vXUM/Y235WKNdYgyQ
X-ME-Proxy: <xmx:Xb2FauOxCZLlz3GxNckR1SNLWhzlIJAr_cylyTjw6gIkOnKy2bQMxw>
    <xmx:Xb2FajUuoQ3OJZmFhURwqm1EjQOn0ALtKEsZk2BjI5VmV1cgTGjVfQ>
    <xmx:Xb2Fahhs8KhTbIbRPPXmkoSIV2MmifJL4EBb2ycWazZGK-phkMRtcA>
    <xmx:Xb2Fasg1CcvxWFNbtJVrxDPsJqwwULyrASGZ7rL37UKIg8ekmm-ICQ>
    <xmx:Xb2FavGgh1Y3De_MoEbNj60c65J8gD-CQ3Pqz51vj2jYOzykKO9P9U8o>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 86E3D7811F0; Wed, 19 Aug 2026 10:27:41 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A0_WlIPSeIZw
Date: Wed, 19 Aug 2026 10:27:21 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Christoph Hellwig" <hch@infradead.org>,
 "Ameer Hamza" <ameer.hamza@truenas.com>
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, alexander.motin@truenas.com,
 caleb.stjohn@truenas.com, stable@vger.kernel.org
Message-Id: <40f94c59-32e5-458e-bc48-80585beea7ff@app.fastmail.com>
In-Reply-To: <aoVF8l3E6SjXOVlD@infradead.org>
References: <20260818225715.572140-1-ameer.hamza@truenas.com>
 <20260818225715.572140-2-ameer.hamza@truenas.com>
 <aoVF8l3E6SjXOVlD@infradead.org>
Subject: Re: [PATCH 2/2] NFSD: Update the atime for iterator READs
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Wed, Aug 19, 2026, at 1:58 AM, Christoph Hellwig wrote:
> Code outside of file systems and library code has absolutely no
> business ever calling file_accessed.

Every call site in the kernel is a filesystem, so indeed, NFSD would
have been the first call site outside a filesystem.

I misread the FUSE code: I see now that FUSE does not maintain atime
in the kernel. file_accessed() from NFSD would have stamped a kernel-
side atime on an inode whose atime the user space filesystem manages.

I assumed FamFS would hit this very issue, but maybe it does not.

The TODO in fuse_dax_read_iter() is a bit confusing. Implementing
that should be a one-liner, or it should be replaced with a comment
that explains why that callback is missing an explicit atime update.

So we can drop 2/2. Sorry for the noise.


-- 
Chuck Lever
