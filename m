Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 10B233DB622
	for <linux-nfs@vger.kernel.org>; Fri, 24 Apr 2026 14:05:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777039526; cv=none; b=SrZfDzehdXEiKnz1++b+sjuyzS/TfCJdyJg8xkXXNjoemt3FmyaGkTXc6zN34MZu4WvmoUWWNLykgvpOQu6cysOCiX0ygMv9wQ0kg9PNZKc2mddJ+EsbfMUhyqJU0TYOPJPE2fC/g+wrDDd5mNcJde8ShwCJt01j8ntfjICoL0Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777039526; c=relaxed/simple;
	bh=tCJb09jONOHI2uZelOMPCrrvwElsKJbWGD7wzHW1Oy0=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=qgU7Sahw+CAlT0npYUSrkuesCY53z+YyY16WabIGEVAHzoZF3d60ZnfhtLnYWiq9xyERu8UJSZMBctGeRLFmrjLB2LuRop15QlWGDxZVcCApOZ35rC7PF0oSNvcGWtJk0t5n8UrhBHIepHTzZzsJRO5mdgLz0ABgqrK9PDk0+n8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ZioLHUzV; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZioLHUzV"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 98AE0C2BCB2;
	Fri, 24 Apr 2026 14:05:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1777039525;
	bh=tCJb09jONOHI2uZelOMPCrrvwElsKJbWGD7wzHW1Oy0=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
	b=ZioLHUzV8BdAvxToF8e1V3BzoR4Bo0pcjTkGn5R/hJTi8C/m7hWFx64nhNBtgcbKg
	 EZ1hevMVoNvc7O3SP/oC1A2AYQLg6HKxWWDuOqZX1QzxdtTrDc4uoh9WYozYmTLy0f
	 kUM3K+9E3slpphb9TFztXvAUGg4tNTWv6K7pPWqS76wE3BfQHynXNxGdODDCFlcD5P
	 03pOM9DjTFJmer2EtKGDc6Z0+WQ6UyROfPOF0gNe8PU/2cbCLM+/8eDMKk3o54b2c1
	 nkQcRcvUkJSyLNRnwMAWGBPnpmHKWCf2pISrGFvDwEMnoulrJrWN4FXKbL8R4kQKcy
	 E4edbQ6M0N4Nw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 9FAE0F4006C;
	Fri, 24 Apr 2026 10:05:24 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 24 Apr 2026 10:05:24 -0400
X-ME-Sender: <xms:pHjraW7te7HZBRFlA-OvOso-h_aeX-W2QKjy0dzW24sypARqtQjOhw>
    <xme:pHjraau_CwrXL0HwDhWWR774Xd2bAY2MfNJdj4xUvnVnUcBU5tX4caFzOIx6HFrYT
    AZLaOOD9w9d0uQgRxSIOgLGuS-f00i0iaiDOC5aKXTEJ90mIhw70KIX>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefhedrtddtgdejtddvvdcutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpuffrtefokffrpgfnqfghnecuuegr
    ihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenucfjug
    hrpefoggffhffvvefkjghfufgtgfesthejredtredttdenucfhrhhomhepfdevhhhutghk
    ucfnvghvvghrfdcuoegtvghlsehkvghrnhgvlhdrohhrgheqnecuggftrfgrthhtvghrnh
    ephfffkefffedtgfehieevkeduuefhvdejvdefvdeuuddvgeelkeegtefgudfhfeelnecu
    vehluhhsthgvrhfuihiivgepudenucfrrghrrghmpehmrghilhhfrhhomheptghhuhgtkh
    hlvghvvghrodhmvghsmhhtphgruhhthhhpvghrshhonhgrlhhithihqdduieefgeelleel
    heelqdefvdelkeeggedvfedqtggvlheppehkvghrnhgvlhdrohhrghesfhgrshhtmhgrih
    hlrdgtohhmpdhnsggprhgtphhtthhopeekpdhmohguvgepshhmthhpohhuthdprhgtphht
    thhopegsrhgruhhnvghrsehkvghrnhgvlhdrohhrghdprhgtphhtthhopehjlhgrhihtoh
    hnsehkvghrnhgvlhdrohhrghdprhgtphhtthhopehhtghhsehlshhtrdguvgdprhgtphht
    thhopegurghirdhnghhosehorhgrtghlvgdrtghomhdprhgtphhtthhopehnvghilhgsse
    hofihnmhgrihhlrdhnvghtpdhrtghpthhtohepohhkohhrnhhivghvsehrvgguhhgrthdr
    tghomhdprhgtphhtthhopehtohhmsehtrghlphgvhidrtghomhdprhgtphhtthhopehlih
    hnuhigqdhnfhhssehvghgvrhdrkhgvrhhnvghlrdhorhhg
X-ME-Proxy: <xmx:pHjraT9VnhArOHktTSQCfl2pJ3FW0vtC6mq9BTsO82M3IUZQiNZrYA>
    <xmx:pHjraU50U7S-beU7iw6qer6ddtBFACBc8j4UOrHITlSqhHDdfPJm0w>
    <xmx:pHjraR6Xpn7u22X-duy8r_mM6qiKxuhedWJsjWpyywoGOrDWofBTqg>
    <xmx:pHjraVqcHm_eB-UZQGQk20Z_4n9VXszLUbS4ciNDRmtcIVitptGM7A>
    <xmx:pHjraaNOLTINaJ_QJll5tcmFVTKjOLIcSNYiIIvYgSuW7dikErcXeQiE>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 7C9A3780070; Fri, 24 Apr 2026 10:05:24 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AWqGfwV8spk3
Date: Fri, 24 Apr 2026 10:05:04 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Christoph Hellwig" <hch@lst.de>
Cc: "Christian Brauner" <brauner@kernel.org>, NeilBrown <neilb@ownmail.net>,
 "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org
Message-Id: <447b45ba-8b07-451e-8a26-54834ca370ab@app.fastmail.com>
In-Reply-To: <20260424132203.GA15687@lst.de>
References: <20260423181854.743150-1-cel@kernel.org>
 <20260423181854.743150-2-cel@kernel.org> <20260424132203.GA15687@lst.de>
Subject: Re: [PATCH v3 1/4] nfsd/blocklayout: always ignore loca_time_modify
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Apr 24, 2026, at 9:22 AM, Christoph Hellwig wrote:
> I got two resends of my series without cover letters in my inbox.
> Was this just an accident in sending out some internal tree?

The first resend picked up the wrong patch set, and was a mistake.

The purpose of the second resend was to transfer ownership of this
series to Christian, including fixes and forward porting changes.
The cover letter was not included in the repost because it is not
committed to the new branch.


-- 
Chuck Lever
