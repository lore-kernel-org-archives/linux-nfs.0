Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0C3EF11CBA;
	Mon,  3 Aug 2026 18:33:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785782014; cv=none; b=czai9TAt2w4Jy/qSbf5e2d3BpvqJbQcpp6EWOHO/Y3tBaJjFOLovaeL7nZZaejE8Z3J5hhgQPJjrDbPG3yYGGLivcrouP9oEiaRjqW8VRgrJpHYWGZfn2TN/LmCP4+bhRHezJ1zMpdI0QumhVzNBmKtrkbIiwg2LSgHXD/aHwuI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785782014; c=relaxed/simple;
	bh=KbaYKjPQbOZ3r8DYPKOBxpc/BOGdwUTPsHIuekTJQII=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=RJjUkSyQYjXZvy1J37v/b5hNH2IyTSkUcibPPECCopv81tqSp9bciJPH4HZe77qc2QD99boF3FIfATaQBKlBcfyaTSy18pSEvVSgw8pl+ITLRIR4JqTfwcOa/Xbml4TfWlZ1PhEfCTZ4KIn0SO6YhxNptJBva7V7mkkYJkkhjrI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=UIe+WohI; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="UIe+WohI"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 65B641F00A3D;
	Mon,  3 Aug 2026 18:33:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785782012;
	bh=d3H8AeFjY8Fj/K6xTP6kBik4k1lsFrnOIh14q8FYCmA=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=UIe+WohI6JC/AzWFeap8OWqAkCw3on1h6Y8SUlSmCWIJwH6D2kD/TAeWqttwIEuqc
	 GSSdmtDxkBo3OuwyuVu5Hy0hCqlg53UsqXUEHzi/FUiUmXGKIg9fPweJA/Swxbp4OI
	 8QwB1ic0G6IbCxeWwA4dPzJHEd+aa8tzK4qj+1Yw3eIBpYY1H8T5OnZ0CW5OQiLCa0
	 3kACU9GwZ5J+EvXMcoWlEhI34kpI86rgNCYRMe3XUpM8OCeVz1ImoJ17bWF6Yn8t+s
	 bRew7KldsI9nwBaf9A/u7AyzKQoQlIybJpKR8K6uGMy8rFkgPp3IzrAbWhLSq16s5z
	 wxZ9HjtB6XHvg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 63924F40067;
	Mon,  3 Aug 2026 14:33:31 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 03 Aug 2026 14:33:31 -0400
X-ME-Sender: <xms:-95waheL7OB7lVkSGnsp0Jsj6WPKV-lbPmzADHGOV6NEDE8hYCAwtg>
    <xme:-95waqC2cFBzjcnukAol98zbz8_8wfTCxtYz5NOHfnkj6SZip8RDzduUwBCbM2pHW
    lM2qRAYC9qrJJH393gXNgZEZD58aCLn-pvy67phFR5QHUtWVnyJQltV>
X-ME-Proxy-Cause: dmFkZTF5FTUneQDRbQR3tEhnTNN0JLSTrNn2pVmbtnXB3UkJcYWp/woaLefjUbRZQg7LPU
    wjUvTQva3YNiahlBORROC5bTronq35kiEjZOD4MXky15N1PWF/+XkJfq4dCuuvGI3F8tA3
    T6Tx+iXlMI9l4kuQszT1fbeqJ1mp2T3iVcXh2QNxoNRn0+0qHeczVb4DDhwxtxqdAL7G3Z
    eLeCirGnZsBwfhx/d1tX8/xTrcknDD+ahwhjGKyeH9IyCIjHbLIfLd7SFgZk/X8QIiDlZf
    gfHH0fO3v8LdTCHRrd8EFkxI5VNe2PH78SzC4yMHTqDQ3wMNqp5lvlBEe2ItIrk/n8PSfB
    aLUIiQQcj0K3CvXhwnRA22XQ1aN98LQEX9gO6yWZ68wuFzWtl03zV9w+GQvHiB42VNJHDU
    nye5GYdPCN+Hx5dXWIC6XvKaHqh+htNVNVu8ZtNHRUTPHPOppzrs6P06r+v3+78dQ0Wdzn
    e965XO99tdlP0L+wCPD148+wFfYzw0yzpeBWTk89/J9QoDYIWfl0UgvwcFpAQeCNcpD9yD
    hUYYCYNj3tX01cT4TVV1Eoy0z30RAFod7TLCIdufSN6GHAzKRkzBVSuhEAPeo3eLDNL97M
    CN2fdZi0LMSxWV6lPD1yR/Z8NyTyywxRwyaPkht7nB/aWknNTeyhF/jKkOaA
