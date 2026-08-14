Received: from mail-qt1-f181.google.com (mail-qt1-f181.google.com [209.85.160.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8F30147141B
	for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2026 14:37:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.181
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786718256; cv=none; b=RTRaGLa3dXzWhbqNm1FtStF2NN67aULtVtx/hi1+oq9rZNR+uPuVBnwMmWpVmEvVf3favNvUUvcZLwcvLZIdsjPenDgp4wBL5QRAPcAqM057NzMmtqA/hi7MW9QkC+LL9mognh9jpf4O6iAOHJW+HAMQr4oXTB1IkSLIWpD04Xw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786718256; c=relaxed/simple;
	bh=8HY0wtknzHE1zM0Bt/3qPku0pGktneOD8Vol90D/JnA=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=R4x8y8w3vnyN3XLLPkB4lyNESyuFP3a2vRu/NdkWRSssS4SJUJQpnh/xv0LZtb2X3LRyCii0FWxwrkdcCHLRKGRYX9hxwgQEahuxxUv556mKHHUj3ML5xvlajIoiUTCElYkUK7vD5WgVCLc8wb4IJcUpFnU8dF6mVUNpyRLzJWY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=aihDdt9L; arc=none smtp.client-ip=209.85.160.181
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="aihDdt9L"
Received: by mail-qt1-f181.google.com with SMTP id d75a77b69052e-51c01c79467so304071cf.0
        for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2026 07:37:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1786718249; x=1787323049; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=pnSp8kF5uifmNKvBVfAG+ZOgXVW+rCKTiYJb35Z6MS8=;
        b=aihDdt9L1ektfKzp9mKuZNAUZaxydoOhm28YFwiX5GnLvkomUaSLq429uUyiubOvxf
         buTHnNI6bZk04Oe9ibf+/VkXp8ZcgNCq4vh7s1raqPjhBNcYyfTK6eDkYwaPukiJ+XMo
         58LPuXBBadUkr80PKvpQmp+ViB9GEERoMZS92BrGTCpmSDqJX+UMW350+dU2iwDk4rT+
         MGE365CJN9Jx+eNIuvPEwI18LBTmuO/L+TcNcg8n6noyOrf7P4YLjorncU89z27YsfVp
         UguiCh6qlEDvESLMovkrAuYxSLvzQR1uHdeQ/zdGj7HoiUZGfyGP/iZlFT4ceipl5IkJ
         TbeQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786718249; x=1787323049;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=pnSp8kF5uifmNKvBVfAG+ZOgXVW+rCKTiYJb35Z6MS8=;
        b=a2YwQSbVoq4vrmomhl2UJPujY57QnoLCd0ZQ4KYnAf3p8gV+Olomou1wIeap8O4eMd
         kGVMLZbuqKaUbc77zP/U3gGSlFBIKs6RCA53J3iwTvLkQT+4trpgPGr67RUcQUFVD2c6
         DemhFVvibBynXSZ0sR3JKZ6izimLTp6JQu3/3zc9CBtEEefAGfCM5vybRrbgPaXB08ja
         TzB+IE12X1+qwAIw0y3bgyuRcKPE5Od8cfKRopeHYqoqjUA+47DIlJAeW+VZ5D3jcg4u
         lJKhvE0bJM2NmQUpO8fS8tNQ630gRw3v5cg8hQ9s5DHmVAin9qkWEPT47YFtlqctBxdd
         cPYA==
X-Gm-Message-State: AOJu0Yw0SnyNdN7s54Y83rxh8UUgDcTiba3QixisPtmQLgQg1oOv489U
	MV8ATa8QgxqDUJKW3sg2v9cMYufa5olFtLyUzB8WC1VnH6Rse3Z046YynaUYNdgxE2TzpW6Vd7J
	1s8rwoA==
X-Gm-Gg: AR+sD12so7u8wsRq8djzbvjMeA3VtdBUhfHu4HkEcIyXNuAMmZs7v2N5trlX+ydlrf3
	d2Z0Q5sVtYEg/6FmlpoRf5CL0s1Lh34SJ/7XgDDw3V61GQ1DeQq7rPxYr6G+dOe68aS7lYf5fhO
	XN3k74ms20Jvafore54AitH7w/yJry3co4Uueu1kv5zLZke/k/AUH33bhmeEbK56g7rptSMoLBQ
	/04kXVHWhcPgP0MTZK4+8rID3+gL0cusO3Xk5WYhfdQQ3QOtHN7BZOt/ykcKbyco5pQ+nM7Z3kG
	V7zh+1oxqxP5d3VHVKRBENNqVJ2YIpcYdn2srVvyVE6tQygRLZiIW0agASAQS4PYo0WrjQWaycO
	rMzLP9rNwuUTD785ESs/4N/rxDDZ9/oh+pqR6PLdwV5JN9JJFasDwt4Oj6o8RlBnNVlO+yNjfyp
	LcKkZ8W+70DoCMn5HEAkL/GHdlotBVqNngh/C8X471r5h18Dx7Qy4FYuE4M/vtZvCXKfsy98cmI
	LvVsC+4/7diqWxjPUMx8BY=
X-Received: by 2002:ac8:5f8b:0:b0:50d:edb1:6bd1 with SMTP id d75a77b69052e-52d8631482cmr14545171cf.13.1786718248227;
        Fri, 14 Aug 2026 07:37:28 -0700 (PDT)
Received: from google.com (21.168.124.34.bc.googleusercontent.com. [34.124.168.21])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-90a921e6f51sm20444946d6.8.2026.08.14.07.37.24
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 14 Aug 2026 07:37:27 -0700 (PDT)
Date: Fri, 14 Aug 2026 14:37:21 +0000
From: Pranjal Shrivastava <praan@google.com>
To: linux-nfs@vger.kernel.org, Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
	linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
	Logan Gunthorpe <logang@deltatee.com>,
	Jason Gunthorpe <jgg@ziepe.ca>, linux-pci@vger.kernel.org,
	linux-rdma@vger.kernel.org, Shivaji Kant <shivajikant@google.com>
Subject: Re: [PATCH v4 0/5] nfs: modernize direct I/O path
Message-ID: <an8oIS2WA5CdQGVQ@google.com>
References: <20260810195040.2877784-1-praan@google.com>
 <ano2R8fAeGmsNt9f@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ano2R8fAeGmsNt9f@google.com>

On Mon, Aug 10, 2026 at 08:38:49PM +0000, Pranjal Shrivastava wrote:
> On Mon, Aug 10, 2026 at 07:50:34PM +0000, Pranjal Shrivastava wrote:
> > Modernize the NFS Direct I/O path as a preparatory step to enable PCI
> > Peer-to-Peer DMA (P2PDMA) support. Following feedback on the initial
> > RFC [1], the modernization and architectural changes are split into
> > different series. Additionally, based on the discussion in the v2 [2]
> > of this series, the migration of NFS Direct I/O to folios would be
> > handled in a separate follow-up series.
> > 
> > Currently, NFS O_DIRECT relies on the legacy iov_iter_get_pages_alloc2()
> > API which does not support the pinning requirements for P2P memory.
> > The implementation moves NFS to the modern iov_iter_extract_pages() API.
> > 
> 
> [...]
> 
> I'm calling out a few typos / non-code mistakes:
> 
> 1. On the cover letter I missed updating the subject to v5 for this series
>   (the changelog is noted below).
> 
> 2. I also accidentally dropped Christoph's Reviewed-by tags on patches 
>    1, 2, and 3 during the rebase (given while reviewing v4 [1]).
> 
> Everything else in the series is correct as per the v5 changelog.
> Please let me know what the right etiquette is? Shall I resend the series?
> 
> Apologies for the noise!
> 

Quick update: 
I've posted a v6 [1] with fixes for unpin bugs reported by Sashiko [2]
and with R-bs from Christoph that were dropped mistakenly in v5.

Thanks,
Praan

[1] https://lore.kernel.org/all/20260814143255.861084-1-praan@google.com/
[2] https://sashiko.dev/#/patchset/20260810195040.2877784-1-praan%40google.com
