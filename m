Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5F16A1DF75B;
	Sat, 14 Feb 2026 15:40:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771083600; cv=none; b=PYH+N6XfCCCYBfp4k5dwb8cOK671mmg9DpBYv8rNkfflBKD+oi1MjS98FhgvJb6amVOxbIt5xMhAL192m4s2omdirshKHKifUzr0VsqU61APwwy1KKOWimKBIONtlSm5WMrM9beZC1nPAj6L0q2rE+61zInTMvIak7Sy/zXAIbQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771083600; c=relaxed/simple;
	bh=7Ln5p6/GgZp7TptAdghOuzwP6zLRRUn3PjDlfScXZFs=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=dlHK43C7Quiu2HTT0ShRfrO/zucdUoRTLH7fCxqbZp1gh/1Qk15LN8KBHTwnssLl2G2L1At6/v2BwTXDcv6hTe6LTwzGi39P3ks9ycAmeB7Tu81AG7NhtCwigdXPIxf1gRwPcXWMj3zng41l4t4shOd38RnL8uuRveW0wYPcFFM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SzS/zIiU; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SzS/zIiU"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A684CC19422;
	Sat, 14 Feb 2026 15:39:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1771083600;
	bh=7Ln5p6/GgZp7TptAdghOuzwP6zLRRUn3PjDlfScXZFs=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
	b=SzS/zIiUOy2XuL1i3373nFcN/4DHgWJCWy5Szz5nhum9WW/H4iRYigR8EU7+z2bKC
	 3sKCerPFYbrkHHVLYDZEipq2wXW1eQxLkPHZgmytAO/OEbJWEL0c5IqGG8S/+53t55
	 w1Xm6/ACMGWUcU0pG3C27hGaqrMlAchQuBxgSC5Pk9oNUio43eTE7737ZMnvP+DB8l
	 Ms0dThWwqpaE2BciRl2nk9lBBe0Hza2UWYfc82ry5weyfrp6FOnH2WWj1hsfj122c8
	 Q3oI3FrbdqwX2Eq+vSHcy/BG87erpXIB4epTvNbfXl9ChVHIPlfL1gD+Si93zt5wo0
	 SIUViQOA4nP0Q==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 899ADF40068;
	Sat, 14 Feb 2026 10:39:58 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sat, 14 Feb 2026 10:39:58 -0500
X-ME-Sender: <xms:TpeQaYEwbefr58LTbT0PYn0GzQW7Z4dDVPzj-zKZZ2uPChYYNOt8QQ>
    <xme:TpeQacJgjBMmfRfrEvb4PqvicUXnm9y57IntwCEt_FHjeo43D0oaqFxATycqq-kTJ
    uK0oCyg_DK-DGT5RkfN6_TLKt2J8s0OJE-WLO5Mj3im9jhulZFX>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgddvudduheduucetufdoteggodetrf
    dotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfurfetoffkrfgpnffqhgenuceu
    rghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujf
    gurhepofggfffhvfevkfgjfhfutgfgsehtjeertdertddtnecuhfhrohhmpedfvehhuhgt
    khcunfgvvhgvrhdfuceotggvlheskhgvrhhnvghlrdhorhhgqeenucggtffrrghtthgvrh
    hnpefhffekffeftdfgheeiveekudeuhfdvjedvfedvueduvdegleekgeetgfduhfefleen
    ucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepmhgrihhlfhhrohhmpegthhhutg
    hklhgvvhgvrhdomhgvshhmthhprghuthhhphgvrhhsohhnrghlihhthidqudeifeegleel
    leehledqfedvleekgeegvdefqdgtvghlpeepkhgvrhhnvghlrdhorhhgsehfrghsthhmrg
    hilhdrtghomhdpnhgspghrtghpthhtohepkedpmhhouggvpehsmhhtphhouhhtpdhrtghp
    thhtohepnhhsphhmrghnghgrlhhorhgvsehgmhgrihhlrdgtohhmpdhrtghpthhtohepsg
    hrrghunhgvrheskhgvrhhnvghlrdhorhhgpdhrtghpthhtoheplhhsfhdqphgtsehlihhs
    thhsrdhlihhnuhigqdhfohhunhgurghtihhonhdrohhrghdprhgtphhtthhopeguhhhofi
    gvlhhlshesrhgvughhrghtrdgtohhmpdhrtghpthhtohepkhgvhihrihhnghhssehvghgv
    rhdrkhgvrhhnvghlrdhorhhgpdhrtghpthhtoheplhhinhhugidqtghifhhssehvghgvrh
    drkhgvrhhnvghlrdhorhhgpdhrtghpthhtoheplhhinhhugidqfhhsuggvvhgvlhesvhhg
    vghrrdhkvghrnhgvlhdrohhrghdprhgtphhtthhopehlihhnuhigqdhnfhhssehvghgvrh
    drkhgvrhhnvghlrdhorhhg
X-ME-Proxy: <xmx:TpeQaYVaDTGC_TqOZguZYb-yx6eTkNymOAhexlSCoKU8Clw3vK2ssg>
    <xmx:TpeQadC-QLztsDG6FrCXCHxXwGT4jVSF4NVEBR2THnZIWxzvjjM2dg>
    <xmx:TpeQadEax2NAlTT5MdBTWDzPyZTHHHDTu5XbgPzuCvBjV5x-dahZxg>
    <xmx:TpeQae4XVsw5veBt9PT59cwjMsdKHBApc2ytRVSfBwX9bjrl7frNsw>
    <xmx:TpeQaTk9NkFh9Gi2UVfY6aNXL0Bt27NK1kqCDZYKWhgjKjvT4ExZSOil>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 66269780075; Sat, 14 Feb 2026 10:39:58 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A-xRDuNKAwPJ
Date: Sat, 14 Feb 2026 10:39:34 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Shyam Prasad N" <nspmangalore@gmail.com>,
 lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, keyrings@vger.kernel.org,
 CIFS <linux-cifs@vger.kernel.org>, linux-nfs@vger.kernel.org,
 "Christian Brauner" <brauner@kernel.org>,
 "David Howells" <dhowells@redhat.com>
Message-Id: <7570f43c-8f6c-4419-a8b8-141efdb1363a@app.fastmail.com>
In-Reply-To: 
 <CANT5p=rDxeYKXoCJoWRwGGXv4tPCM2OuX+US_G3hm_tL3UyqtA@mail.gmail.com>
References: 
 <CANT5p=rDxeYKXoCJoWRwGGXv4tPCM2OuX+US_G3hm_tL3UyqtA@mail.gmail.com>
Subject: Re: [LSF/MM/BPF TOPIC] Namespace-aware upcalls from kernel filesystems
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Sat, Feb 14, 2026, at 5:06 AM, Shyam Prasad N wrote:
> Kernel filesystems sometimes need to upcall to userspace to get some
> work done, which cannot be achieved in kernel code (or rather it is
> better to be done in userspace). Some examples are DNS resolutions,
> user authentication, ID mapping etc.
>
> Filesystems like SMB and NFS clients use the kernel keys subsystem for
> some of these, which has an upcall facility that can exec a binary in
> userspace. However, this upcall mechanism is not namespace aware and
> upcalls to the host namespaces (namespaces of the init process).

Hello Shyam, we've been introducing netlink control interfaces, which
are namespace-aware. The kernel TLS handshake mechanism now uses
this approach, as does the new NFSD netlink protocol.


-- 
Chuck Lever