X-ME-Proxy: <xmx:-95wam_LLGUjlacxWJQAMxjLOuLYxSvsvDUuN140GtFJBkRcuLNUjg>
    <xmx:-95waitW5P8IdIPaKRhHg4sM2lF8uYlh7ETjmi5i6lRMdlAOc1Yqzw>
    <xmx:-95wauOiClbu-v92mDsiv1yzRQ_J6JhCza14uj1Cygl36X_eFNt69g>
    <xmx:-95wavgs12aUGINuF5FVHvzd-CWuX8vkb1WTaIi5SoBLL0JLr5ff3Q>
    <xmx:-95wao7Kwidnx8kX1vgKAe7k3oKCFwIOC1lR8uI0hTok2lvwTxHp0MiY>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 42F32780070; Mon,  3 Aug 2026 14:33:31 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A0Y-jwfPBytZ
Date: Mon, 03 Aug 2026 14:33:10 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 "kernel test robot" <lkp@intel.com>
Message-Id: <848f6735-7b63-43d9-aadb-eeb1f0290d57@app.fastmail.com>
In-Reply-To: <43a111b0927e4291eb0dfae08def19be1e32e02d.camel@kernel.org>
References: <20260803-dir-deleg-v1-0-51be76861821@kernel.org>
 <20260803-dir-deleg-v1-1-51be76861821@kernel.org>
 <54f8ab19-fb1b-4cd6-9600-e3d3d6971173@app.fastmail.com>
 <b8a7379cf6e8e73a0e994937a6b738757a8be744.camel@kernel.org>
 <c018418c-4f4e-4984-8312-c082509090cd@app.fastmail.com>
 <43a111b0927e4291eb0dfae08def19be1e32e02d.camel@kernel.org>
Subject: Re: [PATCH 1/2] nfsd: fix type mismatch and explain host-endian xdr buffer
 usage
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Mon, Aug 3, 2026, at 12:23 PM, Jeff Layton wrote:
> On Mon, 2026-08-03 at 12:04 -0400, Chuck Lever wrote:

>> Number 3: Yes, we have a sordid history of grabbing a piece of
>> the xdr_buf's tail iov for temporary storage. That doesn't make
>> it wise to do, and assumes behavior about that buffer that is
>> not guaranteed by sunrpc's API contracts. That makes life hard
>> when future changes need to change that buffer to, say, a page
>> rather than kmalloc'd memory. Or when I want to convert this
>> code to use xdrgen instead of hand-rolled encoding.
>
> I had no idea this practice was suddenly forbidden. That has certainly
> not been communicated to me in any of the previous review rounds over
> the last couple of years.

I've been removing instances of this anti-pattern for some time. I
haven't seen new code (until now) that tries to do this. It simply
hasn't come up recently and I typically don't look closely for it.


>> So what you've done is fine for operational prototype code, but
>> not something we can carry forward as production code. The sparse
>> warning is a canary, it's not the actual structural problem.
>
> Does this mean you intend to drop dir delegation series again?

No. It's deep in nfsd-next now, and this is a long-term issue, not
an immediate on-the-wire behavioral problem or a vulnerability.


-- 
Chuck Lever
