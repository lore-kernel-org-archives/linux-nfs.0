Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795274868;
	b=bYvam921EuqLgiuI9LEEGZrJ32YQPXFAo/7ol8opkuy//aFHta3BRmEoDNRyPvCzYCrH
	 m5khcr22XB+dueFPO6Zqi+KdOOyf3YAO99NzXQs13vfJs44Crbwudy9YL5IiG27fWOJ9G
	 E2IafJ6tp5Xjw8BdVl14ps5fXDqVc4pRKvWF8cmQ62ObGJzDRagIwtjQhlQCxgkBvClM1
	 l7My/rVcd0/xqJL1MAaGSL10qHbHmm5CdXLvH+XETQcJtfM1gNxm5mAiMxc95WBomYOSi
	 susq13gYCBO7AIhQzM42Kmp3/W6cJde2nmokZCajfIoBGR4JDHk9LK3hWxfNT8vZ8dg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795274868;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=DTrfRE+rsl3T2rYQF3HJeIGf77pd31J4Z97cOADZZYU=;
	b=GAEBzCoPcfaI/5kScYzDvx36au7RTPZwLAfPIyElmXI2xkS7yG2Bgbfd479nlGaP87cx
	 lPZgSCoT5SGDdBT2jyDkIWe/ed58Zot2x80YEIEhZpyNuOrLdV72Z/V1knrg4sjKpaKHj
	 FuhM65RC0Ejqce2aW6sd6tN3th+6fH3PDgso1Ax0Ua9VMMbcmk8lkKBycGIKb/0WgqghE
	 TyqGnvUig9fYCD/h1Kab+71YofNly29I6iuZUBR0hVMKvjpTbi1v2MypE7QuNY8QET3Wd
	 ap7yPZach2Za11lWe11JkIwPxEVey+nHM+fp6zLKIxQjdwu2yogdpq1I9gTZ7ak+MBA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GSlD+ztW;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 071EE606A320;
	Sat, 21 Nov 2026 15:27:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GSlD+ztW
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 046F61F000CF;
	Sat, 21 Nov 2026 15:27:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795274867;
	bh=DTrfRE+rsl3T2rYQF3HJeIGf77pd31J4Z97cOADZZYU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=GSlD+ztWsR56XmY+zYuUYMJL3X/gUaVYxk2KHhBDnPIWxgD/Eh4Dw2cF1MkKiM2sN
	 hqxjuICEehidMsvqucalihtvW5E6094KztZkIc7/YgZl0vwUiyz7ZRjnWIjRTdZOB+
	 c8khtd+wAimqZLUsbjWqXcG+lN3mi7mJtbFElHA/PlRjMwwkhhB4F2SQOEr69EF3R4
	 r1ejN8aTeteJkJ6quNmGOcFw7HGfr2cOwtIbr0NKnE0bbkXwKBNggig/gCrqJ4Sg/J
	 W3ebU/MmHhZ0eOmqDp9cQ0rjzyGh/nFTzl2OVQQJGTWNIxyqy4b2Cg1mj+H9QGKmHW
	 lycfaVRls9wgA==
From: Sasha Levin <sashal@kernel.org>
To: linux-nfs@vger.kernel.org
Cc: Sasha Levin <sashal@kernel.org>,
	stable@vger.kernel.org,
	regressions@lists.linux.dev,
	Max Vozeler <max@vozeler.com>
Subject: Re: [Regression linux-6.1.y]: NFSv4 server: sec=krb5p mount fails with EIO in 6.1.192
Date: Sat, 21 Nov 2026 10:27:29 -0500
Message-ID: <2026-11-21-1-daily-reply-0001@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <awFyZbQE8pDyOxUy@dp.vpn.hinterhof.net>
References: <awFyZbQE8pDyOxUy@dp.vpn.hinterhof.net>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

> Reproduced with vanilla 6.1.191 and 6.1.192
>
> Good: 6.1.190
> Bad: 6.1.191, 6.1.192

This looks like 82cf21374fb7 ("SUNRPC: Convert unwrap_priv_data() to use
xdr_stream"), which went into 6.1.191 as a prerequisite of 2188232509f1
("SUNRPC: svcauth_gss: enforce krb5 token minimum length"). On 6.1,
nfsd_dispatch() still re-initializes the decode stream from the start of
head[0], so after the conversion a krb5p call is decoded starting at the length
and sequence number words instead of the arguments. krb5i isn't affected
because its path wasn't converted on 6.1.

I've reverted both for the next 6.1 release and re-applied only the token
length check on top of the old unwrap code.

Could you check that 6.1.192 with 2188232509f1 and then 82cf21374fb7 reverted
fixes krb5p for you?

-- 
Thanks,
Sasha
