Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A475E344D91
	for <linux-nfs@vger.kernel.org>; Mon, 26 Jan 2026 16:43:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769445829; cv=none; b=aENtBFr+zT6mzY7u8wd3mTgmnAAqNxIwjZp5JrgwthcsRrNkSbouszbp0BWRqCkvgBQe51o/XWG4Xqc1X0VaSaigF2rGy5PIxJ2fRwibpI/acFJ2eZNesCXCARv1F1EnoPFY/QGkmktZt7YjB4Pf8QeEhiIC451hoFRI6AKQzJs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769445829; c=relaxed/simple;
	bh=3UWo939L6qAo1geRf3z+Q3XrV55NBiqDxtsdzDzUB6k=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=irDPpDj7wPFWmMBWKaaZX8SHbKV9SmNP+R0w9NPrGtrItM1YcVVqZSRatQ/pgwc8pn/cauUWCckG74uf7da8+YsqRZJsFAVQY5s59XSGW+d0vXvDmuyK075TYAYt96sPM/XFUXKe8GQrO9PRAhJlzl59T7T3QqlBq0iaII3UHoY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=qKtDcd4D; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="qKtDcd4D"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 122F0C116C6;
	Mon, 26 Jan 2026 16:43:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1769445829;
	bh=3UWo939L6qAo1geRf3z+Q3XrV55NBiqDxtsdzDzUB6k=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
	b=qKtDcd4DkHQQDVYgjbB3yh+iEJckhc4+eFnIZABjylnmieShF4BU7PWM6GBa2YSIB
	 PER9KA6GLxWXwfAu2Sm40KZk18ub0YK/m4h/BH3yFJNfaqUtMBIQmZ7srJSxhCpxah
	 SFIXeAYUdnShTBBSWC6IjycupLW7HsZZdBuKz0qvMKPJH5v0mpvtg13PWRJ2ueJV2E
	 nbOVxD3lfJBRHICe/PrTZ1s71ZTkCsg4WVe/TK7SnHRqXTumbg5FAPHKn0qDyDU/P/
	 VQ3jCFvlmyIGj11qA+BGjuZmaaIKebzhaH3xAGZXzEOZY9g4oETw0qlsC1FGw+F8oG
	 SnaWmBusf/5zw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 1D3E4F40068;
	Mon, 26 Jan 2026 11:43:48 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 26 Jan 2026 11:43:48 -0500
X-ME-Sender: <xms:xJl3aacQ0WAVnPG1svfKIfYFhSM4VDe9T--lNfvOeOdFYWWEHS2wKA>
    <xme:xJl3afD0fBUbVs5ZoNje6daQN3CgVQRMJK1qtf-qWvL3gk5OqTT3_Le7E2OYY1X6K
    kqC0l3viLRQWTbpXLK4Jvn4oPYIo9axtPBuBY93upnydAKC6H-Epy3z>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgdduheekudekucetufdoteggodetrf
    dotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfurfetoffkrfgpnffqhgenuceu
    rghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujf
    gurhepofggfffhvfevkfgjfhfutgfgsehtjeertdertddtnecuhfhrohhmpedfvehhuhgt
    khcunfgvvhgvrhdfuceotggvlheskhgvrhhnvghlrdhorhhgqeenucggtffrrghtthgvrh
    hnpefhffekffeftdfgheeiveekudeuhfdvjedvfedvueduvdegleekgeetgfduhfefleen
    ucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepmhgrihhlfhhrohhmpegthhhutg
    hklhgvvhgvrhdomhgvshhmthhprghuthhhphgvrhhsohhnrghlihhthidqudeifeegleel
    leehledqfedvleekgeegvdefqdgtvghlpeepkhgvrhhnvghlrdhorhhgsehfrghsthhmrg
    hilhdrtghomhdpnhgspghrtghpthhtohepudehpdhmohguvgepshhmthhpohhuthdprhgt
    phhtthhopegurghvvghmsegurghvvghmlhhofhhtrdhnvghtpdhrtghpthhtohepsghfih
    gvlhgushesfhhivghlughsvghsrdhorhhgpdhrtghpthhtoheplhhlfhgrmhhsvggtsehg
    mhgrihhlrdgtohhmpdhrtghpthhtohepvgguuhhmrgiivghtsehgohhoghhlvgdrtghomh
    dprhgtphhtthhopehlihhhrghogihirghnghesihhsrhgtrdhishgtrghsrdgrtgdrtghn
    pdhrtghpthhtoheprghnnhgrsehkvghrnhgvlhdrohhrghdprhgtphhtthhopehhohhrmh
    hssehkvghrnhgvlhdrohhrghdprhgtphhtthhopehkuhgsrgeskhgvrhhnvghlrdhorhhg
    pdhrtghpthhtohepthhrohhnughmhieskhgvrhhnvghlrdhorhhg
