Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792940381;
	b=q/wLgci+V2wib6sDcKfJJPjgiecAM9Nlfx7xtrh+/WlL1vR1Ja7/F1UrAJViEDVjxvLy
	 uLysxh/PkhCnHgdCpWdHqj7kSgUV7POR4t0Y0tZoSka8aY6nGT3PPKvF/uwTcDCnlm3xj
	 K64+16NCkwZnT1wOG2l3HDhLchh+q6zBOiy8uaqfiYQaPxGBelWBd7F16xpzjGylC3lEZ
	 EfiSK/1/IjK43xQc4A1oeXcAQJf+CRFMENqTLLOjC7ixICDc2CTo4uYlbpgFajCSsaKgq
	 5T5fI6fZ7QAIP2H3eADnubhXDGxtYx9e12LriQxlu5WBDfiYoCpExBJpL/40y/BVL/A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792940381;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=ypAazgUbAvcxzmZkxRES4uqcUMkrnn//bRJm+xkJQNQ=;
	b=M4WVxAEAw//URSbaZMBmz5BYZUTGefcnXZVr2TZfXa3u5U+B50UJGD/pMrOswqvyOUsb
	 RkxWkjb8XayVslEJDlRKa0hFB7Dj04c+q9r+erGUffx5R0tNESu3uLTUx5qASq13TCrLo
	 amkokrHzHa27Y82Zz/+LEgaZM388Z6eXLZenMKrv21mXiTnUQbcnd62BKTwX4MqbeXPP2
	 f3c3zTQC2KMU09BJzClerKKoABHy6cLrH9Z8kBmkz4Iwo+1C/djhgDHrSIa8kyeIF8+JR
	 cqfVGpluWYftlVy8FjvFTaDWKhpgytCscc0wKktuJ7ACxQoClLhWS+CfpErdKKKjcGw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GjcPZQK5;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C7126606A31A;
	Sun, 25 Oct 2026 14:59:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GjcPZQK5
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 30F851F01825;
	Sun, 25 Oct 2026 14:59:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792940380;
	bh=ypAazgUbAvcxzmZkxRES4uqcUMkrnn//bRJm+xkJQNQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=GjcPZQK5iFURP6dUTzxcQVaYijWU2eWa1KT+DK3eUv/g/RyN5lMD431tjUXYA/Pih
	 ylmqKCA2WjGbgXyrlDjat63QU3ZBE+Bf1rbZhowUGRXZWhffTzFaV2Vpf/A6sRMeKY
	 ZDCXtLFsDGPFYfL+9yzKajcL8wRlQAN3TwcxAwRDy95EUgxZcWd8mIvQ6Jcqtgh7E1
	 3FOpGqXpaM6j8nruSkESHqLyv/qvEbtxMxri2V8ctfEOe0csR1+xOmE/ZbeKy1Eyi6
	 a/i5YgfoQcCA6qJ4fzZFUz8X4tJnaC2mnBAFx5d9//rR0TJEvQbXar7rzqNKFLRwoH
	 IHrUeLBVXHnHQ==
From: Chuck Lever <cel@kernel.org>
To: Mike Snitzer <snitzer@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>,
	Jens Axboe <axboe@kernel.dk>,
	"Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH cel/nfsd-testing replacement] NFSD: cut a misaligned direct-mode WRITE at folio boundaries
Date: Sun, 25 Oct 2026 10:59:36 -0400
Message-ID: <179294034533.680410.17193539426864107681.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <at0DFod8CcUfus2S@kernel.org>
References: <at0DFod8CcUfus2S@kernel.org>
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

On Sat, 24 Oct 2026 15:12:22 -0400, Mike Snitzer wrote:
> nfsd_write_dio_iters_init() splits a misaligned direct-mode WRITE into a
> direct middle and buffered ends.  Then as little of the WRITE as
> possible goes through the page cache.  That works only if direct and
> buffered I/O never meet inside a folio.  The direct middle invalidates
> the page cache over its range.  So a middle that starts or stops inside
> the folio of a buffered end drops that folio.  Then the second of the
> two neighbouring WRITEs reads it back from the device.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] NFSD: cut a misaligned direct-mode WRITE at folio boundaries
      commit: cc9bb083d84fd52259476346a852a1e0ef2419db

--
Chuck Lever

