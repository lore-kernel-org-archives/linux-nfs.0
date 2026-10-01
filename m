Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C26E14D4895
	for <linux-nfs@vger.kernel.org>; Thu,  1 Oct 2026 22:58:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790895517; cv=none; b=pNsK6PUDInzyOnwZSEa4AJotgj+O+2lyx+Mw9MrpjmoyA2GzOQjrcgi9wIMDZiMPQ9s9LVG1T5Vjq3o9oOW0zbCeMRtQdX7AoSWrJvHHryRuxi4SXFKSs5zz8G7H9KJIrWGzgDXewhY1zO1hzTHFrzw2HQsj1WHUNQ3SzkyhXtE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790895517; c=relaxed/simple;
	bh=iCOovCn08TzQdptXm/c80cAM8DshOjWqg7oMUF8ZCaQ=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Cb99fONK1c5rugWGOoOQqVqAomW6KRkjNePwTs0Sxl6if6LV3mxHZ4jvucFYxw9Yg4PvDF2xJo9CwDyJrNm7aNQ4M5PtR2gESoUCVyba2cXtqsQ4ZeRDp6btF2hNCO/Ekrtfqy8dwHPbnHHQMwOfPqyJzDQMz7pcIrMiqFhgrro=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hF4b87yU; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hF4b87yU"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 22BEE1F000FF;
	Thu,  1 Oct 2026 22:58:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790895510;
	bh=iCOovCn08TzQdptXm/c80cAM8DshOjWqg7oMUF8ZCaQ=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=hF4b87yUQV+JlB9Dut574cNn4ztHTQgoA/c6+b+buLx/TkiKPVNAzmVl0yxXA0HD5
	 t8LlTQzLv1TQRTmW6EmUZMcR5qXdsZSgIBdqajOjOAXd3Iir1GgHIWCN9AIagjssLq
	 JiwSnBf1qy4qkIT53w9SPKLddaMf/x6nzik+QQarPrYo6U5Att0ujtjhVPjzRdsUAc
	 qLmQb6WHqALWso25OfLowvzO/JPRBsoZwaa6NzCkfsSMgzs40Z6xEXPEgWmzZmPs3W
	 aTSJSCqi1TRHy4slwxjDPp2kB+8Njajr3BS0e/o2kzKyJ5aREpXlpRy9BOJsymT8Od
	 VSg2QTlJ5RQqQ==
Date: Thu, 1 Oct 2026 18:58:29 -0400
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>
Cc: hch@lst.de, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 0/9] NFSD: keep direct-mode I/O out of the page cache
Message-ID: <ar7llVgQA49KABVi@kernel.org>
References: <20261001045502.48381-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261001045502.48381-1-snitzer@kernel.org>

Just FYI, while this v3 is vastly improved (thanks to it addressng
most of Chuck's detailed review of v2) it still has issues that I'm
addressing.

I'll post v4 when its ready, so please don't waste time reviewing v3.

Thanks,
Mike
