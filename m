Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 286E63A05CA
	for <linux-nfs@vger.kernel.org>; Tue, 12 May 2026 13:23:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778592193; cv=none; b=KGKeC9pgE9+fpjNgsuYE2wjlgWef60CE1qD+TsNBQfT3AvqqtdqrqwsszQsu/uNnYAlBy5xVzL1M/6n8Minqs0K9AIK7H7RCb43jDr3U8PT3HVjzwiFhhMwo7LnEJYBAalLCgh7K6+En/TH61wQZglBZ7NOgMLv5FhKBDBM2XXM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778592193; c=relaxed/simple;
	bh=PI+uCwI5dxmyTse/0RTKGa7rkbWq5Ij/LDGtGlJlOPE=;
	h=MIME-Version:Date:From:To:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Kqj/fZSDfcCBT9aZHZw9cmyM52TKkU6kHq5sDw3zKW1CgfbmMgoNP+ObfKKjAwvVE076vuvGFU0NYnv239WHI+81mxnK+uWf1zK6QxE+h5crBNygwcz7qaicNcBCMSJmULvsbUTRt4fYlh90KQVBrdr4zV/Kn6laNgnOUvEknbY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=rZY/26yb; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="rZY/26yb"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BC84CC2BCF5
	for <linux-nfs@vger.kernel.org>; Tue, 12 May 2026 13:23:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1778592192;
	bh=PI+uCwI5dxmyTse/0RTKGa7rkbWq5Ij/LDGtGlJlOPE=;
	h=Date:From:To:In-Reply-To:References:Subject:From;
	b=rZY/26ybxfL9yg5+AykQFjkG3zXiXu6Quumwjl9d/L0J5wzr1uTYGNOtcJuzlLpF1
	 ZXUPcxbp7YgrpEb/BZMKRzHT2kKNSjkqPYEErHVCIeB8Z5KZNqgp7HTTD6PquYOIZe
	 KM0s29EqT87iw82ihhOrVJTPA9cdWu52ZAbfESYJRwSDX7B0BCkaSGZjYwsQbkc5Bw
	 +cq9P/Llm/Q7RmvAAuMSKFJDGKQM+xQrzx1obGSksxfkYpqAlo+nWejygH9Yl/uuih
	 lPfEk4OFdyO6QDls9taNdFfEiG6R392vNsX6ltOS1gdpZRPmgINF64IAg8j6RvISwe
	 gj9RrcmMEWMmA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id E647AF4007A;
	Tue, 12 May 2026 09:23:11 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 12 May 2026 09:23:11 -0400
X-ME-Sender: <xms:vykDaqG25KqX9G2H6GLBIH82uf2RiBBsF0aYRsf7BrPTfs3R1Z2acA>
    <xme:vykDamI8cRVx8CUTScZ4HOuJu6l8tEOstqBglI5OohTRB2WkqIltKJWwUg5YvA2VA
    8Ff9D6PNuttUUaHAFSUL5SvzvILecs8LJr-v42vzdaJjwBCFtHfGMQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefhedrtddtgdduvdduleduucetufdoteggodetrf
    dotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfurfetoffkrfgpnffqhgenuceu
    rghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujf
    gurhepofggfffhvffkjghfufgtgfesthejredtredttdenucfhrhhomhepfdevhhhutghk
    ucfnvghvvghrfdcuoegtvghlsehkvghrnhgvlhdrohhrgheqnecuggftrfgrthhtvghrnh
    epheehjeelgeffffeihfduudevudeghfehheefhffgueeluedufeetjeduhfdukeelnecu
    vehluhhsthgvrhfuihiivgeptdenucfrrghrrghmpehmrghilhhfrhhomheptghhuhgtkh
    hlvghvvghrodhmvghsmhhtphgruhhthhhpvghrshhonhgrlhhithihqdduieefgeelleel
    heelqdefvdelkeeggedvfedqtggvlheppehkvghrnhgvlhdrohhrghesfhgrshhtmhgrih
    hlrdgtohhmpdhnsggprhgtphhtthhopedvpdhmohguvgepshhmthhpohhuthdprhgtphht
    thhopehlihhonhgvlhgtohhnshduleejvdesghhmrghilhdrtghomhdprhgtphhtthhope
    hlihhnuhigqdhnfhhssehvghgvrhdrkhgvrhhnvghlrdhorhhg
X-ME-Proxy: <xmx:vykDagwIvkkY-ZZzFUkXV9-7E86g1fz8yu8fEAa-mmKRy3UgaZPhhA>
    <xmx:vykDaiN-DhyTVPHXXeLNQDS8dVDq7ZeY5AANB7PRBdiCZ-oHX5xD0w>
    <xmx:vykDap6kiYPKWhiNnN3GlMAJM_rmeL695CUqvpCPLHKdoAsw8LrCeA>
    <xmx:vykDarP2wA4E8ZM0qvhF_O4sqxf56WiXBQ1eccKihZrxrraeQt_SKA>
    <xmx:vykDavmOZih-diaaa1D7aD8d4q_MWyDHDU6rs3dBC8G2xDbTGCDfLrWZ>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id C8BE9780075; Tue, 12 May 2026 09:23:11 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: ALV4ADXmNQfR
Date: Tue, 12 May 2026 09:22:41 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Lionel Cons" <lionelcons1972@gmail.com>,
 linux-nfs <linux-nfs@vger.kernel.org>
Message-Id: <e44aa868-5ec8-4c35-b5bc-5066487a28be@app.fastmail.com>
In-Reply-To: 
 <CAPJSo4XdpOu_yNGpbMMQ0hAO+mdOy2-TsEke_vHGm60k6jp2Bw@mail.gmail.com>
References: 
 <CAPJSo4XdpOu_yNGpbMMQ0hAO+mdOy2-TsEke_vHGm60k6jp2Bw@mail.gmail.com>
Subject: Re: Suggestions to drastically reduce Linux nfsd I/O latency on BTRFS?
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Tue, May 12, 2026, at 5:47 AM, Lionel Cons wrote:
> Are there suggestions on how to reduce Linux nfsd I/O latency on
> BTRFS?

For us mere humans, the first step is you need to root-cause
your issue. But consider using an LLM to help you with this
process.

Example questions to guide your analysis:
 - What particular NFS operations are taking too long?
 - How full is your exported file system?
 - What backing storage is in use, and what mount options?
 - What transport (TCP? RDMA?)
 - How much server CPU is available when the it appears slow?
 - If you are using NFSv4, are there other clients that emit
   conflicting OPENs and LOCKs?

Then, can you post some metrics?


-- 
Chuck Lever
