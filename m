Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794699348;
	b=1Wb9XrXVcsBFizCfoluSzpywGcgS5n+WOkx79mLLlcylfOAzyofhykWRc1Aeu6awI5tt
	 s0HI6BM2OJfih16WZ1cPyV9utCGxOX5htm8DjtiKDZxV455PkaOxWMypYyJIpmhjPBmFS
	 4fOD8oEdfe7s4Vcz0FAfe9ziYaaneYUopGs1pfABzZ3z/PduGrZdCi+VnvpV2huzSUT60
	 bFBBiIEBx6x2EHB8diJV1oBq4GKkGI3jBQKox/3MaxGVzducTgqeMRO8R77rCQwfVrsSG
	 TmFri4L23TFnztKD/0NqJhzV2lDhnpN3grh+AJ8mf+UCseX9tQtqvl1f7IyUaTOu1Fg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794699348;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=VIR6mXYK3ETiApKWl+z2FejP/5a8onBjeYRAKhIC2pc=;
	b=oME7icCvfLRnlNUlBjEljHrxDnBSt60jUksFlx1BlF8FevroSG5+N2kJ7DQJ/MPiDD0E
	 omQpC1x1r4Ucfyipql9Zvgl64X2brPfaCnjiYYzk8jEiIPlCKJKqDpIC3wAhIvVHLRVE1
	 xupD7Fsaul/DxjJ5w7pEedFY3HWcsAnswe2QdPw5hMSKfLnVFKjWbzJ4uOXuNT3W1/ZlF
	 nIldnw7RJ5+l1exM0ckWk084mhHwfAZhvcjI3Khzfrs5E71HsKdk77fHlrNdfjbtaLd+t
	 qddjqxXkq5EBcD6sok15QVXtV5RrReu51xRQj1ZoLT/iDspi/RKp9SYrTfIpPqhr0MA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZZQFDPr2;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id 5DCCC606A329;
	Sat, 14 Nov 2026 23:35:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZZQFDPr2
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id 42A021F000C4;
	Sat, 14 Nov 2026 23:35:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794699348;
	bh=VIR6mXYK3ETiApKWl+z2FejP/5a8onBjeYRAKhIC2pc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=ZZQFDPr2OBteoJK60ty3lgYNXS982/JqevYnayq5M2JVQt56VdJ0f7HgXeEBXp7XF
	 CYD7i9q4a6s4qq48G33GZIZ7L7NDnGKKgS+Zd7cfEUxuqFx+vjuOFx7fJkkIjLF3j7
	 BPxRY+5oqsHntFgHsq77skoWTKPkj0x48vYhVdR8SAWzHLjrkNJiwM8qHDB7G0wZNW
	 K3FzuiTooW3tl0aiWfgk/x35HLj1Fmx8h/X9zphKIrw+uzyLGMw4pFFdjyFbLxmWmq
	 7Sky8LjYCk3m7OheBofEcorLf8EV13An9NDMZNhLmq8c4R/5NoM//E+m0T9xsssCgg
	 jYU0VRyjZhqhQ==
Date: Sun, 15 Nov 2026 01:35:44 +0200
From: Jarkko Sakkinen <jarkko@kernel.org>
To: David Howells <dhowells@redhat.com>
Cc: keyrings@vger.kernel.org, linux-afs@lists.infradead.org,
	linux-cifs@vger.kernel.org, linux-integrity@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-s390@vger.kernel.org, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org, Alexander Gordeev <agordeev@linux.ibm.com>,
	Anna Schumaker <anna@kernel.org>,
	Bharath SM <bharathsm@microsoft.com>,
	Christian Borntraeger <borntraeger@linux.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Biggers <ebiggers@kernel.org>,
	Eric Dumazet <edumazet@kernel.org>,
	Heiko Carstens <hca@linux.ibm.com>,
	Jakub Kicinski <kuba@kernel.org>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	James Morris <jmorris@namei.org>,
	Marc Dionne <marc.dionne@auristor.com>,
	Mimi Zohar <zohar@linux.ibm.com>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>, Paul Moore <paul@paul-moore.com>,
	Paulo Alcantara <pc@manguebit.org>,
	Ronnie Sahlberg <ronniesahlberg@gmail.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Shyam Prasad N <sprasad@microsoft.com>,
	Simon Horman <horms@kernel.org>, Sumit Garg <sumit.garg@kernel.org>,
	Sven Schnelle <svens@linux.ibm.com>, Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Vasily Gorbik <gor@linux.ibm.com>
Subject: Re: [PATCH v6 00/13] KEYS: Sanitize the garbage collector
Message-ID: <avjwUDaXiAwNvFai@kernel.org>
References: <20261112040242.247168-1-jarkko@kernel.org>
 <avjutAro2-Q5VPvx@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <avjutAro2-Q5VPvx@kernel.org>

On Sun, Nov 15, 2026 at 01:28:56AM +0200, Jarkko Sakkinen wrote:
> On Thu, Nov 12, 2026 at 06:02:29AM +0200, Jarkko Sakkinen wrote:
> > 1. Replace key_type_dead retyping with module reference pinning so live
> >    keys and restrictions keep their backing key_type module loaded until
> >    key_gc_unused_keys() or keyring_destroy() completes.
> > 2. Process serial-tree scans and graveyard destruction in fixed 64-key
> >    chunks to a bound workqueue execution latency without hurting overall
> >    throughput for a significant amount.
> > 
> > The first part has a user-space visible effect: rmmod returns -EBUSY while
> > keys or keyring restrictions still pin the backing module.
> > 
> > Internal key caches or transport state bottlenecks are addressed by either
> > clearing their private caches on last-client teardown or splitting key
> > types into dedicated provider modules.
> 
> This passes bot+bpf-ci@kernel.org and Sashiko other than the remark
> about inline comment.
> 
> I'll update the inline comment, and make the commits available at
> -next.
> 
> I'll leave S390 fixes out as they are out-of-band. They can be
> picked from this patch set; or I can later on send a separate
> patch set.

Done: https://git.kernel.org/pub/scm/linux/kernel/git/jarkko/linux-tpmdd.git/log/?h=for-next-keys

Br, Jarkko
