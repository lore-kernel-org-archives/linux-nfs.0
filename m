Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793628876;
	b=jenoJrGKDHp2PK0PvDHkVXV8t0CkvwsEe9z94nksg+n0cODJVVSF1f2rIC9PXnHckzRV
	 vkEbuhETflFzW7LAv9c4F309YAex8xtL794usy+2Q5dBNJwdLLDWK8ceYN84XDw4wO/6J
	 n4nndH1EZRpMkPE4OorVQ+tU9NTCDZTjdlCObtXbE6sM0XpiEwOiq24gaV7eO4bBxa/DI
	 0y/dIy3vqBhWKU3VKZ/MCLEUnlTKWed8Mopt7RCsGh/fPmo67MBcTmHZYZpLlVqJhAJiY
	 T9Fll1i2X3AyCo7lytuxRfDHoot0MmyzVgsBttqJ07oc/AUjulohdBGLpffFkdjqW2g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793628876;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=JAxbuZ/nMtyVx3Id0dCrZWQ+X27krEZ94KZnYOzEcYM=;
	b=F5FVRMp8p50lRvop2QV2kH+u3MDlAedMU/aPzkEN7VpBviMeUIqw/lY/fSmjoHg0lCps
	 IL6fyGld6bYNiWB8w6ou27RcTAQGdneIZbXZsnElC62O6RnDo2QuP4t5xUcW/y+kT8C1T
	 d9gmfPkfPXLXLgcNpZo7ny9CWzmW4V3Qrl3RIW7UXrB120QDjjudFSLx4VfG4dXFMqnKF
	 +S6FYC8b1aSjsACdTJgGw7PaI54iInl1bbZne/vzwN5lmvaYbAwKciGC32SkHAwGrSRqS
	 du4uqyh5dCUKRyIEW+OLDKtgvTeJEX039CaRLHzmkoRj9Y3y1ZrPrl1R9vqivH/btrA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="GfSE/mUD";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8F2FA606A9BF;
	Mon,  2 Nov 2026 14:14:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GfSE/mUD
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6FCE51F00A18;
	Mon,  2 Nov 2026 14:14:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793628876;
	bh=JAxbuZ/nMtyVx3Id0dCrZWQ+X27krEZ94KZnYOzEcYM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=GfSE/mUDP2LBawMieQFlGlmhnw3DgxebhTlO7jWmZCZMSiUJpaXld9q8wTIku9ubT
	 EwMWjvNCL8gly4SGmWHYqkQGMFMv35XzqygOEoWn6ZqqmHm5RrlCbIoNjEPftjKMow
	 1jqKuS1pDCOUuQ7YnI9Mpph/XYH4G/0jpb2X1YFPs/uC1vxiKTFq39KEigvxcgW17M
	 s3Zid1deDMZ/dHkLa9Mqu1EhRltW8jkn6Unr/IMAG/ddJfZCOtmDWFkCrkhYm8OOlS
	 QT3I0pBcjG78xw2Y0iqWGZCCm+oTCVp7i5x2v8TurTmb2Rsd/W09wdiXG3OCPN7vZu
	 7w2Z4aUYwKW0A==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	Haruka Kuze <harukak@zohomail.eu>
Cc: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: don't access freed memory when cannot grant a write delegation
Date: Mon,  2 Nov 2026 09:14:26 -0500
Message-ID: <179362885856.3023377.13235486966347359157.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20261101212135.1231222-1-harukak@zohomail.eu>
References: <20261101212135.1231222-1-harukak@zohomail.eu>
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

On Mon, 02 Nov 2026 06:21:35 +0900, Haruka Kuze wrote:
> nfs4_open_delegation() hashes the delegation before the call to
> nfsd4_add_rdaccess_to_wrdeleg() and nfs4_delegation_stat(), both of which
> can sleep, and it calls destroy_delegation() from the error path after
> dropping the caller's reference.
> 
> Moreover, a DELEGRETURN from same client can unhash the delegation and
> drop the hash reference in this window, so nfs4_put_stid() frees it and
> destroy_delegation() then reads freed memory.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfsd: don't access freed memory when cannot grant a write delegation
      commit: 2d3259f652bb0f1d137ccabecac6763da05064ec

--
Chuck Lever

