Received: from outgoing.mit.edu (outgoing-auth-1.mit.edu [18.9.28.11])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BFE434BD102
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 14:47:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=18.9.28.11
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788446841; cv=none; b=QMneMydcJFIIYZckQjERK1eNwwpGt9CtYAgTjmjzIjIeuavLcLJ7KpfYIoO7DGRRrZIytuAirHM4O7seFw6qMZTUnlfS2TXRhucqHic4J2PdUfr2blFHFPt//qEI+KGEBOdsmCG3XHlx9uEzTiqqYQ/4J+wCUXGOgUb0uXMN0S0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788446841; c=relaxed/simple;
	bh=/T7YqONCo5eBXsKvF/epQygH07trT6370ALQnDdAp40=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=NvL+ICoX7cTZySHbtg+B6qytSiyKcqGyV4iwrAvcbk2dgBTYipQhcnGbwuAamLE+hJbVR7sGkOvQ/IlKoJAZQeDiuwWiNk3JlOe4Kh8GLdGMYqUeycZ5YHRjM3q5nZ/Ln8j//ZwD8nDm4Tp4bVex3OKkPe3jxX7c0Gz60OF7ZhI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=mit.edu; spf=pass smtp.mailfrom=mit.edu; dkim=pass (2048-bit key) header.d=mit.edu header.i=@mit.edu header.b=QJesqE4T; arc=none smtp.client-ip=18.9.28.11
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=mit.edu
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=mit.edu
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=mit.edu header.i=@mit.edu header.b="QJesqE4T"
Received: from macsyma.thunk.org (pool-108-26-156-67.bstnma.fios.verizon.net [108.26.156.67])
	(authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
	by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id 683EjLMF011651
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 3 Sep 2026 10:45:22 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=mit.edu; s=outgoing;
	t=1788446726; bh=qHs/hYcfdCQ1ysGE+hmGWWr3Mk+We3imbSb6wYOC52U=;
	h=Date:From:Subject:Message-ID:MIME-Version:Content-Type;
	b=QJesqE4TZVDMmqCP0gYnKzQVE38G5Sj1uHY8Px+6ZarWBBRuhH1Fwb1CRJ5tJPRFV
	 tmOiLD28kscOP8nUwRZQsNO/wuT4KMKK12aCBaWLHnxjUqbgUTwmyQBvTJ2mBkZ+88
	 /QN2pl7raeA9OfyGDIqrh4LXvngd7aOvgPf+U75IMT4tmP+CjfZpnKL3Ym4RgOG14t
	 k28ord6f1XO1MU81Az2eIi9VgraAJBU9HpcZgM1M3J0UIfdl859jwgeG0NbUVpFB/V
	 7p2L8VgjrjdYi/84CLpjr044H60KgLgzIYRVIAI7c/vwX2bDYIxq9mAEVxUhO4HVWN
	 LYHu+Y27eWAuA==
Received: by macsyma.thunk.org (Postfix, from userid 15806)
	id BA709132623E; Thu,  3 Sep 2026 10:44:20 -0400 (EDT)
Date: Thu, 3 Sep 2026 10:44:20 -0400
From: "Theodore Tso" <tytso@mit.edu>
To: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Cc: Christian Brauner <christian@brauner.io>, Jan Kara <jack@suse.cz>,
        Gao Xiang <xiang@kernel.org>, Chao Yu <chao@kernel.org>,
        Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
        Namjae Jeon <linkinjeon@kernel.org>, Hyunchul Lee <hyc.lee@gmail.com>,
        Phillip Lougher <phillip@squashfs.org.uk>,
        linux-erofs@lists.ozlabs.org, linux-kernel@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org,
        ntfs@lists.linux.dev, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: [PATCH 2/9] ext4: Remove uses of FGP_NOFS
Message-ID: <apmHuRN-r4gfWnTX@mit.edu>
References: <20260830041901.2668-1-willy@infradead.org>
 <20260830041901.2668-3-willy@infradead.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260830041901.2668-3-willy@infradead.org>

On Sun, Aug 30, 2026 at 05:18:49AM -0500, Matthew Wilcox (Oracle) wrote:
> Both of these locations are called while a transaction is in progress.
> Starting a transaction uses memalloc_nofs_save(), so we are already
> prevented from recursing into the filesystem and using GFP_NOFS was
> unnecessary.
> 
> Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>

Acked-by: Theodore Ts'o <tytso@mit.edu>
