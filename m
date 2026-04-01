Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 652ED40824B;
	Wed,  1 Apr 2026 14:25:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775053519; cv=none; b=GLQaFRMvG1ht0Xc7x4eLTpHCmRaI2RF3d5yLWpfWFky3LpzUeXT1tNiKPxnnNgyONTM2GqaDx87SZ/dFl5nCmnyisHkRFEpDZxEqH3kjKQsacfgWWG9heXt/b2tyouSVAgP0yQoCj3o0A4wiw0d2v320l6n/c0fx+7TMfoEyJdk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775053519; c=relaxed/simple;
	bh=hibNW0OK1+43pYDv4VAtwhTWQ8LT4HOtBtLLO2bP8Po=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=U/+9WzFGP4cF1XcAiCuDB4E0qi6WsWda6I18bwTfyaiB1UeLqkOAnNAxbFvZlNs8dVnpum6BpJJ24do8/tKdl3i6oj6mIlsL45dgbT3BdvcbzThs3Mvd8yemxY/VzL5p+GlTkXPf//19jO63zkjIqdlsle6D395TU05eRMdFEXM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id C881068C4E; Wed,  1 Apr 2026 16:25:14 +0200 (CEST)
Date: Wed, 1 Apr 2026 16:25:14 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jeff Layton <jlayton@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, Chuck Lever <chuck.lever@oracle.com>,
	Amir Goldstein <amir73il@gmail.com>, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 1/4] nfsd/blocklayout: always ignore loca_time_modify
Message-ID: <20260401142514.GA22685@lst.de>
References: <20260331153406.4049290-1-hch@lst.de> <20260331153406.4049290-2-hch@lst.de> <47bf9653ce304f973cef6248e10a7dba4d958140.camel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47bf9653ce304f973cef6248e10a7dba4d958140.camel@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Tue, Mar 31, 2026 at 01:09:28PM -0400, Jeff Layton wrote:
> >  	iattr.ia_valid |= ATTR_ATIME | ATTR_CTIME | ATTR_MTIME;
> > -	iattr.ia_atime = iattr.ia_ctime = iattr.ia_mtime = lcp->lc_mtime;
> > +	iattr.ia_atime = iattr.ia_ctime = iattr.ia_mtime = current_time(inode);
> 
> Technically, these fields are completely ignored by notify_change,
> unless their counterpart ATTR_?TIME_SET flag is set, so you could just
> leave them unset.

We're not actually going through notify_change here, so for now we'll
need this assignment for non-mgtime file systems.

Btw, shouldn't we move the actual time sampling from notify_change into
->setattr for non-mgtime file systems to avoid the extra sampling in
notify_change for the mgtime fast path?

