Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DD69834F263
	for <linux-nfs@vger.kernel.org>; Sun, 22 Feb 2026 15:41:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771774916; cv=none; b=MGc72fmG7RPgH0snRxq+w9mrO97Fve3v7NQbS8MpB8ml1wV2W2AEVyw/1mudC0ALOo68E56Wnt2Ty6w1CwRB5wOFHjXLBjvSd2Y2WvhuX+GJ09gJNsTyTwtQcP+TE1cQ0JhWPxEevpxeGQfVaet+MFkI73iP2G91LQpHK1IDRW4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771774916; c=relaxed/simple;
	bh=izZuT6jyEr5LF4TelrPdbOh9riI0WBoKyiiJwoJWLAk=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=WOeIMDWv07aqOvx2woNWwRm1nG90DKoAQicnXYyYbduDCP+533vtMIckQ7wbd1JRogJLvhVMAotY07MzCEwMgK/TIf7sOT42phsh/x/zGB6DGpBKI0lHoegUSq2exgLNfv7FftgC204PgA7IwZRchIETVmUCxomdStGqHgFiLvA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=tLdCbbfu; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="tLdCbbfu"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 33E9EC19424;
	Sun, 22 Feb 2026 15:41:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1771774916;
	bh=izZuT6jyEr5LF4TelrPdbOh9riI0WBoKyiiJwoJWLAk=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
	b=tLdCbbfumy6WVtyg8E5HW5jOhpLcK7y28AKHgnNiCVBTH9E/igUxDoJmnInbwP1Lq
	 8fdeB9wW7oJfGGyLJ2yDaRCr/Pv/NTlt3L+a36PV3A2X6Hze/2Pr8+kVyJV/BGjoIf
	 5vTPg7VJb0ZRogSDL3EjkZlqT6mmEKPDMq/vfg0eR8wT7zP3l5E90n+GfUtfFC+Jrc
	 x/2uEoU/ev9mB2J+p5BBs998aqr4z6GiRXBN1UXQsaS7PVdyRpk2Y/rakO+kroKyAg
	 Rb8XbSra/P0bkW/sm3P9vLipIlTk8YIK98enyJk6eJZ6tz1OOZtnESgnwsL0z0orXo
	 sLdSIQ04dxmAQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 1AED9F4006A;
	Sun, 22 Feb 2026 10:41:55 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sun, 22 Feb 2026 10:41:55 -0500
X-ME-Sender: <xms:wyObaWaMULumWMI6PeT4-HGk1UOPAvACa6Iwody76OaclkvzvYUMsw>
    <xme:wyObaUM_Bt0truEbnPzbwBvYOh6wT-F1kWdu9e6sSgwbVwkJU08hBW11bzPT3J7HX
    dAuQodyujwoA2jdBFGlwZK_gr6D3nJd8exNbOs3IPYPS9BCH956-es>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgddvfeegjedtucetufdoteggodetrf
    dotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfurfetoffkrfgpnffqhgenuceu
    rghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujf
    gurhepofggfffhvfevkfgjfhfutgfgsehtjeertdertddtnecuhfhrohhmpedfvehhuhgt
    khcunfgvvhgvrhdfuceotggvlheskhgvrhhnvghlrdhorhhgqeenucggtffrrghtthgvrh
    hnpeejvefhudehleetvdejhfejvefghfelgeejvedvgfduuefffeegtdejuefhiedukeen
    ucffohhmrghinhepkhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgeptdenuc
    frrghrrghmpehmrghilhhfrhhomheptghhuhgtkhhlvghvvghrodhmvghsmhhtphgruhht
    hhhpvghrshhonhgrlhhithihqdduieefgeelleelheelqdefvdelkeeggedvfedqtggvlh
    eppehkvghrnhgvlhdrohhrghesfhgrshhtmhgrihhlrdgtohhmpdhnsggprhgtphhtthho
    peekpdhmohguvgepshhmthhpohhuthdprhgtphhtthhopehnvghilhessghrohifnhdrnh
    grmhgvpdhrtghpthhtohepjhhlrgihthhonheskhgvrhhnvghlrdhorhhgpdhrtghpthht
    ohepmhhishgrnhhjuhhmsehlihhnuhigrdhisghmrdgtohhmpdhrtghpthhtoheptghhuh
    gtkhdrlhgvvhgvrhesohhrrggtlhgvrdgtohhmpdhrtghpthhtohepuggrihdrnhhgohes
    ohhrrggtlhgvrdgtohhmpdhrtghpthhtohepohhkohhrnhhivghvsehrvgguhhgrthdrtg
    homhdprhgtphhtthhopehtohhmsehtrghlphgvhidrtghomhdprhgtphhtthhopehlihhn
    uhigqdhnfhhssehvghgvrhdrkhgvrhhnvghlrdhorhhg
X-ME-Proxy: <xmx:wyObaYYVabiONopIxjWibfeLZ3goUecvYvyAVrAVC2Jw488FryxDkQ>
    <xmx:wyObafaLVNpgQ75d6wcH26pj4R-E-uZLb9dtb8h--c-vjyvcWRHbBQ>
    <xmx:wyObaVLsSck6q9MhnaRofpwg_Le0nZTP47u_4NYk3s01dC2WCTS_Ew>
    <xmx:wyObaTsrF0mgHNqo4-1FB0cYhZIO0coiDl52ISEGeIraWk0SvkcfNw>
    <xmx:wyObaRU_Nns-fXyNxXlEHMOqrm03RFVnma4rhumqyKFE593eDFd-WMOV>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id E33CF780082; Sun, 22 Feb 2026 10:41:54 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: ADX66Kwc3vDJ
Date: Sun, 22 Feb 2026 10:41:34 -0500
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: misanjum@linux.ibm.com, "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org,
 "Chuck Lever" <chuck.lever@oracle.com>
Message-Id: <7ae720fc-b121-4d32-9a02-255911c694ca@app.fastmail.com>
In-Reply-To: <177171464397.8396.10030110076107851635@noble.neil.brown.name>
References: <20260219215017.1769-1-cel@kernel.org>
 <177171464397.8396.10030110076107851635@noble.neil.brown.name>
Subject: Re: [PATCH v1 0/2] Address UAF in sunrpc cache show callbacks
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Sat, Feb 21, 2026, at 5:57 PM, NeilBrown wrote:
> On Fri, 20 Feb 2026, Chuck Lever wrote:
>> From: Chuck Lever <chuck.lever@oracle.com>
>> 
>> Attempt to address three crashes reported here:
>> 
>> https://lore.kernel.org/linux-nfs/dcd371d3a95815a84ba7de52cef447b8@linux.ibm.com/
>> 
>> These are compile-tested and regression-tested, but as I do not have
>> a PowerPC system handy, I will need someone who has one to test
>> whether they actually address the crashes.
>> 
>> Chuck Lever (2):
>>   NFSD: Defer sub-object cleanup in export put callbacks
>>   NFSD: Hold net reference for the lifetime of /proc/fs/nfs/exports fd
>
> Nice.  I particularly liked the thorough commit descriptions!
>
> Reviewed-by: NeilBrown <neil@brown.name>

Thanks Neil!

-- 
Chuck Lever
