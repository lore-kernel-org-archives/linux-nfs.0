Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 18A711ACEDF
	for <linux-nfs@vger.kernel.org>; Thu, 29 Jan 2026 14:37:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769697457; cv=none; b=gvtwmLBoJMJHJs+YpbJdwGHYSqGPBpuL5m9B+TNESM4KwnDkjZ/ny7+5c0QVRlsbDRCtR6Lo6u+sXq1PXqxo89nJwiVD7gx9rjzhIuI44om197M4wRYHZJoCXivcW3p9MBaPiDD+erDMGYnhAwv/7/XdBe3fw8/npz2AxTi/fCw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769697457; c=relaxed/simple;
	bh=nExTCtMTnOdr4zb6798lNV6B5e2L/IdbKUstHP9wS54=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Cq1tTvOaF3MXu4NnVUSNIDowZsa6q7CJ3bJb9H1fGQAbAAxn9fwZfFSMG8rVyhf1ECRglkDDtj6PZD6R3lQjdZitApLMu3w93DOjaLwhD6CA+kMLqWvsSeIM8eWInUvJarLJeCfnZA4Fy3nbKAm1v5A4IIiSQ0RUe7eSqJiePTw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Ttma05z8; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Ttma05z8"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8C908C4AF0B;
	Thu, 29 Jan 2026 14:37:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1769697456;
	bh=nExTCtMTnOdr4zb6798lNV6B5e2L/IdbKUstHP9wS54=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
	b=Ttma05z8sT78/VSnueGFpHcrN+W5CVolqrr9/DvsUf6vS3D4wzXuuBDs8TsqCHlUR
	 Bg7sT+hgiCn0tDJ2aaVm3sJq4L/kgJ6MFXeDIXHR9MmfuE756TLxkE77S1bnKFNRQI
	 XVsJZqHonC6bBl5QQp7UGO5G89OtGRzxHOrsPcwkBYN/l7oiqN0ckGDJnB8Olw70t2
	 2LHaUvVZuxF6AZjELml5Icb+wzhcv29PTh/G871hhRPwMsqWVZyRFSP3Q+1sEtkj9D
	 NKguqQSsBI8TTZOjnD+1SZ0frxmJUV9IDuhSV7zoj69erm79tP/wguQ11IO0/zPann
	 bspNQptdSteHQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 65EB0F4006A;
	Thu, 29 Jan 2026 09:37:35 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 29 Jan 2026 09:37:35 -0500
X-ME-Sender: <xms:r3B7aS2e0_n6zDJ7WHD_Bvw3uxkDMbrsDQ1ECeC77jiRQot-Qg2UPw>
    <xme:r3B7af6aQTL2Fb6en-DmLaBW52_4papEscrptbWTBvJei7HIy6ypE8lUMeH2HwTTq
    YhxivN9P1Igf8aN0jViMLwre3wQzoxVSp6XaEbD32-Uq6twmpNJfiMk>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgdduieeigeeiucetufdoteggodetrf
    dotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfurfetoffkrfgpnffqhgenuceu
    rghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujf
    gurhepofggfffhvfevkfgjfhfutgfgsehtjeertdertddtnecuhfhrohhmpedfvehhuhgt
    khcunfgvvhgvrhdfuceotggvlheskhgvrhhnvghlrdhorhhgqeenucggtffrrghtthgvrh
    hnpefhffekffeftdfgheeiveekudeuhfdvjedvfedvueduvdegleekgeetgfduhfefleen
    ucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepmhgrihhlfhhrohhmpegthhhutg
    hklhgvvhgvrhdomhgvshhmthhprghuthhhphgvrhhsohhnrghlihhthidqudeifeegleel
    leehledqfedvleekgeegvdefqdgtvghlpeepkhgvrhhnvghlrdhorhhgsehfrghsthhmrg
    hilhdrtghomhdpnhgspghrtghpthhtohepuddupdhmohguvgepshhmthhpohhuthdprhgt
    phhtthhopehnvghilhessghrohifnhdrnhgrmhgvpdhrtghpthhtoheprhhitghkrdhmrg
    gtkhhlvghmsehgmhgrihhlrdgtohhmpdhrtghpthhtohepsggtohguughinhhgsehhrghm
    mhgvrhhsphgrtggvrdgtohhmpdhrtghpthhtoheprghnnhgrsehkvghrnhgvlhdrohhrgh
    dprhgtphhtthhopegvsghighhgvghrsheskhgvrhhnvghlrdhorhhgpdhrtghpthhtohep
    jhhlrgihthhonheskhgvrhhnvghlrdhorhhgpdhrtghpthhtohepthhrohhnughmhieskh
    gvrhhnvghlrdhorhhgpdhrtghpthhtoheptghhuhgtkhdrlhgvvhgvrhesohhrrggtlhgv
    rdgtohhmpdhrtghpthhtoheplhhinhhugidqtghrhihpthhosehvghgvrhdrkhgvrhhnvg
    hlrdhorhhg
