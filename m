Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5CA1D54774;
	Wed, 29 Jul 2026 02:24:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785291853; cv=none; b=eDS7UI7VpkeNRRUrXCzl74EAS/RdmfFLb9RBqq9JqRk0t+C+WW39UTUptZSb5QbfH8PzGIFWi6I1R07gnK58qHSp+LWMS1TZxe3VXvvzCqI2mITSeLu1PmxQc1j0XJCe7wdKPKp4HHxaTq2dkb6PiPRNr0ECmNXsC2AAllCkQw8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785291853; c=relaxed/simple;
	bh=XUIq8aOF6Tno9b9c/9ogAX6wHIo8g5YZZD9TCEDWNDU=;
	h=Date:From:To:Cc:Subject:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=JxvHrXnwHKOs1Sak2Qe37Yp9/WAiV8qyGcYIUpCGLoK/mf+DFehT17TTz48ye4OKeQMIJgtDeIKWwRdHeCx5qeIH6Ers0o/aF8icGdaKqsNQimnFa9G3Ip/jecn4+GiITsaKGtutgjHgPAFw/BnN1FgGcL6YbmrbMtK3C4zao9I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=WVO3SV30; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="WVO3SV30"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 942EB1F000E9;
	Wed, 29 Jul 2026 02:24:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785291852;
	bh=G4+RfJBCvWya/zp6SvMmWI5PU/fVYmvHM22tHQWDbP0=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References;
	b=WVO3SV30SUf5ppjM0jI7Ss+SBlU0MD+uyVB16M/n1YvniigqIkvQPJN7j6T8seqDE
	 PPtGEsibpQXOv8SIzBPv2hPAqhH0g0xjMC0HjSM+FjVNEwIME/tPwuGwP24sbckVXI
	 v8RXYsEGD2pKqXrqgNP6RVANi11bWwFKKkY9dmstjVSldROxlhhmuQdq5nLCP7QADM
	 wpUHi0l31tcS6+cGbywxh13xEOCw8AFOkfDskSZHgmQF/b6ccxWPhpS6GRLnbIUgvl
	 PdjzdPiocEI0XNYWVeX92Rq0Vo1HDgYEUYHQWNLYSgn2W8m6FhcM691et+0Yi330m2
	 lGmebLQ9cf9ow==
Date: Tue, 28 Jul 2026 19:24:10 -0700
From: Jakub Kicinski <kuba@kernel.org>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 "John Fastabend" <john.fastabend@gmail.com>, "Sabrina Dubroca"
 <sd@queasysnail.net>, "Shuah Khan" <shuah@kernel.org>, "Jeff Layton"
 <jlayton@kernel.org>, NeilBrown <neil@brown.name>, "Olga Kornievskaia"
 <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey"
 <tom@talpey.com>, netdev@vger.kernel.org,
 kernel-tls-handshake@lists.linux.dev, linux-kselftest@vger.kernel.org,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH net-next v2 0/6] Deliver TLS control records to kernel
 read_sock consumers
Message-ID: <20260728192410.75212c03@kernel.org>
In-Reply-To: <0e1f1b09-fa91-4a6b-b60c-39bae6e287a6@app.fastmail.com>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
	<20260728184312.20b21582@kernel.org>
	<97b61f5f-57df-4a29-85a0-613f7b7e75eb@app.fastmail.com>
	<20260728185525.27b443a9@kernel.org>
	<0e1f1b09-fa91-4a6b-b60c-39bae6e287a6@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Tue, 28 Jul 2026 22:16:22 -0400 Chuck Lever wrote:
> >> It makes sense to me. Which terms do you have trouble with?
> >> 
> >> Patch 1 is moving to a pre-requisite series, so this can be dropped
> >> from the cover letter.  
> >
> > Did you write this? If not what model did you use?  
> 
> I did not write this text. It was written with Opus 5 and reviewed by
> gpt-5.6, sashiko (gemini), and myself, repeatedly.

I was just curious. I find gpt-5.6 output largely incomprehensible.
