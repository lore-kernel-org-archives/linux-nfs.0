Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E934346AA96
	for <linux-nfs@vger.kernel.org>; Tue,  6 Oct 2026 14:00:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791295236; cv=none; b=YVc5vpSVrrJYFMVMorEursyQ11YqYyItbpbk/GV8CE65tBvw0eCWTOcGNnC3lrm4h1lagiLzsI0EUEjcNlwyxsxzjrHZYcA18d0FgFrkeKP7o8c+BNDwXxy5fZ0Zg8T/n93D+PhrSuOMdEPR3CPGcCtXdVg0skoXd7Grc00VrSI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791295236; c=relaxed/simple;
	bh=IvxQxF3UXEvW4AulGQz4dRRqGz31/slpuZJK3rSrPOw=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Enyy6Dx0aqS1ae0yqfS+DdKpvu6tKhxXkiv+o/CUdvJLZTJfl5r4Yx43pVInAOHYtr2UXpH/jEKAJuoihWbSiLPZyii+l2DUG1z0Euwnj3Ux0bfsHHYX4Q9a7/EoGCRFrAEYkwvYymzwkPw2qMEYuYAhAh/AuiBx2IYygqygm3Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jjD7Kzun; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jjD7Kzun"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3352C1F00893;
	Tue,  6 Oct 2026 14:00:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791295234;
	bh=AXezEU08QBeG6wMOvFEJXbVaFlnnw6bnJlBhBZAQsbw=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=jjD7KzunqpKEnta0ZDKOOYBRfKpSXs9xgCQ43x9kD0fLobkRTF5QkDvkEsTHTg0Wj
	 RdB5CgL174waoHsZ3F6hmM/WDKgoK1Zm4loa6iAdOLTZCIqCKrt+lHANrYr6BYhy/9
	 sCeo/AjY23JriAa5g6Pjp3P4X+S+pFMYzvigWgytSvXHoAsviR4vT8Nwnwq6oz49Eg
	 9zjF7DuMbEOsOp6GXI6Vcex3tHBbWw/zxBWsG/eLHxCW08V1g8jb95cjlM06ZNfhmj
	 wS/fbxi9uR4U1k4sPfl+YasgGXiDLcKp4BZe781RwIjQJ0WyzGGTWmdKFQ42x4DORB
	 lvNteIN4cxGEg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 62F09F40066;
	Tue,  6 Oct 2026 10:00:33 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 06 Oct 2026 10:00:33 -0400
X-ME-Sender: <xms:Af_EaoC6_EzFOlJGDmTYUGC9T2KQXfQqyecbBRx07qX5FP5p5C1JjA>
    <xme:Af_EalU8uaB_W_CG0P_9Ey10vMbEEaLsbe6HJRhafB468sha8LVm6sleTlP1-VTkz
    jX5j3wh8EC_hdB-df1qYO8jepIAVdC8maxhtsv82_dIX4iYS5QyZhE>
X-ME-Proxy-Cause: dmFkZTFbe4bmLonpBE+N+mIT1TkF00SkHA/tjY++bZCa3yZi0I08WccuIFyxCY7OTcT2xN
    4rAYsbaJwnCMgDxJYrjW6MFuBBmkjc4ACyy7ZcsnS1K//Vl+uyyFKDw/A2ZWChPECk8N18
    hSgnDT42q80/yA/msTTYf0ZrXMGvynIjwdTpent/xU/WspQqvym1UqYKtcXwAkooFFLg5W
    ZLCqDJBpXQvWEmVq9RIn90mylRb768ARphhXU7aLiU6+3HVoYew280LGC+VOJceOtlZd1+
    gH2e1uTKFAsDv92SgwbXX4vFD5A7gL9zJXYKhRP0OjIHKzEuQhNNBQW4p1wjSQP1dFKPEV
    gfuV16KHGVbb+Rhx77x62q4Y84rVPguaVZs3qgdFenUp1zQnj70e6GztQC+IUPkEmBYZY/
    AUqHKP7AueCaxcUlLyu6UMB1Sar5xSDUN/xdAEiMDP0UJ9HloqNPjMobwHTI3x9TIRyVVa
    2zeZOQmA0E6kKumPkJpgKqYJI+LlcyXTGOctPOmFO3WoFsGUSHIEkRzyd6CTSE1Jh8BJMC
    LFlZ6n3FaGiIp+qMavZrC17EsBN4kGzcuUfZ6xRawGcmBF8NdUSBpVQZ43wY2QGW5ymiZQ
    GNyxwI0gw/uzcY/ub+nqka7ZlWZ8AOFcUrfnEOmhKR5dWDh5TvTvWdgCUBlQ
X-ME-Proxy: <xmx:Af_Eal5aY94F0ymr2vYzp4iavz9Zw39frMWuCwxyuQ7Ma_jLTWPEkA>
    <xmx:Af_EarC_JPHe6lNeHX3ymXM1mGedd6I2E6ecOFtk08FROVoYUFe-3Q>
    <xmx:Af_Ear_LttAFvzPc5gUJah6vniLgdjVRFEY3Ieq4vO5HRGMUIzT8IA>
    <xmx:Af_EauHYYOFZlgHq3QJhiXqGjpWM5zBtrrDNbCcwtfLBjIFmZixDBg>
    <xmx:Af_EalSfcoPqwxSj4p0rUZh9jggfXGtdC6MPF2fsW9MBG42emD8jslYa>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 45380780070; Tue,  6 Oct 2026 10:00:33 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AgBbH0lsTNlc
Date: Tue, 06 Oct 2026 10:00:13 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "J Louis Kaplan" <Louis.Kaplan@arm.com>, dai.ngo@oracle.com,
 jlayton@kernel.org, neil@brown.name, okorniev@redhat.com, tom@talpey.com
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org, anna@kernel.org,
 jgg@ziepe.ca, leon@kernel.org, trondmy@kernel.org
Message-Id: <d189ba0e-6215-433e-b27e-859502db67e5@app.fastmail.com>
In-Reply-To: <20261006090028.3412544-7-Louis.Kaplan@arm.com>
References: <20261006090028.3412544-1-Louis.Kaplan@arm.com>
 <20261006090028.3412544-7-Louis.Kaplan@arm.com>
Subject: Re: [RFC PATCH 6/6] sunrpc: Allocate svc request pages from large folios
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Tue, Oct 6, 2026, at 5:00 AM, J Louis Kaplan wrote:
> Bulk allocation of base pages does not guarantee physical
> contiguity, limiting opportunities to coalesce service buffers.
>
> Allocate large folios opportunistically and populate the service
> page arrays with their constituent pages. Cap folio size at
> 64 KiB and allocation order at PAGE_ALLOC_COSTLY_ORDER, falling
> back through smaller orders to bulk base-page allocation.
>
> Retain one reference per populated page-array slot so existing
> page-based ownership and release paths remain valid.
>
> Signed-off-by: J Louis Kaplan <Louis.Kaplan@arm.com>
> Assisted-by: LLM

Given past experience with contention in the page free path, IMO
this one needs careful macro and micro benchmarking.

I wonder if this change should get merged first instead of last.
It's probably going to have broad impact and high risk, and will
need testing across all hardware platforms and on large- and small-
memory configurations.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
