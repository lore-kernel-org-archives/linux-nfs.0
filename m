Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ADAC82E54B3
	for <linux-nfs@vger.kernel.org>; Mon, 27 Oct 2025 08:09:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1761552569; cv=none; b=o5nTIFfCAEeqE9NnYfURLXXbFFHWSuKor/UB9B2n5ayeLa8glIozxGsCkoxLPel9KPBNSTcSgZ3UJIKavH73bxXmuxiOO7GoFF/tO93oG1TkPTftVfOg0fDTNHmzZkA/8qyw3+9YfV3pqayPdt+lYXx99r3roN39b0nY9fNgPtA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1761552569; c=relaxed/simple;
	bh=8p0XIvBn239vkcgIaWpL//YYLk+2rc2+CVplSyBrwL0=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=brD/gunfw9XxKYI1Si0JLUvyoGOZULrTipxjGizOgnmZK2XRTDO/hmRbHnlHsWhTdJjCmOMVQePPVOht70hS/Hk5UGbTQ9h7vV2gmhx1XI/MGXQ4ADrflZ7c3ok08iENwvCHYpNsSbUoiUSwlyQGFyD59Jeq/MF6mOKfN12Ln7g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=1+2M9408; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="1+2M9408"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=e/BCrHQK1sLqknWhe8D4sEuhW94+wpcnxrkpyPM8ipY=; b=1+2M9408H3Uz4FXZTTi8DR1pMu
	S65O+/H+ws52lK8q4sIzHqrTlLanmYiBCrC3sxsMOlho6FuPWXPXE1S6cT7rpeq1vNkWqKESvOzOw
	68ZMmF/o2FmkrivMNgLYo5CZtV5Yo3lrPz8/fpJmIvfsMzP7E+FPpvj7EXLhdTDDpEtZOXsSX/tRg
	8lP9oND1PXeC+XqGLZisaUYy2tRZeNuy3AT+/C6R8RuSTLqKvSRN+01kFUOQmwRQ6i8WS6sGEPMJd
	38jTeht/KAoluMMcG6ayrXXnt5xRTwe1njm8TU2EKbXlgVBYE8e8GfXOp74KJQNoarBS4ogFPBeS1
	IL8hslZA==;
Received: from hch by bombadil.infradead.org with local (Exim 4.98.2 #2 (Red Hat Linux))
	id 1vDIIA-0000000DKK9-2hTQ;
	Mon, 27 Oct 2025 08:09:26 +0000
Date: Mon, 27 Oct 2025 01:09:26 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <cel@kernel.org>
Cc: NeilBrown <neil@brown.name>, Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>,
	Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v7 08/14] NFSD: Remove alignment size checking
Message-ID: <aP8otlrPH3DerSR-@infradead.org>
References: <20251024144306.35652-1-cel@kernel.org>
 <20251024144306.35652-9-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20251024144306.35652-9-cel@kernel.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Fri, Oct 24, 2025 at 10:43:00AM -0400, Chuck Lever wrote:
> From: Chuck Lever <chuck.lever@oracle.com>
> 
> The current set of in-tree file systems do not support alignments
> larger than a PAGE, so this check is unnecessary.

XFS does, although your won't find production hardware with > 4k
blocks as far as I can tell.  The reason to drop this check was
to not arbitrarily exclude them for no reason.
