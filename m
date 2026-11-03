Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793711691;
	b=Htngj8Dtib3uxUs2J/ux+QTvL8yI28v56goCbH/x3zpEL+hpyX1hkuTU3VddS42bjfuT
	 mWHcd7eHhH6PXgn1jOAsUPMssc+7gCWwrleroVn5MtblU5l10ae5uO3aN+b3U0JH+WMEh
	 0ucoW5/oNWmB2K5r6IX4TZ7RsYg8WyIvf1SBLptO20iVI0m4NYKlZmSGUELu8HL4d56un
	 /3+1LokRiqsc/nfxx+VfaQ5rXelcHtufhMcbmQ/0/dHmSfRHBoba8CLOqCIv+u9EkgZUQ
	 6mLJ0PCATCqH3tisbqXCQ6Ae9gXo2uriWdPurlFnkZxn48RGOqYqh/K17+QURyYCmdQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793711691;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=LR3hXNWZP5n+r23QSkhauKB+Aw0Nt+vGD0FpyMnIGXA=;
	b=ar9NesK8UwUhnPydiKx52NEFiEFLxK6BmiKaSNc5Z+FkuskisdHSoXLGj4+EOKUnLROy
	 KysR6cI2JLv7BuFfn3Jj+n7DCXtAPkDdWWkjzZ0OOCN9Z1gdFIbMt5LQVHsIT8Kflhcpr
	 AScNF9l0S0+vTc5kakyaG+oV1IW9J/ArVFjWhR1gCIMumvS4WyyR4NVY3p4nwqTAK1C++
	 l1QX/Rny5gFS0S714tgHOYIb/p1Lmf2dhX0MaP87y7/4wTxolTJvGg7oNXU1mBTevDrm1
	 GhfsMp03ooGD8+9OLA0/r5rAjaQOa3vJFKNOAPE1RzyTWVHulYHh1iwikdQ1wfy5myw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CjtXdWfx;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DE9B3606A32F
	for <linux-nfs@vger.kernel.org>; Tue,  3 Nov 2026 13:14:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CjtXdWfx
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 275E21F000C1;
	Tue,  3 Nov 2026 13:14:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793711690;
	bh=LR3hXNWZP5n+r23QSkhauKB+Aw0Nt+vGD0FpyMnIGXA=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=CjtXdWfxf+eeX+DoPHnRH6EmmQ/eIWxpf8pPoD6tY+YnNfrCDP1EgwsG7Z3ubtlgd
	 +U/HzHa5PgzVnQpHnS2ILsxM/iAfNxJ6DYjHpCANi74ni1yigwbBYkeywC8Yo5M6S/
	 fGelvUfY54/kcu8LeBkc7yumH5LyQwiDk3j0+xXkG23kBZHP4cQsYUAPQXUSg7TMYX
	 iwPSmcCdN+ND1iD4DkltUC5ZHOf9fvp/UDuIOnEdWSomiPky542oGOzjyZUss3QCRq
	 6LPLZI11v7Whlvj6yO2lsAil/e+QLaw//1hFLDSq+akRbBEGXFXpRl7IZ/r67i7yy1
	 H666tfSI7+PXw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 5E9CBF40066;
	Tue,  3 Nov 2026 08:14:49 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 03 Nov 2026 08:14:49 -0500
X-ME-Sender: <xms:Sd7panxn7PzCDjXRRWttXjZQRsK6AFlyha3FnAPAv2zRsDcON7Q5fA>
    <xme:Sd7paqFLgN-WtK_-TenZy2QQc7Z6k62n-mGG92Ncp66WLpql97MN_sWfbfD-UMUqy
    2hMfKb6HprLsfD4kWzf6MMqcbCX86VaOYrlnmflrG_i1taxcl4UOQAm>
X-ME-Proxy-Cause: dmFkZTGzHFriaP+8D3U4/9vZVzxsSxGVE7kIPQNzgQ2LczIgnJ7yUBMq9hcfRWrbOesmuY
    jzIHjED4dyQvDQPOrgteKHNH4nGc0A+qnz5z6mtPxCyfkRvLQkvrCMoJw5I6mYvaDgPXj2
    WrzHblmecxXWcB6FyRinrVvJ3zhw+6XqnHHHsjTex4YCpOEAGvIU1a1KgTaQ/xXgjwUeFY
    xwWltWWhlp7/ys1XBgzsxElKZao+2XMPNUgPMfFNUqdBjR5zey7b1Bxh81scH05lvIDU1g
    x1Zh5ZtxssMErNhSyFsaKhrti6sR6spBQCZMTC11pYdV22Sdbo6YLgFgj8eHrPifu7liiW
    bpa/75CsW0ZfQv5v05eVCbeyUhXpSbO4iFdTMe16iBKVJH830uRhQAM7oNb9SOW2NDCUZp
    4AsnU5JJSdExvtYYDnsrZfXEOJ7QptRMz2DqPWLokoKg3HVV/pleWpyhRfzkYzspdwhdwt
    j9ZOaY1cDPdonhzCJ3QAPLnCdBSGJzBN6T/GJunCJxvZTFf31ps9un/tHd5evi4ZareNgI
    JYvZGWLq4PCb0g3HBXohTOG6sX8fq1sApE7MDjLgh7FZuTuaTri2nK1TBuxa3q6zFVdS9x
    GGIg5P1b9F2fnNB8wV24hXHHRWZDH9IpueCMXbj3s8WqqlzrTUWZDPaTgjhQ
X-ME-Proxy: <xmx:Sd7pamaL6Wh3Lk8UFSigkO-vYnAmEEQVqVW6wiMoH2-UlUw-Ap63Yg>
    <xmx:Sd7panMM1k2CNcHI3imHK1D2HpmV8NwUV0ESa1R3N-FxnXePd91VXg>
    <xmx:Sd7parbUl1RfFfT-jSlScpzVP8PyVjiiXHozkaimtlxVSJ0YYgJhEQ>
    <xmx:Sd7pal1jH6jXeivYhArqUCPRwP--_a56vH_gRTYG69EBJde_N69tGw>
    <xmx:Sd7pahfwSZDAzpTljI84rhHP3Ezcp9YY_h2WYDk_AbJD3LeN8nNCNmiw>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 375DF78273C; Tue,  3 Nov 2026 08:14:49 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: Amp6-xB30PNR
Date: Tue, 03 Nov 2026 08:14:29 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Frank Filz" <ffilzlnx@mindspring.com>,
 "Calum Mackay" <calum.mackay@cdmnet.org>, "Jeff Layton" <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Message-Id: <ffc3a48a-a499-45e9-a3f8-6cedfd2d15c4@app.fastmail.com>
In-Reply-To: <018501dd6b59$a92af8d0$fb80ea70$@mindspring.com>
References: <20261102214351.602543-1-cel@kernel.org>
 <018501dd6b59$a92af8d0$fb80ea70$@mindspring.com>
Subject: Re: [PATCH pynfs v1] 4.0 server tests: remove RPLY14
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Tue, Nov 3, 2026, at 1:07 AM, Frank Filz wrote:
> Could we keep this test case but change the flags from "replay all" to
> "ganesha"?
>
> NFS-Ganesha still passes this test case.

The reason we're not keeping this test is that pynfs is a spec conformance
test suite (at least we're trying to keep it that way). The duplicate
reply cache is not covered by any of the NFS RFCs, so RPLY14 does not
belong in pynfs as written.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