X-ME-Proxy: <xmx:xJl3aeKkEI4SocJDGBRW4txsUaNP6moLnLr9BKe2seSDAIW3UQMbGw>
    <xmx:xJl3aUp-F01NdIKcuDvs61M-BQEt1QOLbQrhgihchcFGWSkeFcJhJw>
    <xmx:xJl3aVhdq_zubHyDkCCurqhW3bwbxuWGI-F7l9V3RH_eBOunsa4tXA>
    <xmx:xJl3aTYaWrne4dpudBq2-Ho_HaiIrWPicM96W3FfYKImyUL__uD4eg>
    <xmx:xJl3adnqsKxEyO6csg7-ZPbYI5m17qQn0BZ_MChYHYgJxlEtZ_0GX7MX>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id ED751780070; Mon, 26 Jan 2026 11:43:47 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AhhugJyzaYCV
Date: Mon, 26 Jan 2026 11:43:18 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Haoxiang Li" <lihaoxiang@isrc.iscas.ac.cn>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 davem@davemloft.net, edumazet@google.com, "Jakub Kicinski" <kuba@kernel.org>,
 pabeni@redhat.com, "Simon Horman" <horms@kernel.org>, llfamsec@gmail.com,
 simo@redhat.com, bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, stable@vger.kernel.org
Message-Id: <9b028652-eb5b-4faf-bf9c-6d64f0ed7a9f@app.fastmail.com>
In-Reply-To: <20260126021047.2478741-1-lihaoxiang@isrc.iscas.ac.cn>
References: <20260126021047.2478741-1-lihaoxiang@isrc.iscas.ac.cn>
Subject: Re: [PATCH] sunrpc: fix a resource leak in gss_proxy_save_rsc()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Sun, Jan 25, 2026, at 9:10 PM, Haoxiang Li wrote:
> In gss_proxy_save_rsc(), if gss_import_sec_context() fails,
> call gss_mech_put() to release the reources acquired by
> gss_mech_get_by_OID().
>
> Fixes: 030d794bf498 ("SUNRPC: Use gssproxy upcall for server RPCGSS 
> authentication.")
> Cc: stable@vger.kernel.org
> Signed-off-by: Haoxiang Li <lihaoxiang@isrc.iscas.ac.cn>
> ---
>  net/sunrpc/auth_gss/svcauth_gss.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c 
> b/net/sunrpc/auth_gss/svcauth_gss.c
> index a8ec30759a18..cdae1f23adfc 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -1268,8 +1268,10 @@ static int gss_proxy_save_rsc(struct 
> cache_detail *cd,
>  						ud->out_handle.len,
>  						gm, &rsci.mechctx,
>  						&expiry, GFP_KERNEL);
> -		if (status)
> +		if (status) {
> +			gss_mech_put(gm);
>  			goto out;
> +		}

Is the reference already released via free_svc_cred() ? This
change might introduce a double-free bug.


> 
>  		getboottime64(&boot);
>  		expiry -= boot.tv_sec;
> -- 
> 2.25.1

-- 
Chuck Lever
