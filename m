Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 745B6253F05;
	Wed, 11 Feb 2026 15:53:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770825231; cv=none; b=S+q2ZwlPuwx3/LlmShbsKTHOHbtKndGZUZXiyimR5zA4acoRxgCfYM4YfaKRnGd7/2L+xTScCn0tsHzXJiLzHaiLq3A0DseHSVLqQX/7mTycT7DR4dybBzx1pXAGXcQctdq3fFmiRO16QnATnMh7AgLtQCjDFkBktJsdojkuzcY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770825231; c=relaxed/simple;
	bh=bQpzoySm9WxiL3m+AQgKRKyIaZ51ZZa5CoaKD8psjFk=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=f00oN0V6d7N+7RZhOtqBqm2TBlpBGmsfRVGhSDg05lgY3TZZm7r5vnnqRzn0XsH4nclQ0q4J7mJcd9JcfySS84cIL7ZwL4Z2OIScWcC5tONtR0jrsxS0NjPYjNM5iIO0V9FJWaDQYSiIfe2/hqTC9RqJupqTVg2zpz90+ttnvhk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 35A4668C7B; Wed, 11 Feb 2026 16:53:47 +0100 (CET)
Date: Wed, 11 Feb 2026 16:53:46 +0100
From: Christoph Hellwig <hch@lst.de>
To: Kundan Kumar <kundan.kumar@samsung.com>
Cc: jaegeuk@kernel.org, chao@kernel.org, agruenba@redhat.com,
	trondmy@kernel.org, anna@kernel.org, hch@lst.de, brauner@kernel.org,
	jack@suse.cz, viro@zeniv.linux.org.uk, djwong@kernel.org,
	pankaj.raghav@linux.dev, linux-f2fs-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, gfs2@lists.linux.dev,
	linux-nfs@vger.kernel.org, gost.dev@samsung.com,
	anuj20.g@samsung.com, vishak.g@samsung.com, joshi.k@samsung.com,
	mcgrof@kernel.org
Subject: Re: [PATCH 0/4] Avoid filesystem references to writeback internals
Message-ID: <20260211155346.GA10445@lst.de>
References: <CGME20260211070533epcas5p32f50f317b20250bb61b1b5a0b3a2a5d9@epcas5p3.samsung.com> <20260211070057.22001-1-kundan.kumar@samsung.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260211070057.22001-1-kundan.kumar@samsung.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks fine as a cleanup, but maybe add comments that these functions
must not be used by file systems that support cgroup writeback and
thus can have multiple bdi_writeback structures per bdi?

