Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794412985;
	b=BW6Lxyd5joCEg42BRB6Q9XMjMio1HaOEm9GkXMQSsegJQbEJAKc2I7E1uLl/FPjA0iSz
	 PkkxZ+RV9DVodq3reuaBOOrxhBzt7Lsu8Qaisp7YeWJkS/T7UkGoLfb5bjZFW2TAkQAl6
	 etB+1gMtahFNe9046xqeK7r13ixlWPibR/RNi0Jj3xiltpNz2yDiCr7tl0ZGWKvSw7Og8
	 RN1yTtG5tkT+vXzPNk8r/OERNiCaQOApOiWJraVsCJFxtSLMBKWKXSn1JdmSDAKFJwf1Y
	 Zbr3KYYxEPJJ3OrH23QD+46sBinCT6zEk9TqQOro/f4UxgnCRr/mlo9odBGSit3EtLw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794412985;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=u8QJq76jNTxwAdCXaFTbsFk9ja1zX6O34FmCTiFCsbU=;
	b=5QYoTiSxpRBBfLitc17UpOMnR62gC+BZyMEknruFp7F2/6ocJ5rbXK6Pd4JdnEeYzaG0
	 dPQEGhTFSY65Kc/AKALJgGsLJAUNzeYTXXFxpQNI/3lwQXOC95de+mVY6mvQQGwdMLrqI
	 cLBBlnjTXyGn/mD5f6ffF6RvoCq+Y33bt4AYZadoUn9b3P2ZHCQSvfjdhLFRUuB5xloqF
	 nBI5KGGwD/YVIx7iUtTcvG5nb77M8HBGP+vsw5BXtdR2Mqtdgj43+Hv1q6Jew9UnRWIXy
	 yIv6X4zXnHvITVpwJuLcPdLzwTaTS0Rb7k0ICAh3G8N+TW9iNzRvtCSkNlpEdMT2EGA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=N7WyESXE;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DA8A2606A33B;
	Wed, 11 Nov 2026 16:03:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=N7WyESXE
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 644021F00A0E;
	Wed, 11 Nov 2026 16:03:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794412985;
	bh=u8QJq76jNTxwAdCXaFTbsFk9ja1zX6O34FmCTiFCsbU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=N7WyESXExXkCJXlOhIUrNslFnScshoOCxo7NVc/57IfPncmHP/efAEFQHUgJ5Fih/
	 qnXWZIceFahXoPtg0f2V/ntKdx3r3IwhCrGYEW4OYnvWq/pIMInlfEZvKpZ4Xx9A1b
	 lXWobRCWewXN2bWol2ZS6cDZiamRRqjSF0BNGt2Z4/FeBowyhtu48cMI/JCWs+B6WP
	 v+WntnsHytTRVP9jo+UygGraQIQw8HpisOOKrjq1QyVO7rWq4wgU2/t0Aw345SCoo9
	 X8RFwq5rqrFf8KHU8Iv3HW7nFf6tBCki6VGWOXuWhrmF7mRTUovw5h0Dfm0DJWeYwv
	 pP9M1Kc40VwuQ==
From: Chuck Lever <cel@kernel.org>
To: jlayton@kernel.org,
	Zhan Xusheng <zhanxusheng1024@gmail.com>
Cc: neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	zhanxusheng@xiaomi.com
Subject: Re: [PATCH v2] nfsd: don't block on a file lease while holding the parent lock
Date: Wed, 11 Nov 2026 11:03:00 -0500
Message-ID: <179441297296.185629.5211207109560941650.b4-ty@b4>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261111074835.599584-1-zhanxusheng1024@gmail.com>
References: <20261111074835.599584-1-zhanxusheng1024@gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Wed, 11 Nov 2026 15:48:35 +0800, Zhan Xusheng wrote:
> Since commit 2a60db3525d4 ("nfsd: (almost) always open file in
> nfsd4_create_file()"), an NFSv4 OPEN with create that finds an
> existing file opens it with dentry_open() while start_creating()
> still holds the parent directory lock. The open flags lack
> O_NONBLOCK, so break_lease() in do_dentry_open() blocks. Before that
> commit the file was opened later by __nfsd_open(), which breaks
> leases with O_NONBLOCK, and the client retried on NFS4ERR_DELAY.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfsd: don't block on a file lease while holding the parent lock
      commit: 9d9a3e68a2f8a7d69d597c65cc52026456edbf6c

--
Chuck Lever <cel@kernel.org>
