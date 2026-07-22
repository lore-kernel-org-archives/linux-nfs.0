Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A4E2918871F;
	Wed, 22 Jul 2026 21:32:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784755931; cv=none; b=M/FQuthqbOeqzgGqqxcTGxz4etsEf0xb3CUD4dbUXzC4zd49/psPrzYt+Xb66zHEr06iQrK8xuvImIruoZY+QANEJK2xvy3vg4rWgZW4ETWhnJBEcIyh0kJZ/ca9DjjEbcQksBsneyKnjXPy+A8t2U6BSNiahYvYUO7OvNWVt60=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784755931; c=relaxed/simple;
	bh=9ehj8zTjMtP8H9SI9ORAQWC1KqlCHR5I8/nDoooQ5mk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=U7CfePEaCIAra0/NQ/dB2M1efbjj6nTrc6JHDPO6BUgmJweqsFGTBNakDyQdC2g8UMgQc1bMhh6tXyP3FQng2fuhpa9hRgR5OI04p/aGx1IP2Rrf39UY/j2QGj3a5E2cH0/mwQk8eoqt2aOBFyR89a9M+8z4ZV6BggjREvRAVr0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=PH91BIg1; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="PH91BIg1"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 32B351F000E9;
	Wed, 22 Jul 2026 21:32:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784755930;
	bh=9XLB7AYeci+8TrxqPT6+IOsMiKzoTZLtKnwX7jqlGN4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=PH91BIg1QR6ELplwY+wSOquP4RwVanVmBQWWzSd7P+YqasAq8xZO54Pxsh+41XgrC
	 OUI22U4Ohe4zjPg1QgA7vG2yYBlKxm8ciGW/oPCdMCa7Ap6crqxZVk32ZcNUHNLzK1
	 1vbkm41psGvhnnKVcCd7gyg2FZWfIfWEPj8CZUKhKnDFE4VUxFnG2FYLw6IrTPp/2B
	 aexWdQ6UC7A3yRVXVhjlhVW8qEEFXxmAs82TLezmQNPVoHqKBYqwZue/P4VFp/1DaO
	 +DSiIcsPI2F36leG2kyPJi0Y74KBbL65aS5woFAZthn4de4lkHF8wEPyJ7j4cm3eEN
	 S1heg7ZJs7p9w==
From: Chuck Lever <cel@kernel.org>
To: jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	Ameer Hamza <ameer.hamza@truenas.com>
Cc: trondmy@kernel.org,
	anna@kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	frederic@kernel.org,
	alexander.motin@truenas.com,
	caleb.stjohn@truenas.com
Subject: Re: [PATCH] SUNRPC: Restore NUMA_NO_NODE for svc thread allocations in global mode
Date: Wed, 22 Jul 2026 17:32:05 -0400
Message-ID: <178475581093.3096927.18170922544327617159.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260722182012.2063936-1-ameer.hamza@truenas.com>
References: <20260722182012.2063936-1-ameer.hamza@truenas.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Wed, 22 Jul 2026 23:20:11 +0500, Ameer Hamza wrote:
> Commit d57e43b72bf2 ("SUNRPC: Update svcxdr_init_decode() to call
> xdr_set_scratch_folio()") changed svc_pool_map_get_node() to return
> numa_mem_id() instead of NUMA_NO_NODE, because __folio_alloc_node()
> cannot accept NUMA_NO_NODE. That return value is not equivalent: it
> is evaluated in the context of the task creating the nfsd threads,
> once per thread created, and it is passed to kthread_create_on_node()
> and to the per-thread allocations in svc_prepare_thread().
> 
> [...]

Applied to nfsd-testing, thanks!

nfsd-testing has been re-ordered so this patch is positioned before
Jeff's restructuring of svc pools.

[1/1] SUNRPC: Restore NUMA_NO_NODE for svc thread allocations in global mode
      commit: ea94cbfb34c7151d79da28a8c7e4bec0290b3e27

--
Chuck Lever

