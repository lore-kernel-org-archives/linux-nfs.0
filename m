Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793783259;
	b=ytbpjFhTbJyxsgkjgL5GCRYzJ4aa7jH+mrt1gp0gp5xsGgX68/cs1d4ZfRpLaMeSIRjH
	 psVHUB52vHQBVggHAc4IuQCFwKwTtxEjXVjJloh13Y7CuYZbVTly4SaHSMz7VeMipSSwN
	 73hFPDx46vhNaWTTE849PgECDBibcY/cGboHsh0s31YzlYQi38jN984ngdUFfTL5jSqX5
	 zywrMpD78188GEP9QVnHe8V6vDE5fDl4jPibEPiyu7r5+mPTunklbTkuaAKzbI8et4XJj
	 134qCmrVRup9asRGwmAucliWBp73gliFlw7B1QNxynUkUm8YSIjl8tutsqQHQPNWPZw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793783259;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=/wtgYPMXZXp6zUY4OHNPQsnexKANsg38h6IetxV4HVw=;
	b=VJpMiwYIzeyazWnax3Q4E4PwGp28W3IEyXShFaQNGP+u0s0xzPaJZZkjtanHNcQABTo7
	 ahaSqbpqeBi/v7+PmnlAvBTlNotdwjS23pY3YE/6Ersjh3e2u6lpMY4G+dOPtsQ3tIU+x
	 mE4CyGQW1OKNOuOBfTMz8kaL0knUAtTnwTAsoktO4RPMeS1w/Nn7mPrGK1YcYumhOEaTa
	 UQ1DjXNrsbcCyH7g6LxGwG2cfTZbjqfnHT3uohRRp5GyjdCS6M+sRyHLUUlyVVMOmNwC9
	 a+PLVeLY/Si94MNwoIgR90CeEkKUOjU0uqSI+OVZW2oMCyrZ2dRuPVJ395evT1+Czrw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=G2dP9jW8;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 62613606A326;
	Wed,  4 Nov 2026 09:07:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=G2dP9jW8
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BF4D31F000C1;
	Wed,  4 Nov 2026 09:07:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793783259;
	bh=/wtgYPMXZXp6zUY4OHNPQsnexKANsg38h6IetxV4HVw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=G2dP9jW8XN9fwXCrGnjt6PUjB94dMWk22P5oRER6/dYD3zXvvuzlKIrKLzPlfnYCC
	 qOcuBRM28rAzRCFJukigtV7OTBeLQcFImEoDeS3a5YMb8bob19T1P9EA2nb4kKdQ0v
	 WWHlHf/gkNd+l4NpDAM32yRLg64mUtajz2yXneujyfLyPRx2qQuV3v8Ma7iE4TggCu
	 hw4qQHy1lBXXlmkThiO3lpG/9nEypbtPLVCAmyrzUS9uiZ4azhCT29uKjwonTiORlb
	 ytNHnHqtR1POQ5gnAFwbKO4J0o16idIKO1z9oen/GYwHDy+SyUWj9m3HYs3YIT9dyZ
	 mamCDVhtpL9BA==
Date: Wed, 4 Nov 2026 09:07:25 +0000
From: "Lorenzo Stoakes (ARM)" <ljs@kernel.org>
To: Huan Nguyen <nhuhuan@google.com>
Cc: tglx@kernel.org, mingo@redhat.com, bp@alien8.de, 
	dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, akpm@linux-foundation.org, 
	david@kernel.org, Liam.Howlett@oracle.com, vbabka@kernel.org, rppt@kernel.org, 
	surenb@google.com, mhocko@suse.com, trondmy@kernel.org, anna@kernel.org, 
	ziy@nvidia.com, matthew.brost@intel.com, joshua.hahnjy@gmail.com, 
	rakie.kim@sk.com, byungchul@sk.com, gourry@gourry.net, 
	ying.huang@linux.alibaba.com, apopple@nvidia.com, rostedt@goodmis.org, mhiramat@kernel.org, 
	mathieu.desnoyers@efficios.com, jackmanb@google.com, hannes@cmpxchg.org, shivankg@amd.com, 
	rientjes@google.com, dave@stgolabs.net, nifan.cxl@gmail.com, fvdl@google.com, 
	jic23@kernel.org, rkodsara@amd.com, bharata@amd.com, sj@kernel.org, 
	weixugc@google.com, xuezhengchu@huawei.com, yiannis@zptcorp.com, 
	yiannis.nikolakop@gmail.com, dimitrios.palyvos@zptcorp.com, alirad.malek@zptcorp.com, 
	ryan.roberts@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	linux-nfs@vger.kernel.org, linux-trace-kernel@vger.kernel.org
Subject: Re: [RFC PATCH v3 0/3] mm: use non-temporal stores for demotion
Message-ID: <aur1xv84Siddlg3P@gremlin>
References: <20260730-rfc-nt-demote-v2-0-452dbe3b5073@zptcorp.com>
 <20261103223025.2482227-1-nhuhuan@google.com>
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
In-Reply-To: <20261103223025.2482227-1-nhuhuan@google.com>

Hi,

Please always send new revisions of series individually, not in-reply-to
any other email.

The easiest way of accomplishing this is to use b4 [0] (the recommended
way of sending patches to mm), otherwise format patches like this:

For a patch series, e.g. at v2:

$ git format-patch -v2 --cover-letter --thread ...

For an individual patch, e.g. at v2:

$ git format-patch -v2 HEAD~1

[0]: https://b4.docs.kernel.org/en/latest/contributor/send.html

-- 
Cheers, Lorenzo
