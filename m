Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="gmYBIYBN"
Received: from bombadil.infradead.org (bombadil.infradead.org [IPv6:2607:7c80:54:3::133])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 6D1D1D6D
	for <linux-nfs@vger.kernel.org>; Tue, 28 Nov 2023 05:06:30 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=cr39bMb58vJt4rWebaEN0xNgrMpZlAXuU3PDJK++r/U=; b=gmYBIYBNRFvWSmeRdmZd1erwaQ
	YO1Dh2A+/bJc4sdrfUimfBLXSQ1s5c0vv5sUchbgMfipR4aVQPcFKsPFhVoiou71Ti+xt0QwxA+tW
	grZ4hZvp3sjWjoeJpZFybps9iLD90OAS+nh57sFl2tMJ9A94tezB9l1NJY2yuq3a/maHqJzMOnGdC
	ODxUJE/qAbvW3fWeFo76ZpaLy4s7ln26/VCvHznLYwTqazx27nI8WmlbeYEbImV1F6IOPgN+IBq5U
	x9ikNXD7S4YuNxS8/u+Fo9lBFGjI7Gr4gSfsh/a6dPLkYGMD2RpXwckMDK4PADAwJYdMEGbIGjWEP
	zw5XtYQQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.96 #2 (Red Hat Linux))
	id 1r7xnF-005M5V-2T;
	Tue, 28 Nov 2023 13:06:25 +0000
Date: Tue, 28 Nov 2023 05:06:25 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever III <chuck.lever@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, Tao Lyu <tao.lyu@epfl.ch>,
	Trond Myklebust <trondmy@hammerspace.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Question about O_APPEND | O_DIRECT
Message-ID: <ZWXl0ZppQkpafXVr@infradead.org>
References: <c609e5f9df75438dbfe3810859935d58@epfl.ch>
 <2d948b43fa625952e50589e4bedf9551df7ee112.camel@hammerspace.com>
 <7d2d17e4d3904d29b75fadcfd916b2a3@epfl.ch>
 <ZWTFn0/FtJ5WuQGc@infradead.org>
 <7E2914D2-B9AB-4280-9A44-875DA8B58328@oracle.com>
 <ZWTKBzx2Wkw6Mbxd@infradead.org>
 <52559C84-A251-4CAD-8BDF-B1B2EA4DA390@oracle.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52559C84-A251-4CAD-8BDF-B1B2EA4DA390@oracle.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

> I said "proof of concept" -- obviously you don't want this kind of
> racy arrangement as a long-term solution, you just want something
> that works with current server implementations for experimentation.
> 
> And, if the above WRITE succeeds, the client would know exactly
> where the server placed the payload in the file.

But I'm not sure how this proof of concept helps me to prove anything
except that this method sucks :)

