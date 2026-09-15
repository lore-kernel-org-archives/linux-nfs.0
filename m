Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7858F4D09E2;
	Tue, 15 Sep 2026 19:08:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789499314; cv=none; b=USG0WSfqjGDCOIRMlr2Vr9IFpog6dA+npADIMwKM3Jw4JIo6DWQJy4U9KajeQXM16jsvMcwBwUnAnoXCWjoeK2zPXl8OemsM3V08mo5b3tqxVfLzG0kcd1ssP3w98Op+6kpfM2iPubhUbi2pAV1bwZDE2UeZIlKR6A+qSqStUOY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789499314; c=relaxed/simple;
	bh=67p3qO6XFHgTNei/moOP3TD5vJzpNZwxCxms2udUC8k=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=R/wShnOFMwa/IF8sf9OdYVclhG5G+zARhrSK57aeCFGXuRH5wsu5Jcq5c92V5kEBZ3iU+yxRV9uL+scZTmSA5QoZ/7jRdX2A4/Swqj0WWWgq9dE6SzmjQihyURMAQwdtF63SeldYWavf1gdfTs7NZNBfKrc48HrijHGGQ/bx8rM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=IEBbZlN3; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="IEBbZlN3"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A0C5E1F00899;
	Tue, 15 Sep 2026 19:08:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789499313;
	bh=exhivTK2z7bblDWMC5lKR4EogIyFBYeXjdR0BKrI96M=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=IEBbZlN3/KWu9n26NYRxraArk7xS1SFMK0RauA6GJbkNRGdbZSK4OG5M8SNkUSzHv
	 lItfPCUEPvYjA2RJHs/e2ib4h1a0PI4P64ZKkU3cjuU0LTPA+BUoKp4iuazYaLpLuq
	 KztZ5NxiE4UGGk4ji5czjoZMd6zzAiOMSSagRpAnqrSDFB7GBkmwyxdBdFgak4Avvz
	 zItwzqjB0RHg7Gz4unz1vJOGbtmSMQGiK6Q/AumqMqc3oAek2iW85+wCclfD2WNgob
	 qT5YUt/954ktRUc2IQ0R59UlimYqPY6Blfgn/RutuOjiCfVWR5qWZ+QKNxLwQb8TKM
	 amJHRGpkauvEA==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Aldo Ariel Panzardo <qwe.aldo@gmail.com>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Subject: Re: [PATCH] nfsd: zero NFSv4 COMPOUND tag padding
Date: Tue, 15 Sep 2026 15:08:26 -0400
Message-ID: <178949928864.1538756.8077623230283401923.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260915160049.3105481-1-qwe.aldo@gmail.com>
References: <20260915160049.3105481-1-qwe.aldo@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Tue, 15 Sep 2026 13:00:49 -0300, Aldo Ariel Panzardo wrote:
> nfs4svc_encode_compoundres() copies the tag bytes into reserved XDR space
> and skips directly to the aligned end of the field. xdr_reserve_space()
> rounds the reservation up but does not initialize the padding bytes.
> 
> A remote client can choose a tag length that is not a multiple of four,
> causing one to three stale bytes from the response page to be returned in
> the COMPOUND reply.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfsd: zero NFSv4 COMPOUND tag padding
      commit: 28c0a5693a60625fb794943f2755c4bc5643f7c4

--
Chuck Lever

