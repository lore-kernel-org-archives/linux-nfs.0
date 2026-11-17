Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794877390;
	b=1jMNyeBeFYlaUtuwmaQL3bgIU2/TEga80WxiOFFwxBagVd021PF5GPAV8MVW+WFDgCsy
	 JuLSezCX23CnMbSur2rpKGjQum3wciKNOOfGCY6SNg00TNIyf1eHxCzi6N4Psy0OwYY0G
	 KRCKpquMWzCiHxVipadZEu4zRRhvGe76hh3zgE4SDRKqFk7q89+LUxLYM+pMWHOBdyQTa
	 ybdHaRkuO86TfcsN8q7zECe26+Umpdah4/m5AITd6R4bt9HMGIN2DBo7zTzXFHxony4pi
	 LHyehc+LNyBSoG1DnBTiaQtKciwISNeIwcME4oQpmGMc4xpPLOlxJmPXFFiGUP01feg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794877390;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=ctl9L1NNllHU34mLpNmtS7+FcoqFTF1lEyCbVFmBBR4=;
	b=yzcYN6X4zbRGz1icSv5hNsi7/IUQowznsPA+GVh/wUwclINzS3f+4a5h4fSANO/DAl6e
	 OHLm5LLkWBhTenGJm8qxysDpVyMeq/neuSeIz8VqrLa+o52KjMt6qsn5KEo9RVPZe6pGb
	 knyEJm6dJW9q485oTDfaweKBI/527Moi0ydT605JxHIvR6kF6+hbZdZmwtOZjesc02b5s
	 fFQzIcJJNxBgZdk+h1OoHeaHUL3AKuMKx1pG4y9O6cYkTvW6bPRT9CFQbTVXzbC71GizX
	 x3/ikwhDtUfvVq1OoXbvtdsqfo1VLfnPD/5txraDvKFnpE5xgq7jo6T485KgMCmvd3Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bWcZZSeQ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 844D7606A31C;
	Tue, 17 Nov 2026 01:03:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bWcZZSeQ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8B6491F000C5;
	Tue, 17 Nov 2026 01:03:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794877390;
	bh=ctl9L1NNllHU34mLpNmtS7+FcoqFTF1lEyCbVFmBBR4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=bWcZZSeQoIn1xDQNInkelYsjjleAlodUY5FJKx/KxvqSMB/5TwFx6jZCVHTUUCwCJ
	 fw2ztixGg4AL4o9LVS/GSPRq5UnQGpGBZV7La7dx00WHLyo5Q9+c+BuVn8+6Efr+X9
	 s76YuBnRXHcHjV4L9t2qidC5sIYBlKY5DLg4XEfFgaBJrxQs/5vuYmKSJ/crBM63nN
	 uM2LeJw4MfNAHJlDjMFypFZM64HiH7btorpFYVr1XNhcm6pAroQBm8wQvGPXFTgRGH
	 RDoPayzLdtub7r25TsJNJbmlzG2awwdW3xph6Fcb2YIRTmAdmADnz0y5p2KO9adXHa
	 Ie6aISdaHHzLA==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org
Cc: Sasha Levin <sashal@kernel.org>,
	gregkh@linuxfoundation.org,
	cel@kernel.org,
	linux-nfs@vger.kernel.org,
	Kimi Security Team <bug-report@moonshot.ai>,
	Yilin Zhang <yilinzhang@moonshot.ai>,
	Bjoern Doebel <doebel@amazon.de>
Subject: Re: [PATCH 5.15] SUNRPC: Copy the deferred RPC Call from the head buffer
Date: Mon, 16 Nov 2026 20:03:00 -0500
Message-ID: <2026-11-16-2-daily-reply-0004@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20261116135551.2582117-1-doebel@amazon.de>
References: <20261116135551.2582117-1-doebel@amazon.de>
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

> svc_defer() snapshots the RPC Call for replay once a pending cache
> upcall resolves.

Queued for 6.1 and 5.15, thanks.

-- 
Thanks,
Sasha
