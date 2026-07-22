Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 68C0731960A;
	Wed, 22 Jul 2026 13:06:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784725597; cv=none; b=o9oP4R2PtUbqXnhcFqi0lLYxWWCfWJD8v0ewOoOjLWAk3h2CcpJW8TePV03pTS+3Mz1epFW0MF32jDNVMgC/+YP3bIFR5ycYKXBq+RvutFiuk5eDqokGjDaSWc3cpJWdFUaHC6tIfuK14iPPPatlxIuBCXTthmSCfdk0nU31TxA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784725597; c=relaxed/simple;
	bh=w9J71KcjBFQYW/1N38JVknjcGogLRlYxpuulQBMBO5o=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=NXDdOG7TOkaJr1lcPHFCBMq2N37zBqOPliMX6NXhvVwaePYjQq+cFf1LqDc6DfmooPLsCt4mF4UoLSMfGsvfQCmE1UzPdcGx0SGI5KnBs7OBvQITjrdR+jpl34f3FcNBY6aH9S/ffmwoMLCKugqzZup7SB1qql+KE61qqfsQbUk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=lst.de; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=e69MtbyR; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="e69MtbyR"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=Content-Transfer-Encoding:
	MIME-Version:Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:In-Reply-To:References;
	bh=w9J71KcjBFQYW/1N38JVknjcGogLRlYxpuulQBMBO5o=; b=e69MtbyRHRNH+rCKPI2zWDZbP3
	bBueOpsET7/VzIvU66KYLPQOsMQ3Cse/U28q7q/kVAPImaxFh03cAGdjitzODe7N7sfrpsw4DPllQ
	90SBBoLQHDS6loLD+AU2uVdAV77YXDXTuwW9pbWqHKohtfXRQl9VT3LideQjl8MNVpzJNltAseov6
	Sad1tqlOeUw82VPcsV8vyIzfGWI8JWwrV9Xs0VIKYBgCGn2wWTn2SRvtpV3faUhCD3qD0sul2wP/f
	BgGJLp5z8yYLEioQE5egPd4Ohrjha+MaCLuWbGXgQR5Erz8FARAQrL1hGpp626P7mxijcYsgE2UnF
	pAw6xRfw==;
Received: from [2001:4bb8:2d6:3a78:eb21:714c:af4c:ee7d] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wmWeU-0000000Bpnc-2qsA;
	Wed, 22 Jul 2026 13:06:23 +0000
From: Christoph Hellwig <hch@lst.de>
To: 
Cc: baoquan.he@linux.dev,
	akpm@linux-foundation.org,
	chrisl@kernel.org,
	usama.arif@linux.dev,
	kasong@tencent.com,
	nphamcs@gmail.com,
	shikemeng@huaweicloud.com,
	youngjun.park@lge.com,
	ryncsn@gmail.com,
	trondmy@kernel.org,
	anna@kernel.org,
	sfrench@samba.org,
	linux-mm@kvack.org,
	linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: swap_ops updates
Date: Wed, 22 Jul 2026 15:06:06 +0200
Message-ID: <20260722130615.3163560-1-hch@lst.de>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

Hi all,

this series is a follow on to the swap ops series now in mm-unstable.

The first patch reintroduces direct folio writes for synchronous
swap files, the other two remove the double indirect for file
system based swap.

