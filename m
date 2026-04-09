Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D0FBD72623;
	Thu,  9 Apr 2026 13:26:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775741174; cv=none; b=lO8DWyhdIUdoSav2lfhR5DIrMJebZOIMrZqo03emoAukEMpp8X0kZRdqnqEpAWhFfAtuqqs+NKvS26pxC6Lm8VCfflsH0NV/NY2yuU7K2yvx0/nFUsxqr3NzFQa84DhVjjE6/muJX3w6juQf5ml39ti8+7guCRQPeCd1b62e+gw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775741174; c=relaxed/simple;
	bh=zmhkq4PDS4IfOWhY+pb2UCU8sN/y24aMrKPrN72/iKc=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=fsFgDN/hZd+2smkuVV3Z++FQ7J0d/ISlhjTZJ8yox8YMDNo4qMK4fRLIXK74lIm3fFjPDq7LE3Pmn5+qVvnwCn8Gk72xysDCgaKCnkq4clPDu52BSrM5BeyU/lMTSnQr9gNrY6vcoMDZ7ZdJ5XEg56NKHn843zGWk0fJiGBvcEI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=u1ahtYIt; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="u1ahtYIt"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9C113C4CEF7;
	Thu,  9 Apr 2026 13:26:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1775741174;
	bh=zmhkq4PDS4IfOWhY+pb2UCU8sN/y24aMrKPrN72/iKc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=u1ahtYItx4uVvPHncZBk+Kgg4NIk3Fmd1T0zOxBZ4/lncRxrqwUm0jEBt8ENiaeYr
	 Pl0Ai5axEw8mE5poBo2ON6nguiK7BVcHLG12VuHROCYARu1ePxirj2BbEny08cSFO3
	 AJ3AHZCMVnKKcyb6wgZrZttDKA6x0hr7nJ0Z7D3yuKZM6ZMBuGY0z2sYYgepdDvPC1
	 FO3iX/zdUE8CZD8KEUeQnfLmwFTq3nwlu23GDu6MqRX8hnGUQGwa5uZ2+pRyIQit2O
	 OAnaUSvMFmq4rvaTneqOH9RrcqEB4kLyM+OHKipc2Fna1xkj5T+arT+rwV+7+VYdjv
	 L+V+KDH4GIsRA==
Date: Thu, 9 Apr 2026 15:26:09 +0200
From: Christian Brauner <brauner@kernel.org>
To: Chuck Lever <cel@kernel.org>
Cc: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, linux-nfs@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, 
	Chuck Lever <chuck.lever@oracle.com>, Jeff Layton <jlayton@kernel.org>, 
	Amir Goldstein <amir73il@gmail.com>
Subject: Re: cleanup block-style layouts exports v2
Message-ID: <20260409-schwalben-neutralisieren-fb5a184e5049@brauner>
References: <20260401144059.160746-1-hch@lst.de>
 <8bef4d4e-1c0d-451d-8854-ed0cba27ee1f@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <8bef4d4e-1c0d-451d-8854-ed0cba27ee1f@app.fastmail.com>

On Wed, Apr 01, 2026 at 04:31:10PM -0400, Chuck Lever wrote:
> 
> 
> On Wed, Apr 1, 2026, at 10:40 AM, Christoph Hellwig wrote:
> > Hi all,
> >
> > this series cleanups the exportfs support for block-style layouts that
> > provide direct block device access.  This is preparation for supporting
> > exportfs of more than a single device per file system.
> >
> > Changes since v1:
> >  - consity struct exportfs_block_ops
> >  - fix spelling
> >
> > Changes since the multi-device export series:
> >  - check for NULL bops in nfsd4_setup_layout_type
> >  - clearly document why we are ignoring loca_time_modify
> >
> > Diffstat:
> >  MAINTAINERS                    |    2 
> >  fs/nfsd/blocklayout.c          |   37 +++++++----------
> >  fs/nfsd/export.c               |    3 -
> >  fs/nfsd/nfs4layouts.c          |   29 +++----------
> >  fs/xfs/xfs_export.c            |    4 -
> >  fs/xfs/xfs_pnfs.c              |   44 ++++++++++++++------
> >  fs/xfs/xfs_pnfs.h              |   11 ++---
> >  include/linux/exportfs.h       |   25 +++--------
> >  include/linux/exportfs_block.h |   88 +++++++++++++++++++++++++++++++++++++++++
> >  9 files changed, 162 insertions(+), 81 deletions(-)
> 
> Christian, are you OK if I take this series through the NFSD tree?

Hm, I generally prefer infrastructure to go through the VFS tree.
You can get a stable branch ofc.
