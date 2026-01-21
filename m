Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 329F9500971;
	Wed, 21 Jan 2026 14:50:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769007060; cv=none; b=FAYXz9VMVJzOv4KwkWaLSuXaBmbRcMrI9cfow3bPTh/XfPXFK1EEK+kK+QThHXjFUkav7/2oTnztVX0TQLMbiXkLGIdfpElXqMPGSAS64A8GTHLCS1xqLW+twcbU3rii1MOEB0snp7Aeri4+SZAZT2823iLkNF5+exVQN12s/RY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769007060; c=relaxed/simple;
	bh=jkN42i04PCY9gsFvRKGdvArKZfuihUzw6N8XCuSD7EE=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=sb6bFOjFsRLqq67LbXZRo8mKpYd27hvqExNRgZSLvBvSX/ch1zBYslk9jYAJpuiwhUcNWcZB68tiwqVXhsXhVD8eJogoaIw9uUcfdm8ViIy8yB2di9JWepAkXi7D2m81aLlLbqGA9Su4iOnP0PZze4zh17w4gpK9Kpe6Zt5Ytgg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id B2714227AAD; Wed, 21 Jan 2026 15:50:52 +0100 (CET)
Date: Wed, 21 Jan 2026 15:50:51 +0100
From: Christoph Hellwig <hch@lst.de>
To: Amir Goldstein <amir73il@gmail.com>
Cc: NeilBrown <neil@brown.name>, Christian Brauner <brauner@kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>, Christoph Hellwig <hch@lst.de>,
	Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: do not allow exporting of special kernel
 filesystems
Message-ID: <20260121145051.GA13325@lst.de>
References: <20260121085028.558164-1-amir73il@gmail.com> <176898904083.16766.14818617047357377637@noble.neil.brown.name> <CAOQ4uxiB=RAZEgTRqRvbCQ4e0FTc9WaTX2Z+T=YAYySaPUVHjQ@mail.gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxiB=RAZEgTRqRvbCQ4e0FTc9WaTX2Z+T=YAYySaPUVHjQ@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Wed, Jan 21, 2026 at 11:24:47AM +0100, Amir Goldstein wrote:
> > It is not immediately obvious that this is safe when nop is NULL, but it
> > is because exportfs_can_decode_fh() checks for that case.  As that is a
> > static inline a static analyser can easily confirm this.  So it is
> > probably OK.
> 
> Heh, in the RFC patch [1], I had those conditions wrapped in a helper
> just below exportfs_can_decode_fh(), so this was more clear, but now
> I tried to avoid adding a helper named exportfs_may_nfs_export()... ;)

Please drop the nfs - exportfs is a generic layer, and not tried to
nfs, even if that's currently the only user.

