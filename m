Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8269B40A93E
	for <linux-nfs@vger.kernel.org>; Sun, 18 Oct 2026 17:47:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792345645; cv=none; b=BTh8XABJ7u4cR5V/RYuW8+Zsl7PoBuz84UeCgHNeHzncqc1iMBigIicExLxhMunvb0pPZ8O9j1TCz4iVzqYhArCF2mT9pk15iLdHXwZNv6nZdS86q0xw7gUKAaWVzrak+nO6h98XCbit5DSdRPokTPKeafl+YWMkJiyOyhApREY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792345645; c=relaxed/simple;
	bh=KQGvNDmpZgQdAi9iTEBzCM8yUKZ6HEfTrzIc8DfMX08=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=Wxw66gNj7R7gi9iYEQYoJAFjnoEFxtx0I5pTd2l5Sy7Hi5tND8dtRJse9lgtDQKL8dI+Qm2C3Ug4YMRj9+uez0HWIZS/r7Z4ZTjtPD3U7cgFaRXjpOb2nRyvq3DCBnRE70j601PYAYVS2ltgb8ntARJQ6iG+q4onAKP2ds68KqQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Xvp1L8UB; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Xvp1L8UB"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 591581F000C5;
	Sun, 18 Oct 2026 17:47:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792345643;
	bh=fsDYzNlJTjk7An950ACgs6r7S95dyvCKvzejzrWXnlE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Xvp1L8UBQQYsPmtQFrQub9XAbqf9iDcVQ+qyKH5+p7SFyZs1l8uTScA/1lA/AHsDe
	 /3Kopk3QpcxV2WchBztW/d9Opf5XxbbgkjROYpNLLCxZIpXTGfN2piULxAdppf9UDR
	 jyya202bY54VvLq3yylAdy81XwP32gxuy1TuWsrFL5IIX8s7utOyzQcuKwZ7V0NA8g
	 xy6+mQQqJxUPbT+tgxfVMg/iyFw4PuitiB3ri5EcPcJgzommE9FpcQWzXljFNLEJ2+
	 /GR7UTb8nd8y1Pve7xgBlDO+ebUiQDiT58yva/kufBfQ1pjV/dZSdf2tQJC+fpzVzP
	 DSXayftAfhoHA==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>,
	Jens Axboe <axboe@kernel.dk>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org
Subject: Re: [PATCH v4 00/10] NFSD: keep direct-mode I/O out of the page cache
Date: Sun, 18 Oct 2026 13:47:18 -0400
Message-ID: <179234561005.678493.856092392865379039.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20261015233309.42999-1-snitzer@kernel.org>
References: <20261015233309.42999-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Thu, 15 Oct 2026 19:32:59 -0400, Mike Snitzer wrote:
> This series refines the heuristics NFSD_IO_DIRECT already uses, mostly
> on the WRITE path and in one corner of the READ path: the io_cache_write
> and io_cache_read modes where an aligned request goes to the filesystem
> as O_DIRECT, with DONTCACHE for the parts a misaligned WRITE cannot issue
> directly.
> 
> It does not knowingly undercut anything the existing upstream code is
> built on.  An aligned WRITE is still one O_DIRECT write and an aligned
> READ is still one O_DIRECT read.  A misaligned WRITE is still split into
> a direct middle and buffered ends, and by default those ends are still
> DONTCACHE where the filesystem supports it.  io_cache_read and
> io_cache_write mean what they did, and nothing new is asked of the
> filesystem.  What changes is where the split is cut and when it is worth
> making, which READs are worth expanding, how often a synchronous WRITE
> is persisted, and what happens to the page two misaligned WRITEs share.
> 
> [...]

Applied to nfsd-testing, thanks!

[01/10] NFSD: cut a misaligned direct-mode WRITE at page boundaries
        commit: 80728157d1bd1bfba745ead39a0459622d1f5017
[02/10] NFSD: mark the direct middle of a split WRITE IOCB_DONTCACHE as well
        commit: c5d5ac48860343d7741ceb5c9024509b4aa7e2ad
[03/10] NFSD: only split a direct-mode WRITE for a worthwhile direct middle
        commit: fcd8823db80e218372d9c5ec6bc207e915ea4863
[04/10] NFSD: add direct_misaligned_dontcache debugfs knob
        commit: b99724228837563893326517a589565e0fbcf45b
[05/10] NFSD: do not use direct I/O for a READ smaller than its alignment
        commit: dae8320b4dc640d9ee99b1cd7f2e5da910828982
[06/10] NFSD: persist a synchronous direct-mode WRITE once, after all of its segments
        commit: b4e06bef38843c8b909d0b4317dfaaf87dba6d72

--
Chuck Lever

