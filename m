Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BFAE6351C0B;
	Fri, 10 Apr 2026 11:10:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775819413; cv=none; b=nzA/VJ+bf0B8SNwimGk3zNhpRenTTbChbv6E4oCuQzURrlNg1jakoovFjRyovm7HIZ4JBST194hH7RK9FwLUkIyorQARmEDtN7mBsmvzG7oIu+NJ65GyUnJQQMBVrP6P4Xv+O65ejL8AAVOk0Zmnpi+ipDtbdy3bR+OYZjxpFyY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775819413; c=relaxed/simple;
	bh=Ya2WgyjrRXRzPbJUZ7gu9VmOtZNdk1pa9p5Sv3qi5Yw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=pOrwtX8LDrlBwJVTjuPId+VNZT8+1ptJHO5gzBK8J8grXmZNVP8ugjN3VwbgQrz4fBnsOPZPia+x+51G6JKaQIOWTou3WDXC8+VmCKA5+Wm8bzQCwDWlgYoAVigBiewZRiKUYCyE7XecrqTxfjwONxXla6R05YyIT3Fg5gil20E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 3EF7868BEB; Fri, 10 Apr 2026 13:10:08 +0200 (CEST)
Date: Fri, 10 Apr 2026 13:10:07 +0200
From: Christoph Hellwig <hch@lst.de>
To: Christian Brauner <brauner@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>,
	Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>,
	Amir Goldstein <amir73il@gmail.com>
Subject: Re: cleanup block-style layouts exports v2
Message-ID: <20260410111007.GA10292@lst.de>
References: <20260401144059.160746-1-hch@lst.de> <8bef4d4e-1c0d-451d-8854-ed0cba27ee1f@app.fastmail.com> <20260409-schwalben-neutralisieren-fb5a184e5049@brauner>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260409-schwalben-neutralisieren-fb5a184e5049@brauner>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Thu, Apr 09, 2026 at 03:26:09PM +0200, Christian Brauner wrote:
> > Christian, are you OK if I take this series through the NFSD tree?
> 
> Hm, I generally prefer infrastructure to go through the VFS tree.
> You can get a stable branch ofc.

Communicating this earlier would be helpful.  If we switch to a new
tree base we're going to miss this merge window.
