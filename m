Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792940363;
	b=ppghqDW+1y0o3JRZR89DoB1cMv4JZtcscrz5Pxg5hJ9daa6Lm+WA+88OQSfRveX2VpLx
	 Xmc/SZ75BeRxfF/AMA2/JyAmEnls3OcZB+kCpnChtrTwxpaBC7FTc6YPYsjf+muKcvVpG
	 TUZjO146uXPwDVCtmAUgqRJy4JNt0qbJXmf5SJmB/v3LYOCEtRh9pFr9nYPZGWQTfyBDL
	 GJ9SHSL+QtrVoK0BL6tG7ebXjO4+7BoXjJQAZKGrX3biOW9n98RxsWBrT8m8yx4aJlKJa
	 9sHGYlSIGRKW/YNhbmPCvhJoYGRPnptqnoTIVukrVvpegTuIN/DyuFTYmDdMr89/8ZA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792940363;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=BsoLW6CkCRX5iCjzQsw1HbyRGsIpupAhBj6yUe3KgDw=;
	b=AKKAh1PdV/e1LiG4eMjiA/TgliD43Hq6/HhBnnvhBx2VIv0XmNpb8peXW+Lb+Xg8ejR8
	 5eMql2iBeQ27cx4fgBRI56Zo9kUrXlOKwnbxZ/PZKlkMe7LWa3KnkpACCtbv17HocP0Zt
	 WKOZgERXUfZU7b1a+0aW4KQBLrTgWk6ejC5lcofBLXHZytrTC9NotUG2mKdHg8UVH/zIz
	 wSXLDZleu/75jFgUJyg1i9O9kxG0dLSNfT0slPlrMO06vsDJWKjB/zDw9mr3p8Kshbdmc
	 aksnpT1cQc5yJj11wV74nNXYOS5K+IvIM+px043i1bIf/Xf0dsun8w2/87IM3LR6nQA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oYvxjhEA;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 277B0606A31A
	for <linux-nfs@vger.kernel.org>; Sun, 25 Oct 2026 14:59:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oYvxjhEA
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 157FF1F01825;
	Sun, 25 Oct 2026 14:59:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792940362;
	bh=BsoLW6CkCRX5iCjzQsw1HbyRGsIpupAhBj6yUe3KgDw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=oYvxjhEAnDtPJ57nzWvSu15C2SqfN0St8CIK/2iFO6ATdAd2fiY9v9SKdY7/UZ8l1
	 5DoNSBzOeC8dUWgxqTXUy/zAhJyefKr3jjaO2QhY4QqjuEsITULCxSewl32BP2P2uP
	 1TXBt6XYfxDJdwooW9RlFXdsa3AiDPrf3CMTcIOpMJaap9iNIA67VF8nUCQq4Qws8b
	 0EbRr6JVna3qMUnV/ZfniOSqKc41xHyQspxIVI5rLavnOqxtUJQWssoQiawIFYji2i
	 kAPPvLwrf16pG3zAX2lxfmDOxNyFxIDLpwQbrtjXEYiwxkRHTN7UoTS8r9Es5tmLqe
	 J4quTWRk0okIQ==
From: Chuck Lever <cel@kernel.org>
To: jlayton@kernel.org,
	Jakub Klus <jklus@redhat.com>
Cc: neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: fix delayed cache cleanup in write_flush
Date: Sun, 25 Oct 2026 10:59:18 -0400
Message-ID: <179294034526.680410.15627456302829977609.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20261023132821.3273867-1-jklus@redhat.com>
References: <20261023132821.3273867-1-jklus@redhat.com>
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

On Fri, 23 Oct 2026 15:28:21 +0200, Jakub Klus wrote:
> When writing to the cache flush control file, write_flush() advances
> cd->flush_time so newly added entries aren't prematurely invalidated.
> 
> However, write_flush() was also assigning this future timestamp to
> cd->nextcheck. When cache_clean() runs, it sees that cd->nextcheck is
> in the future and skips cleaning the cache buckets. Rapid flushes (such
> as running `exportfs -ua` followed by `exportfs -r`, which can happen
> during systemctl restart nfs-server on RHEL) push cd->nextcheck
> further out, leaving old tombstone entries stuck in RAM.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] SUNRPC: fix delayed cache cleanup in write_flush
      commit: fa5ce71d54eee315c5cdc95ca85bb1eae5336d4e

--
Chuck Lever

