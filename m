Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792610411;
	b=gHFfwFhvN1ubgD1u3a0yYrJ7kNJumux+JPr6pCmN9eql3wzg5FgSN96RRSbaVrKvAEzO
	 TkABJbS/+105XaWjxidiXs9qYVb5VLQmhaDdSh483axRE5v6dvbSRPgzX3DCRnURfXM6P
	 JaZXdn0lxnalnhUCUZUCe/w9t7eeEx9kFsbLyGAEOZugqh94lQ95xB3Hnn6/ieHrqRXPv
	 0uTx0UyGkAhKsEUFKhol6RDUGMHiFFTMS1U1Pi8XLIOk7uSOhZkPiH4/7sU+mQVAAzWYz
	 BihY6LnG2jF5i5DqpNFB716ucdRdbJm5DrLGI+SxrbA1+uqn9d6J1Zz1YqBP3hHwHnQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792610411;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=N55gIs/itUQnf0q8CJBUzovM0UEJlW4e387F7nHqjT8=;
	b=rqg6t+UAr1/7s95fGQMsQ9oTCTFnPlXLJFYxT9oNKr4RiH8CyNGkwkhCE5dYdHKC9Slo
	 K9BQhL3c/IMLn3pF4EnBlTXhsAKK52+wiqSOJD4JqEhdHkwPwIjux/ebR/SG0cbO1eWNM
	 WqLXIdqPyF+Er3+Oez/93szOlbCK8yY1IwfpLJC9VPfepGfZ/IW8vRyYx5LCf0KmmfLew
	 VAE3Mvg6eDhBe9tiJ9BFPwSp4Pw7ozy09/tUcN3G/6PGxqyXZMFsuk7slTOEJvgPunYdd
	 IF0GWnfxC8Et5BmL1e8QFfqQv2gIDEtOlYpoY2PYn+kTm9zAKSqpYQj3GC3J7izS7Jw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KP27sovf;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 009CC606A31A;
	Wed, 21 Oct 2026 19:20:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KP27sovf
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 34A5A1F000C1;
	Wed, 21 Oct 2026 19:20:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792610410;
	bh=N55gIs/itUQnf0q8CJBUzovM0UEJlW4e387F7nHqjT8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=KP27sovf3epPRHQdX3YhqrM0vdEeOuHUWf4x1+ZsE6aGki0XudEx5CF7Qt5W4C2W7
	 pvdsrdcvTeUnFSucqq0CQDh9xHhntQw54gY8yXVMOdvbPcWY5VuDHalhUlqRQD6dlM
	 uGRa6ggJ5nPq6V+1onVxAjt8s4LFqh7VpiXrWiTn86i2NC2au0SBhLyY219vzGsFpz
	 /DlXy1/2lkH+z/PJVp2gmG4BhdHNGOSE52K6/i/O57tyNnQVpDDEqOHrmegRf6Yq++
	 JAUkZIdbO/kG/LwN4JjbXwXR+LXOtMYtPIasXOh8JNRTuN8ImDO7XFb35Uk0sCB4f5
	 uYjlEynk5jxnQ==
From: Chuck Lever <cel@kernel.org>
To: Donald Hunter <donald.hunter@gmail.com>,
	Jakub Kicinski <kuba@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Shuah Khan <shuah@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kselftest@vger.kernel.org
Subject: Re: [PATCH v2] nfsd: add NFSD_CMD_FILEHANDLE_GET for root filehandle lookup
Date: Wed, 21 Oct 2026 15:20:06 -0400
Message-ID: <179261039943.1716542.9468280490238427804.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20261021-nfsd-filehandle-get-v2-1-bd7fc8b1b783@kernel.org>
References: <20261021-nfsd-filehandle-get-v2-1-bd7fc8b1b783@kernel.org>
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

On Wed, 21 Oct 2026 07:44:13 -0400, Jeff Layton wrote:
> rpc.mountd still fetches export root filehandles via the
> /proc/fs/nfsd/filehandle transaction interface to satisfy v2/3 MNT
> requests.
> 
> Add a netlink equivalent:
> 
> FILEHANDLE_GET takes domain, path and maxsize and replies with the
> composed handle, like write_filehandle(). Unlike /proc, which silently
> clamps maxsize to NFS3_FHSIZE, maxsize outside [NFS_FHSIZE, NFS3_FHSIZE]
> is rejected with -ERANGE. Include a kselftest covering validation and
> byte-parity with the /proc interface.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfsd: add NFSD_CMD_FILEHANDLE_GET for root filehandle lookup
      commit: c9d646d1dd8b2fd96548d3f22fc709a84dc6f3e0

--
Chuck Lever

