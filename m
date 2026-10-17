Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BACA83D47BD
	for <linux-nfs@vger.kernel.org>; Sat, 17 Oct 2026 20:22:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792268525; cv=none; b=Nd30yyzKN9GGPl+JkLhbvbZFipusREW0mJf5Jr9eh9d2FgcSb96CEaj+NcBdfBb+gUtmlazfUWfWewVJHGimC3Mf88XHIIkV/LP4LcURFPy6o5JYi+PLjkcm5fwMbHBC6P8uFPIgmHOjEJ1czSzBWftJCwgNtXx3939x1n4jqDE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792268525; c=relaxed/simple;
	bh=XLGlIYFlGUxz3XrLrgAxJQXNQiojMpSp72KqivlN+NA=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=rQhr3XO+16+h2+rb0jQZsHxCEBhptlSrc7Y+l0tWeaXaesqcSFNByvrwCDQ5DxvH9KG14uxSVZK4P9J00MEq5HAtY4bASWrycHHTjFxHPkk04zfH0VsUIrMJDnp4qlfPyOuDlIG86LYCZNxX2sE7C80pDvviP8VYsHCQW8sIy7k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=QhAiiwMQ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="QhAiiwMQ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 010D91F000C6;
	Sat, 17 Oct 2026 20:22:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792268524;
	bh=aaLn70CeP3Q8y8xmpykRafKibJMZVBLTb1hqu180a7g=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=QhAiiwMQry3GdYWalA+rKsEunsWgZJdUVxCYFZZsTVYcswUbBHVAG76kzdgm9+TSO
	 grTyKCbJDePXsN2guS9DxJsn2deiAgLfCumQgAOGJrgK8262863I23R/SXorAv3jAm
	 x0SRkh8N+gw5iruMENdGH7Fa7EBJC8w3Fab+LI9TuQoaLyczlwfu49apXxgH/A0wqX
	 LY3Tui+RgIw5dS/zjlBNRFfVtTyp8wUnJE/UIuvHYcGpdRh8QAfZ6cso+N+utjk8qJ
	 0qveJbsodhThFNU3sgR6wgUQafoX+bmRrqTquwG72huhTtAKoMH2/vxPenJojfZsjJ
	 Yt0vHhBslyrmA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 2E157F40069;
	Sat, 17 Oct 2026 16:22:03 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sat, 17 Oct 2026 16:22:03 -0400
X-ME-Sender: <xms:69jTauaOcwjzmflMV8xyiQGt2-s0OIzXe4kIURxL54BtR5L5hNYY8g>
    <xme:69jTasNPLXfhDilTYXUyaqHJDlu6tC8GBjkcL-0a9dsmbuliCsRBn8_hdJmODj1XG
    kJNANdQIgV89c58raDEmwOn9OtXXrxkDFfI-W4vTJUBDC-gdkKJGHXL>
X-ME-Proxy-Cause: dmFkZTENtYKl6YTXhI+B9FpVMnYirjkR2wHpBXjuhrZFg2ou3rIWwL1icfaBcFo/77we51
    OgnP88rf978IuAkvYeRg5zv5ZMUz5afMKOoibXogSiQBitEpEGee5n9sXD+xCzBMyivyU2
    1BkZdDyxTsTvsaGobnbgoe0xj2eNXE0yoneVIxl0LHSgPRFKHv22whIwROW/4o85UnIe8g
    zJBrAMtaR8NpSgJyrQIeQWoWxTaiao1/FqYWhufDmzggyS9D70zj5DRo4rH7znyqS4ZpXE
    lCvQey4HrU7nBZDoUM/1pOC4yTDUr/qzjfxtDXXA7P61katAKdZsAeVPn0esmuiVc9oJeY
    EUhr8IZbwNWbV2AYWIT73HN6Fq2/8++OeDFiNhY6ZJtVQuItT2CfDjoVxPnTCy3Pv/Rjlo
    mBXvHaljN6YNw74aTdQLuJ5oZmmIhG26kaKlP4Bcd+lzhqA4lPSY3ZzYMr7A9/pAphQv/q
    kE+GvZkh8j/AWeL1VEFkRK33WXykTvDysKSi2FoHQCybMnGUFLUOmwcQzbmsvJCXP9/Ie6
    qIwzzVWKTstQMztCAqqfQazRkzpkPcx1XGN/LJRRzuT9hx7do2ccdGaRh3hmOEil0V3J7+
    tddBGmBNaRAaPEXaz5SMSU58/g6mG9p6Ph8H13Vsd6VoM2Itx53dw3ZIEjbw
X-ME-Proxy: <xmx:69jTagk80LQIEHcwRtXfXru9aWl2aidU7P_PUmEGl_qgWdsoVvQoeA>
    <xmx:69jTauErXpv-bC-2-Yh2UBDTbLvoNDR0ktyy-rGEqZXnfzT9sf6b0g>
    <xmx:69jTan8YP0stvtxqDudFm_oai-ff6z9la8TSSTFq3uLwfyQIYmhpgQ>
    <xmx:69jTavla2GdgLyDJyZW7sIqOXu4UeNMkSIKAzLYGHx4o8rc3U-V3Fg>
    <xmx:69jTaiCNMTTcDig3JXhwb-TXbBePX7RRXwy_lJEDK2eMN6aKy_YVbtxl>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 0BE3578273B; Sat, 17 Oct 2026 16:22:03 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AfI0eCoY7JIB
Date: Sat, 17 Oct 2026 16:21:42 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Mike Snitzer" <snitzer@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 "Christoph Hellwig" <hch@lst.de>, "Jens Axboe" <axboe@kernel.dk>,
 "Matthew Wilcox (Oracle)" <willy@infradead.org>, linux-mm@kvack.org
Message-Id: <74c5b238-25f3-4349-a99c-4806fa644022@app.fastmail.com>
In-Reply-To: <atPDhmfdneS-d5qM@kernel.org>
References: <20261015233309.42999-1-snitzer@kernel.org>
 <f60b0363-c4d5-4539-990c-1c6c7967f8f0@slotpi15m67>
 <atPDhmfdneS-d5qM@kernel.org>
Subject: Re: [PATCH v4 0/10] NFSD: keep direct-mode I/O out of the page cache
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Sat, Oct 17, 2026, at 2:50 PM, Mike Snitzer wrote:
> On Fri, Oct 16, 2026 at 03:23:27PM -0400, Chuck Lever wrote:
>> Consider splitting this into two series (which I already proposed
>> for merge process-related reasons). 1-6 need careful scrutiny to
>> understand the trade-offs between scalability gains and
>> predictability. 7-9 need to be explored as an issue with DONTCACHE
>> that should be resolved below NFSD, not within it.
>> 
>> I'll study 1-6 more.
>
> Patch 10 too please, it improves tracing so we know precisely how each
> segment is issued.

Agreed, observability is high-value. We need to assess whether these
should be counters/metrics (ie, always on) or trace points, so I'll
have that in mind when I look at it.

But the high-order bit here is whether the changes in 7-9 belong in
NFSD or in MM. Seems like you've identified an issue with DONTCACHE
itself that shouldn't be limited to an NFSD-only fix. As always, let
me know if I've misunderstood something.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
