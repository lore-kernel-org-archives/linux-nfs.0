Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792583348;
	b=ZtUeXkM/mOSXMGj5IRZ3itWqIOm7ISr2MGPvFLdyGNtYb+9dPCHGx3EemwJQmE6PIGM2
	 UNuza+RX7UmRQDTUTndcAQA0DLYF79K0xwjFEsDEjqK+TnAGS4o03DLM6afe6VNm0Gpss
	 J+iGOHVPoWz0GkI2NfrlpqNTxmBcgqRWSwJykaJskgnEDGplKqpDqi8+btKHulpdQ1MAU
	 Te8hOlmEde5x1dIjJCVg2ChIaWNt8DzV5F3PnpP6QRqTTuWrRgHBRaXGYagGUMrUjJF4p
	 pQjbNOCvSvxCuTI0+Jj/vxOlleJ9TNaIoypqdnvCjgLy6Xd6HH2thGaRvWQV3iRaTEw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792583348;
	h=Received:DKIM-Signature:From:To:Cc:In-Reply-To:References:Subject:
	 Message-Id:Date:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=dlLrJtFxJ/GpwFQraeE8og/Mz0Pa3MlpGavSBpIeY7U=;
	b=pBhpV5mBY6dBv47by6qktgu431IP1WxVadRJJBUewputIRxn/FCJKxF2Ei87So4xNuRR
	 ZgoG61vVOiYGFdZnK5KJxQQzGM458YSZTZSq0uDoyyq0UJ8WsjP0GCxxHXVMYxhANplFQ
	 M0SSH9ghNvwBi7LJyjKGAsShDvuxwRarovfQdhL/0Qx5Cqey9FXuV5r665ViQ8IsME/4K
	 qSMu+JKzPlvEF6cAINJa9/crWOtnZpibP9kVo2IkrnxH4CuTErYnMkc8a+oOJTwzSvqP5
	 J4v93c30LR5cKDYqgX18+yaia4p7E8A4g0LTgLeQlF1TT/7O8T5e5Pc5csQ7852tF1A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GktJL47x;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BF35160A260A;
	Wed, 21 Oct 2026 11:49:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GktJL47x
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 33F601F000CC;
	Wed, 21 Oct 2026 11:49:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792583347;
	bh=dlLrJtFxJ/GpwFQraeE8og/Mz0Pa3MlpGavSBpIeY7U=;
	h=From:To:Cc:In-Reply-To:References:Subject:Date;
	b=GktJL47xgyfD31pXaCGC+JKi2Ubx3e4kpB1pRHiKLli8ugf3OHUsK9L6Ma2TQs60d
	 0R8lr0xItaOYAQzqjSMYdjh3F7xeMPDtIf51hp610LW8EckQtZyUiH63fGoHEDhAio
	 yyuQcks4Qbu0tCmd3FmEg5fpjd6u7Dr4N7frpiVqb9yDkYKrZieAGzkFbbRbYz6IV4
	 ZV/p0a13K5jhlItr/2r+almZh6LRGTj+f4uFZg2fSJLA49PaHFI8f/qcPC5ZkFRZ+x
	 hAeTmY8Rr1Kru+1137OMCdhSKALdUE75/JxfpNmp5w7dyKIk3JVIu1UOIihfxYMwNd
	 nYdLuhY4h6Vbg==
From: Christian Brauner <brauner@kernel.org>
To: Danny@lightningiq.io, Al Viro <viro@zeniv.linux.org.uk>, 
 Amir Goldstein <amir73il@gmail.com>, Jeff Layton <jlayton@kernel.org>, 
 Chuck Lever <cel@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org, 
 stable@vger.kernel.org, Danny Pidutti <danny_pidutti@hotmail.com>, 
 Danny Pidutti <danny@lightningiq.io>, 
 Benjamin Coddington <bcodding@hammerspace.com>
In-Reply-To: <20261008140903.2784-1-cel@kernel.org>
References: <20261008140903.2784-1-cel@kernel.org>
Subject: Re: [PATCH v2] exportfs: Release the get_name() directory file
 synchronously
Message-Id: <20261021-tabelle-akzeptabel-atheismus-b17a3f71f799@brauner>
Date: Wed, 21 Oct 2026 13:49:01 +0200
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
Content-Transfer-Encoding: 7bit
X-Mailer: b4 0.17-dev-3d1b8
X-Developer-Signature: v=1; a=openpgp-sha256; l=897; i=brauner@kernel.org;
 h=from:subject:message-id; bh=YCYD8K5tz52OlKoV4PEmzLPuUZqoHDnahLMQJ6GRvEc=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWTdWLb+d0S02/a7Rd21RjG1d26tKzyufk59yr4v1bM//
 0ta98J+QUcpC4MYF4OsmCKLQ7tJuNxynorNRpkaMHNYmUCGMHBxCsBEinYz/C8WWul56XATS/IT
 u8Ln5f/zzpfe2PzE0MzfavOpmR4yMYkM/yw2e9o+inoyTSZnfr/Ze9Zp6jnf6zd+03M78c+GzSh
 9JQMA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

On Thu, 08 Oct 2026 10:09:03 -0400, Chuck Lever wrote:
> exportfs: Release the get_name() directory file synchronously

Applied to the vfs.fixes branch of the vfs/vfs.git tree.
Patches in the vfs.fixes branch should appear in linux-next soon.

Please report any outstanding bugs that were missed during review in a
new review to the original patch series allowing us to drop it.

It's encouraged to provide Acked-bys and Reviewed-bys even though the
patch has now been applied. If possible patch trailers will be updated.

Note that commit hashes shown below are subject to change due to rebase,
trailer updates or similar. If in doubt, please check the listed branch.

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/vfs/vfs.git
branch: vfs.fixes

[1/1] exportfs: Release the get_name() directory file synchronously
      https://git.kernel.org/vfs/vfs/c/9cd8c2a5bbaf

