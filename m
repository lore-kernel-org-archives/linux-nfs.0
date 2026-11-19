Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795085545;
	b=eLoxoArUReXscnqoPJg50p3/oGEe16/Ka/v8mwu4XBRUR9VdJcjAevWlziBQJmqrp3KH
	 okF02HNGnsR0GICfYyBNs0PVJwfbsrXaZWg8RBSQenAVytmxEXInS85bh7Yf33cXwsZiH
	 m4D2zX2b96cDwPhuPGEMSbzn0d3LYuBCfBrLqa7CH1qbTX11FPOsl7FUGKMAERieqphdS
	 N2x3BuRirhbUngGN0584++VM7B6hCZFfiVJy7YEltcn/fLa/RYjYTmmplvdJbjHmUGbLS
	 kgNYGlcfD5SwuBuGyea/SpTsAiwYRdmT6b+7GIBzpN/HhTeFfDJX6wrFmipLLPwe0Ig==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795085545;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=OqF5vrBptKgxZu2EMdBPRPy0tap7A0RPQIqpEhJDaEM=;
	b=b/jG+yf6MV9ljJ5e2mxcQeE4nphz7pvVtWK6Mo3CcvaTEW4zsDkR4V1SMgpmt3EHYOX3
	 KeW9VXFeiFZH6N1s3hc2WutqvodC8CqHjzi9o9lqIBDy67e/x+vXSuuiLTr7JLAaYfMKQ
	 QQGf5JTVUmQ7W86Gm29RS2+9Whc+oBsmrkLa9HuVVpXT4t16M+DpmVxeUuAJ8s8SMiFvn
	 85X58qlbUHAdmhE07d8bEgq/v0oY3INU68arR5aTO/Pc3+xRwl+cKFcOoGMrZQpTF7pXk
	 1bHfelwaYV1dCMKF9Y2b63KSzZ1Jll76x2ICupTYiGs/nEtHvFTV0DUjGE0TlFQkGuA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RYMK2ArS;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E57C7606A326;
	Thu, 19 Nov 2026 10:52:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RYMK2ArS
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 781301F000C5;
	Thu, 19 Nov 2026 10:52:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795085544;
	bh=OqF5vrBptKgxZu2EMdBPRPy0tap7A0RPQIqpEhJDaEM=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=RYMK2ArS0wRvEjQ46WpFNLoHgw4LnDLCKz2wIUutazUiPrzI6+owAo82qSsTDV3Dr
	 l9LCub57dKDF+9C//tVLZgmc30UNBwM9KAgtbRi10d+neB9INqhVWWcGOhXuisEjRy
	 QeBCb6mKXv/L0xobqoIdmuJRVGFl9Mr5gFlJzrH8JuWXzWetofpibpjwVKL8MD1pZ4
	 57htvAwZqch0lxNrL/fVKSwNrZrICeqkblyMjeuKZJ0OvkKu1hAT36PevhqD0gist3
	 Q1PF+ZFdDpVDOFUrSDetmWJpohTwxf9KCppgLWDB6krbruedHqa5l6KSgWFTXNA823
	 7Uwgj84yof9CQ==
Date: Thu, 19 Nov 2026 11:52:19 +0100
From: Christian Brauner <brauner@kernel.org>
To: Anna Schumaker <anna@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, Chuck Lever <cel@kernel.org>, 
	Jeff Layton <jlayton@kernel.org>, Amir Goldstein <amir73il@gmail.com>, stable@vger.kernel.org
Subject: Re: [PATCH 1/2] fs: reintroduce SB_I_MULTIROOT
Message-ID: <20261119-beinen-gleis-affront-8ea5d3703879@brauner>
References: <20261118-work-nfs-multiroot-v1-0-66e4458b7d32@kernel.org>
 <20261118-work-nfs-multiroot-v1-1-66e4458b7d32@kernel.org>
 <82b7c5ed-5736-48f7-8f65-e7984ea140bb@app.fastmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <82b7c5ed-5736-48f7-8f65-e7984ea140bb@app.fastmail.com>

> I assume this is going through the VFS tree?

Yeah, I got it on vfs.fixes.

> Acked-by: Anna Schumaker <anna.schumaker@hammerspace.com>

Thanks!
