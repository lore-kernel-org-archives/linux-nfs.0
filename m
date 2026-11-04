Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821722;
	b=t+ygbwg0kGu9tDESh9hFeOs7OrUzyhGYKXx4EcBDjrs/w0gH8+2+VqqvffrnOcuaKegX
	 5onHSayNhNr31xVFJdwFAmShML45XBy0JMF13sV7HaW8PUE7CYjk/ZllgPHyYqaJZRqUO
	 f9nSr+j2Z9tGHsBZQd1ZpwYpYsvwDDnO3pOIwqgsiDc78XmHfxqUKG1Bn5GfiigR1LGbj
	 0JI6L5ZlOyxFrB2ZpwLRFA5qMKQF54FpfJ53LCjTef+81YJtPzW6/ILIcSc8VqfD4TuQU
	 iU9WHBR0fnule5LLSzTA3U/0iaHl+LrFzXDWtJ7sNnPj3/w87CdZYp7s7WP5h6sleYQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821722;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=U/oQOdUnKCFzbAZN7JiZHE4Kbs0Sjb6waZ206u+YoQo=;
	b=r/Kzr05lLnXcSiGULpYI3Al2bd3mtisrODyRnzvd8b3semTm8fOD17pLLN1zelH7hD1D
	 wBNoMGqFDVtHKDDdvGq2+QRnMmk5kw09cWtJEki/GgcDF2lUrhvcudHA7Lj6oF51+gYip
	 uVj1DtmLfOUIcqYVZTP9b8wGMQGgciFX/i4+1XUF3s5NlWxVzrLVcnX5ew4X2ESfba3ff
	 MwCDtf+8KxZ9cdE9+AtnyCoS/jmgHjazkLebHAhFk9DTsCQ6Q/c8HmK7/xyodSP9cXcFy
	 VNgwh848bC2CJbNg6NCbwornzMIAF6m7DOlG2YGwE5jT45VcAsEQXUPskBHPczWSIGQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HLLJzgUo;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 975F1606B2C4;
	Wed,  4 Nov 2026 19:48:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HLLJzgUo
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 982681F00A22;
	Wed,  4 Nov 2026 19:48:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821722;
	bh=U/oQOdUnKCFzbAZN7JiZHE4Kbs0Sjb6waZ206u+YoQo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=HLLJzgUozOmi8TJ5aCw8deZ1Ua/C5lK29aqLz8M5EJjHzXCImrYuRBRWXGPg4WHBl
	 Wp+SdoNtcYHvEJJvhctHD1g+DvEmsMhd1ZMZ03FWPotQN+JYfaQ/6RZfFP/1YEAWIU
	 CPUkeKVYzdW4fBrxnDHyB1y3kApyR5zedXusZxbcapaG8yACcWOCgYk3safNxmuN8m
	 8AR1kY5XMEsNWvodSnrGK8KGmPn99/yrkFRou2nvcNswWNunRpX4sGherisGT9XG3D
	 VP47u+XG81q/G5x4xqVvg0fgir+hgfNNiubEhYw1VorLD8zZA2NxENVcc34okfVVvs
	 uFe1pWuWlhHRA==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	orkunsari <sariorkunemin@gmail.com>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/2] nfsd: fix two mount-crossing regressions from the v7.4 merge window
Date: Wed,  4 Nov 2026 14:48:34 -0500
Message-ID: <179382157232.3460048.13835850595124039928.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20261104-nfsd-cross-mnt-v1-0-5ec5fca0a553@gmail.com>
References: <20261104-nfsd-cross-mnt-v1-0-5ec5fca0a553@gmail.com>
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

On Wed, 04 Nov 2026 14:56:14 +0300, orkunsari wrote:
> Two fixes for code merged for v7.4-rc1; released kernels are not
> affected.
> 
> Patch 1 fixes the NFSv2/v3 CREATE paths, which pass the dentry returned
> by nfsd_cross_mnt() to end_creating() and so unlock the wrong directory
> when the target file has something mounted on it.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/2] nfsd: unlock the locked parent after crossing a mount in CREATE
      commit: 0e0796416999f96e4192a25ac589f57bb497176f

--
Chuck Lever

