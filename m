Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 2A41445041C;
	Thu,  8 Oct 2026 22:58:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.140.110.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791500326; cv=none; b=g+siSr3RWkg0L/bbZL8AMtFh8RyaYKweRqbP9PXJbaZcagRaP5yO2+m5Cpy2EO6AfTKBYTsf993BGv+L4v+geDx6RteeGjXS/wXqkMCcH772Ojl62EssuKqgw51FcdJPkX9XUJkOE0lwTiT5eHKcY4h/oNY6lb33CQ1joNKygG4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791500326; c=relaxed/simple;
	bh=dfD+bJF9h7dLTRCLt8lHJBwiu1mQ2/5+5VLsZj+oO7Y=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=A1/RZeMT2pKyKH9qiyxM0Pj9ZOf2TxQ6LWLePrOC+lpOq/gon0kQBJpX2WoqDelNu7a8RFWUjbsUJZTFGgw7SbbXbJB44+vofd1ZnIyPJRbqVSGOAVU2rgLTAbzx6xrCplOQV5zfFhLbvGztaNCwBpnTrtq9eiy+ExJ4APwmNng=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arm.com; spf=pass smtp.mailfrom=arm.com; dkim=pass (1024-bit key) header.d=arm.com header.i=@arm.com header.b=VKM+cnEw; arc=none smtp.client-ip=217.140.110.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arm.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=arm.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=arm.com header.i=@arm.com header.b="VKM+cnEw"
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 14C941692;
	Thu,  8 Oct 2026 15:58:41 -0700 (PDT)
Received: from e132076.cambridge.arm.com (e132076.arm.com [10.2.197.107])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id CE7013F66F;
	Thu,  8 Oct 2026 15:58:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=arm.com; s=foss;
	t=1791500324; bh=dfD+bJF9h7dLTRCLt8lHJBwiu1mQ2/5+5VLsZj+oO7Y=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=VKM+cnEw6A5VPtIxfkjBJ57FpyKUJavXooSEDKXKjTLBZVNB4cqE65t76/E3uejpR
	 R54GdldP3piNy5/ARTwtg1Ht+JI1IfRD2yZla88E3qS1NSK5GYGzq+pJczAg75MCEx
	 UCPDpIiXt+BDS+PW9LP1sDJzUjbfM3Ag7F8RF7F0=
From: J Louis Kaplan <Louis.Kaplan@arm.com>
To: cel@kernel.org,
	dai.ngo@oracle.com,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	tom@talpey.com
Cc: anna@kernel.org,
	jgg@ziepe.ca,
	leon@kernel.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	trondmy@kernel.org
Subject: Re: [RFC PATCH 6/6] sunrpc: Allocate svc request pages from large folios
Date: Thu,  8 Oct 2026 23:58:33 +0100
Message-ID: <20261008225833.682794-1-Louis.Kaplan@arm.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <d189ba0e-6215-433e-b27e-859502db67e5@app.fastmail.com>
References: <d189ba0e-6215-433e-b27e-859502db67e5@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

> Given past experience with contention in the page free path, IMO
> this one needs careful macro and micro benchmarking.

Makes sense to me after reading through the links you posted in the
other reply.

> I wonder if this change should get merged first instead of last.
> It's probably going to have broad impact and high risk, and will
> need testing across all hardware platforms and on large- and small-
> memory configurations.

Happy to do that. Should I consider a separate single-commit submission
for this change?
