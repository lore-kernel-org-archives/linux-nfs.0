Received: from fout-b5-smtp.messagingengine.com (fout-b5-smtp.messagingengine.com [202.12.124.148])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 33B7D39E191;
	Thu, 30 Jul 2026 23:40:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.148
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785454847; cv=none; b=KbQ5hjaV5UPYL/GwnV8hO8QdKi/yImUa4U31J/Pn9cArRPD9enQaA+2DzmriTDzXe56pL7+YV9vFMqy89+oIiQCPxns0jndnpwZyUmuTS3V51Jq6AfYSt08cBmTUA5ioxTXj2YfCyWiC4UMqj9N64hQ5VlVzkkYFBY2s8alKtWA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785454847; c=relaxed/simple;
	bh=0PNVvQgfL86+YniH6IHoJ9fAdMxPjBqjO5seQ79794M=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=op85+jWyCovDhsKmB8sIz0ZB1/2JIPYh/VBaWUxcYXuao582fAfZFeY5/KihP98tp6+F41+zJdAwnZZ9ofqF52tukP7JBZygbocUQmJG1s3X5bvJHBFiHuxM5Azwsq7rMzRJIqulE66rwnJn+z3pPs1I8nVzgcPVlsXEhm9yo6k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=queasysnail.net; spf=pass smtp.mailfrom=queasysnail.net; dkim=pass (2048-bit key) header.d=queasysnail.net header.i=@queasysnail.net header.b=mhb8RRty; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=l2pO+Nj/; arc=none smtp.client-ip=202.12.124.148
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=queasysnail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=queasysnail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=queasysnail.net header.i=@queasysnail.net header.b="mhb8RRty";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="l2pO+Nj/"
Received: from phl-compute-09.internal (phl-compute-09.internal [10.202.2.49])
	by mailfout.stl.internal (Postfix) with ESMTP id D17C41D000FF;
	Thu, 30 Jul 2026 19:40:43 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-09.internal (MEProxy); Thu, 30 Jul 2026 19:40:44 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=queasysnail.net;
	 h=cc:cc:content-type:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to; s=fm3; t=1785454843; x=
	1785541243; bh=jm90P0QTqonir4lfY0yCf15wuiPe9qHY5yBWGJm+IBo=; b=m
	hb8RRtye2BYSIkoNqU6aFODz+x/gG025jt5rgnauAo7dNKuKh7GVJRuRwHEzvIKX
	lIovAEivGDRg2+73ESxMJcn73FBcHsKAHZ34SI5GFGE/bWOjneKJWjzIghNZnw8j
	LR5ow7cugeYkL8CrSIxQzEb1RAP/HIe7NZ2Y1JkfGtms29t9qOImRpusoihocFI/
	hxfJsFXOcDlOeoD1anZ/Zago8kUOWEYjLIjFdT/AaGSq3VqYcPZbpBbDnfATaQGG
	fBSdKw6QoJqsnO2yDegSVuzYr1nyrF7ye8TNxHLJ+C3QgtQD0P/wdjId8rMMr+cx
	NpHCUUOdI5ZM9Ab49cWsg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-type:content-type:date:date
	:feedback-id:feedback-id:from:from:in-reply-to:in-reply-to
	:message-id:mime-version:references:reply-to:subject:subject:to
	:to:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=
	1785454843; x=1785541243; bh=jm90P0QTqonir4lfY0yCf15wuiPe9qHY5yB
	WGJm+IBo=; b=l2pO+Nj/2wl23I/OqdSRmKKIpUjMGVRpgZuhjYMga5dgbWMKBAY
	tw077g6pWd9JVT7S8d5CtSqhb7zz00IE6FajmZ+MdXRJJOPqIZ8H0+s0wrvsDoPs
	wdAqdSFXWVy+GYTk0W9RnZ0435qBYXwKTiA8HzxnU3/Q/BseaxVUgS3Vnsczb1kE
	SQdPCwA+4vEzm1+DedEmY7bcNKZ8zlVpSLnanSjbRw7pvgX3irpPY4TxH0XpBsU/
	oIhwNlfLH36hzU/UBOt43AEjAZGnsKakf7rNulxEGeieMOpj7lLppawOTk5eKk9/
	kJpJ9GFFEtH/jE9m/+G4RSPZc9owfTIh6qA==
X-ME-Sender: <xms:--Brau69MibfHkvhXUnIJr781r7ggt3r2ZL_irl4hC6YRnDfPluAlA>
    <xme:--BraoUlUYmPxfJM985n02u10BAey3psdvKQEQzL5TsYqry7G_n_iB48p35yfwo6P
    kGTCVQVnUeEU9HkubG21VGzVXQyfM6fqfrHJV7oyr-JtWH6bBlVhec>
