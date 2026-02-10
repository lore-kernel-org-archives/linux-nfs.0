Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 822CC32E6A2
	for <linux-nfs@vger.kernel.org>; Tue, 10 Feb 2026 21:21:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770758477; cv=none; b=JyJO8XRdIllZQs/LZ7+pOeX8eN5vG/lUkqcRgRXIPzKoxkUJdR3mFQusVc9cdjWpaQNfL6DIvKR2BKATGmM7YQVhx8McfgTI8n93bPuif3g2QaQnNZnhzpiX3vj++ek4eCS7IuNFb7/BHiGIwAJUFL7zk6h5N3/7VLkv9DemqaM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770758477; c=relaxed/simple;
	bh=vKwKEZ/Yx9yKpC3Mn/LhUmzzN5uuFwsQplm3daDRMZI=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=W7JpdVqBhKS0MEwXqCcUfaDSiL3tJHAFgG2gBop8AbgRNwGunJn8X0jDApABHJpe5f1x3fqYV++AJ5ww/bLsfV4K9Sc1q5mislC+h+UwHpRi0WmNyT0L7LNyenyB1azHQl1qThhA5E5+udOba2PcnBjlInF+J9p23wPLnsJzbvg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=UMYK9m3X; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="UMYK9m3X"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E92C9C116C6;
	Tue, 10 Feb 2026 21:21:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1770758477;
	bh=vKwKEZ/Yx9yKpC3Mn/LhUmzzN5uuFwsQplm3daDRMZI=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
	b=UMYK9m3X7v31QKt4QYQIA6q8Y7PLUlSaewGWtd0QTTYIgQS/kfApiWiQl0RlyDCF9
	 3SIIbSumLsaMmugbZUELzkFpWo/LQ+Z7Slb/LgbO7hTqcr8z3iaAcJ3c1WD5H1aVry
	 /H00JwcwOz89KXsE8ueM2Svg36uW94uCb7L8ZhXzCorckjV/xO8E5D7jNz8c3R5idA
	 93lCA4iGKxU8QTszXEg1IStSUSclmSD0rmF+Ysd+UNRIGSioZ2kEVWdTLwBh3IeLUK
	 3oxx0QkIIb3eb1qlE736k45CFtWuzlZHZaOqR760tGZyhgDcANRI8BB0WsyUTEA+Ww
	 r5oD4h4RKJTTA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id B7D01F40068;
	Tue, 10 Feb 2026 16:21:15 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 10 Feb 2026 16:21:15 -0500
X-ME-Sender: <xms:S6GLaZhVTK4bdD_IiGvGvNnyDPj3ysMQYv2nSZx4t3urJL3fOOrpkA>
    <xme:S6GLaY3VFV82hYLQuMQIbhpHKTXQivSnF5wsekfb1Fu8poLFcpm5YOALjypmmEl-h
    isn3Rxu02pAym98PVwSdvcIwofT2aoD5AVHcJphosLXqHhfjM2XOLg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgddvtddtjeehucetufdoteggodetrf
    dotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfurfetoffkrfgpnffqhgenuceu
    rghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujf
    gurhepofggfffhvfevkfgjfhfutgfgsehtjeertdertddtnecuhfhrohhmpedfvehhuhgt
    khcunfgvvhgvrhdfuceotggvlheskhgvrhhnvghlrdhorhhgqeenucggtffrrghtthgvrh
    hnpefhffekffeftdfgheeiveekudeuhfdvjedvfedvueduvdegleekgeetgfduhfefleen
    ucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepmhgrihhlfhhrohhmpegthhhutg
    hklhgvvhgvrhdomhgvshhmthhprghuthhhphgvrhhsohhnrghlihhthidqudeifeegleel
    leehledqfedvleekgeegvdefqdgtvghlpeepkhgvrhhnvghlrdhorhhgsehfrghsthhmrg
    hilhdrtghomhdpnhgspghrtghpthhtohepvddpmhhouggvpehsmhhtphhouhhtpdhrtghp
    thhtohepuggrihhrvgesughnvghgrdgtohhmpdhrtghpthhtoheplhhinhhugidqnhhfsh
    esvhhgvghrrdhkvghrnhgvlhdrohhrgh