X-ME-Proxy: <xmx:r3B7aR-zngJSE3DlOE38w2tS8MjqSKimvDhWep0Tmrvs29rSpVLxgQ>
    <xmx:r3B7aRiJRXIE5Y5f74DXxsxDz5Ux0vBwIMFUabV6yNHPX6Mt-0N8Ew>
    <xmx:r3B7aaYoOBvwOp_0SoXkdy58J8iMaj4c57TH5LzjyWn0KpShs_De2Q>
    <xmx:r3B7ae-vJKuDq1ZjNDzB97_BCD6uiigKW-wk80uTmWJeU7djEABGsA>
    <xmx:r3B7aUM5jo1314PVxUuPy1sZ5SsyJdpSxp291TX5S37R1GEyF50k3BEJ>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 449F4780076; Thu, 29 Jan 2026 09:37:35 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AvBI4pOdhfek
Date: Thu, 29 Jan 2026 09:36:41 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Benjamin Coddington" <bcodding@hammerspace.com>
Cc: "Trond Myklebust" <trondmy@kernel.org>, NeilBrown <neil@brown.name>,
 "Chuck Lever" <chuck.lever@oracle.com>, "Jeff Layton" <jlayton@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Eric Biggers" <ebiggers@kernel.org>,
 "Rick Macklem" <rick.macklem@gmail.com>, linux-nfs@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org
Message-Id: <6ff7cb5b-5914-447e-88a3-9da908eaec3c@app.fastmail.com>
In-Reply-To: <5C6C8838-9244-476A-87CF-123F4822F459@hammerspace.com>
References: <e545c35e-31fc-4069-8d83-1f9585e82532@app.fastmail.com>
 <176921979948.16766.5458950508894093690@noble.neil.brown.name>
 <686CBEE5-D524-409D-8508-D3D48706CC02@hammerspace.com>
 <77e7a645-66bd-4ce2-b963-2a2488595b00@kernel.org>
 <8be0a065a84bed02735141b4333e9c49a2ab0c90.camel@kernel.org>
 <33c02e5a-03e7-42ef-8ccd-790a9b29a763@kernel.org>
 <D3263C1D-A15E-48EC-B05A-8DC6A0C2B37A@hammerspace.com>
 <041a37d8-c114-4ac0-875d-022e9d07aac8@kernel.org>
 <5C6C8838-9244-476A-87CF-123F4822F459@hammerspace.com>
Subject: Re: [PATCH v2 3/3] NFSD: Sign filehandles
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Wed, Jan 28, 2026, at 4:24 PM, Benjamin Coddington wrote:
> The other thing about those pynfs tests is that they get awfully linux
> specific - requiring new tooling to setup and change the export option.

pynfs is for unit testing protocol compliance. Since signed file
handles are a feature of the Linux implementation and not part of
the NFS protocol standard, pynfs won't be an appropriate home for
unit testing the signed FH framework in Linux. Sigh. We'll have to
look for another framework that can host such testing.


-- 
Chuck Lever