X-ME-Received: <xmr:--BratPnwawKdSfsJa55MSs-O_9i4M43xXw3q_ZuRZyNK0mrCAu3ah_Aduw>
X-ME-Proxy-Cause: dmFkZTFYVk8NcSk2wbNwhdLtdsXGeH/R86n5D6efhvDDwcgweVCYRCd6ygvYP0P0kRw4HE
    NEk522CLUaeiD3DmFH9Csg5IQMZO9JjS8trb9+IYM+AIOZcr39azQXu37Auhe68cm/jvcg
    kUUdtH4FDa89R1QUWxIqAw3K/bAGBzzOKN1y4dYMIHOXe4BKMtvSJcgtQIJDHLyoMFnJou
    p+MNve5ri9MQc1SrhqauCu6WvILKE+XfQ+7oCMThCQVwi0AhdYhmzRq1Eq0usls5P9VT1e
    xgKRzIf0w4rCVyh93ccd0/Qcct2IJrQnYhsKpIh6MTQ5C4mef2vpk3+jGlLTFCat/SOoKy
    VKN4JA7g9Iq/PpIIfnh6HwFiOKY6f86jIH6eIQAH9uW75YSIzSqvRM0ZbDo3GD7YhXlpsN
    M35GhqTk7vjDRkEstp9klgAh/6YxGepivlbgwqDygEBO8xx/SPHPbNVUi1nbV88tfPMgHX
    Egsyhg68wFRcpQPO34gDy0EBdaBFSZvhQdWuB0nJo4i7VdsRbsSCLrhT/vsR+ou7bqkE+4
    Dp+lgBB5RxFiNAx6wNhz6jHNGMfbtWA79lSTN3HbQVPGGS7/Dzn96k7vVUx0iisDSm4r6P
    CwUYc0RkcNadyLzDXLa15TfUSfHc0cF5RAtl+bzurW8vc+9ZAMD98JqvUejg
X-ME-Proxy: <xmx:--BrangW7cvj7kf6I4YioPYjm21EZGnclB21Rzh7XZ5m_ORaRINxsQ>
    <xmx:--Brar5rbbdsU1OpArGq5MzGvOhvVK9mIgl_gEIQS1iTLIcCEaveeg>
    <xmx:--BramfzPjNd3iwgIboBY9sXrhVPSmYUqHH6zjQ43tI9bUWsPmT6wQ>
    <xmx:--BrasC0wSlvWI2GZM9i2h0bX529qLN92KndjYT1PPlUNBupoU2KLw>
    <xmx:--BraqPzFn-wKVOmcAAwcnWGl7f7GzXncAsiEqGZEeQ2pqC6pWhxnDly>
Feedback-ID: i934648bf:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Thu,
 30 Jul 2026 19:40:42 -0400 (EDT)
Date: Fri, 31 Jul 2026 01:40:41 +0200
From: Sabrina Dubroca <sd@queasysnail.net>
To: Jakub Kicinski <kuba@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>,
	John Fastabend <john.fastabend@gmail.com>,
	Shuah Khan <shuah@kernel.org>, Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	netdev@vger.kernel.org, kernel-tls-handshake@lists.linux.dev,
	linux-kselftest@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH net-next v2 2/6] net: Introduce read_sock_rectype
 proto_ops for control record delivery
Message-ID: <amvg-dZzDB6GzzSH@krikkit>
References: <20260720-tcp-read-sock-v2-2-29545d034f3c@kernel.org>
 <20260728185124.72e421c8@kernel.org>
 <480a8337-a91e-40e5-8dbd-d165599fba4b@app.fastmail.com>
 <20260728193058.7f6b453b@kernel.org>
 <a6fb364d-8344-408e-bcd5-0cee4ffabdc3@app.fastmail.com>
 <20260729163142.4f41484f@kernel.org>
 <amtcwSO24GGq_qd0@krikkit>
 <20260730143556.4a8463fd@kernel.org>
 <amvZraHU3n2sQts1@krikkit>
 <20260730163457.1105fa69@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20260730163457.1105fa69@kernel.org>

2026-07-30, 16:34:57 -0700, Jakub Kicinski wrote:
> On Fri, 31 Jul 2026 01:09:33 +0200 Sabrina Dubroca wrote:
> > To avoid that, you'd have to run recvmsg-nocmsg/read_sock to get all
> > the DATA out, then once you know the next chunk of payload is a
> > control record (and hopefully nothing else is reading from your
> > socket), one recvmsg+cmsg into a separate buffer.
> 
> I guess the difference in perspective stems from a fact that
> I'd look at a socket as a stream one reads and dispatches work
> based on the input. Not an abstraction layer that by itself
> dispatches different handlers for different message types.

I agree. But TCP is a magical world where users don't have to worry
about message types, and TLS isn't. It seems the users of the existing
(TCP-oriented) API are unhappy with the mismatch, but I'm not
convinced we can (and maybe "should") make that work.

-- 
Sabrina
