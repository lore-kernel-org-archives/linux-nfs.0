Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 31FF14C6D;
	Wed,  1 Apr 2026 06:19:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775024349; cv=none; b=Pgez7tXa8agd+iCjDh4PUxAxgocJHzMXssdM7GSFiNzZCkcSDr9QYjsUKATeu1AFSxwve9A1eBEEzpWdiOQ0WPndwOEPUjKzhXiTcdamAyWysp3Gi9kuuBSLTEuAt0RNtTCJ97CrgVCATDhCLcNa8P7PWzI8545sEtgvIzB339g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775024349; c=relaxed/simple;
	bh=bPQQft+2QSfANvlLhfSlQwSMRnZGJogFo6eQWfnF8Ac=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=SnESm9iOllTaLLwx2dJV6Rbud/BBPR1EJCBaWhzC0vDNm4yPkk+yOUuyakMVv2jBOmlfVj4rxwHCKtHhKX/WgxrbLtrHG2u/dYNjvZSQGmx/KDyWnjhyAZt/4VCD8JyZXKyRpQ2+lnzu1HiI/nDkp2AKUN+Rs/0FV5lOM/pncfg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id CB58268AFE; Wed,  1 Apr 2026 08:19:04 +0200 (CEST)
Date: Wed, 1 Apr 2026 08:19:04 +0200
From: Christoph Hellwig <hch@lst.de>
To: Chuck Lever <cel@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>,
	Amir Goldstein <amir73il@gmail.com>
Subject: Re: cleanup block-style layouts exports
Message-ID: <20260401061904.GB24293@lst.de>
References: <20260331153406.4049290-1-hch@lst.de> <df21ae49-c763-43d6-bdb2-c492f349a6cb@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <df21ae49-c763-43d6-bdb2-c492f349a6cb@app.fastmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Tue, Mar 31, 2026 at 01:33:11PM -0400, Chuck Lever wrote:
> 
> How do you see this getting merged? Do you want all of these
> patches to go through the NFS tree? Or do you want this to
> go through VFS?

I don't really care.  But I traditionally see exportfs as a nfsd domain,
even despite the added other uses of it.