X-ME-Proxy: <xmx:S6GLacNSN54lK1oupX0-Fve40l44v3bN_380MUQGF3ETjgDw2wsHnw>
    <xmx:S6GLaQ64h5_DEFu_UFz8xCOvKF1-Uz4eFvhx0uggmwmhunJU4XzHiw>
    <xmx:S6GLaa1v1JYtmqZNHDkn_nr2MxZZAjnANxMAEjNMpl92uTWq-Uwe3w>
    <xmx:S6GLaRbm3Kvcf5AHK5fjFJX4Q6dD9g7iFWPo00TT8zZ3k_WzOJv7uQ>
    <xmx:S6GLaSBuoq_SGnq4FESXUJozgAF0fmNRYdvfQ2O0tF6_floKZEB38KnY>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 38561780070; Tue, 10 Feb 2026 16:21:15 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A7FasjyZ6tmc
Date: Tue, 10 Feb 2026 16:20:53 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Daire Byrne" <daire@dneg.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Message-Id: <d97b4a81-7fbe-405e-b5dd-82e74630c9d9@app.fastmail.com>
In-Reply-To: 
 <CAPt2mGPMvQMyMcNUnznqU=0pSZ4xVDB32Q61_gTkL9TvHyKXrA@mail.gmail.com>
References: 
 <CAPt2mGNAGaO8hP9u4M+oH0_w0dbSNAmDF=g0jyb26ED5R_mhOA@mail.gmail.com>
 <a1b6c46f-e49d-4ae6-ae5e-3c08ed40e359@app.fastmail.com>
 <CAPt2mGNL4neF1NX7_1=9svnNz_iXhadHw0AEjZ_B-50-vwNtUg@mail.gmail.com>
 <723418cf-cec6-4afc-906e-b93a55e85fc9@app.fastmail.com>
 <CAPt2mGNkGbWujzTzxoTGTvAWoOL9aUUhN93SEJQYJTQyV4xu7Q@mail.gmail.com>
 <d9926f9e-50bf-46e7-9109-21b30dd695c1@app.fastmail.com>
 <CAPt2mGNbZm9YDjuCUwJHiJUQUUnKQtbf1ggYPzAytgWjMp68LA@mail.gmail.com>
 <CAPt2mGOsCLrG30s7mrOvd3N5t018T+gJhGWd88pw0WbOnagO=A@mail.gmail.com>
 <110b6190-ed55-41d0-a3ca-580ebc38c1e5@app.fastmail.com>
 <CAPt2mGPMvQMyMcNUnznqU=0pSZ4xVDB32Q61_gTkL9TvHyKXrA@mail.gmail.com>
Subject: Re: knfsd read iops limits?
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Tue, Feb 10, 2026, at 1:34 PM, Daire Byrne wrote:
> On Tue, 10 Feb 2026 at 16:53, Chuck Lever <cel@kernel.org> wrote:
>> On Mon, Feb 9, 2026, at 6:43 PM, Daire Byrne wrote:
>>
>> > Anyway, the attached lockstat is consistent in both cases - the nfsd
>> > threads are using all the cores of both sockets.
>> >
>> > I don't see much difference in the patched and vanilla cases. I will
>> > triple check that the patch series was applied successfully and I
>> > didn't mess up the install.
>>
>> The lockstat data shows that the patches are applied and that flat
>> combining is reducing xpt_mutex contention, as designed.
>>
>> This time, the lwq spinlock in the thread pool dispatch path
>> shows very high contention (246M events, 54k seconds total wait).
>>
>> Could you collect "perf record -a -g -- sleep 30" during the same
>> workload? A perf profile should show whether that's the throughput-
>> limiting factor or whether nfsd threads are spending their time
>> elsewhere.
>>
>
> Sure thing. I have attached a perf report of the workload with one of
> the nfsd threads expanded.

Thanks. The two significant contention areas are the lwq idle
list in the SunRPC thread dispatcher and the group sort in
nfsd_setuser. I'll post some patches to test in a day or two.


-- 
Chuck Lever
