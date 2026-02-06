Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ACE1E49659;
	Fri,  6 Feb 2026 06:16:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770358583; cv=none; b=qCx5SHiz9yhQa5azfuvSYBW8A0v2eFRGuNYPUrc++VpsDY3frYTcLlcmZZ8o3SEL140e35sslfJDh1FoIagSttRlea+huh4/HD26o/9ezrEGRcCzffVe50YJdvFDF9MPnopH7YxcUeK6mGZB/+ZYWsOPSLcFjB61HWs4gqfwXL0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770358583; c=relaxed/simple;
	bh=8PQdEOmHbCSQyT+ysDwPoF2uH5YyPYG9BZGQCZUWhyU=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=NsGXUWK1nfnSfqpw5/WwHwe20Uh0knRnDeDKSerdWg8+mRusirXt0wbWg1c+MnJP34ifidxaHv1OeP62YKKTRj3cZsdIERWW7iVrMsvr6ISds5ILYX8xVM1kJIcirJZFwcwOk5Q51f0DEMy/dxT5Tjet0WBeE5g4q1sM8D/xj0U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id E855768D0F; Fri,  6 Feb 2026 07:16:17 +0100 (CET)
Date: Fri, 6 Feb 2026 07:16:17 +0100
From: Christoph Hellwig <hch@lst.de>
To: Dai Ngo <dai.ngo@oracle.com>
Cc: chuck.lever@oracle.com, jlayton@kernel.org, neil@brown.name,
	okorniev@redhat.com, tom@talpey.com, hch@lst.de,
	alex.aring@gmail.com, viro@zeniv.linux.org.uk, brauner@kernel.org,
	jack@suse.cz, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH v5 1/1] NFSD: Enforce timeout on layout recall and
 integrate lease manager fencing
Message-ID: <20260206061617.GA25655@lst.de>
References: <20260205202929.879846-1-dai.ngo@oracle.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260205202929.879846-1-dai.ngo@oracle.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

Most of this is over my head (but I'll still try to come up with good
comments if I can find some time to learn/relearn the lease code), but
one thing I noticed is that this mixes up VFS and nfsd code.  You
probably want to split this into a core infrastructure and a nfsd patch.

