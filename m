Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CBB3928E0;
	Mon, 19 Oct 2026 00:14:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792368862; cv=none; b=L+ZUFaDy+tdPg7LsV5yPGl5EbVZpzO5zTgYzGpUABRd6zQIObTR1dk8lMhLN58dkCfdhgQrThI+LCmz7mOpDVEK0Sq8WIYUbGAymeXkbih/Fy/bRpRH3OFCW1hVVIOlTuUB5pRz66DM4PP/HuDlOZKyZLMZrdn9BsiBLuMusq8c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792368862; c=relaxed/simple;
	bh=31LFka9lqTPPvFf0v4Zf4jEDwkXm8S9OsSIeRxHt1N8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=BvQx3pCC+qbCdcXzG5/+Esp9hrBQrVJsC2sPu1KaM8yMOEtJd6cazQtzQG8R1vokVHjVy2uSpMTsXreVlvXNSrcbLCyv7zQZesSJ9HRUMBMXyuixVu1hCmsLAE35oWPdc7VO3WwwHQWODhY4rRF2WwPWFCTFuu4yfT19D2+NKU4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KXuOKhlZ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KXuOKhlZ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DD0DC1F000C4;
	Mon, 19 Oct 2026 00:14:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792368861;
	bh=ptSEciUqOh9Yj+UTSoFmlUsn05uRlW6npRwspgA7+pQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=KXuOKhlZwxWB7pcbEGie15m1kb3tkU+4KcI4EUyo0uOynIBEeYWLiN/k4gH3Pw+4k
	 jn0ClMNn3b0gS52UV9Sy0YhrFC4YSeePZ/b0OJMRX+puEU3ZAzinvfKkofqOG+k+ke
	 hyKjnYgA0H5xlbyhnJFhrbTKqdLlqlUG9DwHvTLCkH0pB50HjrAjaZak19FXh8flr1
	 TJFMlFEkY9cIaUJ0Pwvx/MsrOvgeXG9BwKX9viw47nii/YHP4AeTgDsOJr1b9itehI
	 gGLwlvj0VPTwzbtoph+FsKWfL7C/rhobNZpCk9Sfi2yWyzi33dMhslF0BkQdtQRoIQ
	 rJ4nRQRhXbaqQ==
From: Sasha Levin <sashal@kernel.org>
To: Miguel Ojeda <ojeda@kernel.org>
Cc: Sasha Levin <sashal@kernel.org>,
	gregkh@linuxfoundation.org,
	achill@achill.org,
	akpm@linux-foundation.org,
	broonie@kernel.org,
	conor@kernel.org,
	f.fainelli@gmail.com,
	hargar@microsoft.com,
	jonathanh@nvidia.com,
	linux-kernel@vger.kernel.org,
	linux@roeck-us.net,
	lkft-triage@lists.linaro.org,
	patches@kernelci.org,
	patches@lists.linux.dev,
	pavel@nabladev.com,
	rwarsow@gmx.de,
	shuah@kernel.org,
	sr@sladewatkins.com,
	stable@vger.kernel.org,
	sudipm.mukherjee@gmail.com,
	torvalds@linux-foundation.org,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH 6.6 0000/1674] 6.6.160-rc1 review
Date: Sun, 18 Oct 2026 20:14:12 -0400
Message-ID: <2026-10-18-1-daily-reply-0001-6-6-160-rc1-review@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20261018094833.47517-1-ojeda@kernel.org>
References: <20261017160431.119607952@linuxfoundation.org> <20261018094833.47517-1-ojeda@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On Sun, 18 Oct 2026 11:48:33 +0200, Miguel Ojeda <ojeda@kernel.org> wrote:
> It looks like mainline cleans that up in the next commit which was not
> backported, so we get to see the intermediate warning here:
>
>   7b31f4daebad ("SUNRPC: rename and refactor svc_get_next_xprt()")

Thanks for the report. e3274026e2ec ("SUNRPC: move all of xprt handling
into svc_xprt_handle()") was only queued for 6.6 as a prerequisite of
c479bde671cb ("sunrpc: defer rq_argp and rq_resp free until after RCU
grace period"), and that fix does not do anything on 6.6: it protects RCU
readers in the nfsd netlink rpc_status interface, which was added in 6.7.

So instead of adding 7b31f4daebad, I dropped the whole chain from the
6.6 queue.

-- 
Thanks,
Sasha
