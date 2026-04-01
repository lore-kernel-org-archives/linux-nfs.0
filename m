Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7557F1DED63;
	Wed,  1 Apr 2026 06:23:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775024635; cv=none; b=KB28OavbGpeuuAXnqv1bfQZK3KGOWQMl7T4Rai1Y3ZNq9cHEWBwUZDH1OSLdLT+xe+N1OHk6Zua974yVVj6IfDU+7KjO4FEfDz5BYuQ/IJDAy+AUI5p45FAh/08QELNStVnj5bsxaW2rX1xsDE60mPdI80JT1zwOmg1NkUPOuwg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775024635; c=relaxed/simple;
	bh=bOxbA0rIzcVxD36BF9Wj8NhMdARsCovSx2UVQ1UrLUc=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=kMbuL+CtDYCMiYuPIiPnwbtt0HIoNS1QsOUrNpA/IsL9pzcseciqohm10XS3J6A3jDQJJ1/Nzd2GvN+LvVYB+7ZEnLZxWJd4ORewC2b1a9sDAqfMI4MgvNhwkHg0BGdsimd4KMbxhhJ68uLmKnE90t2urZ002Zos7TcMNzj1XrI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 86FDC68AFE; Wed,  1 Apr 2026 08:23:49 +0200 (CEST)
Date: Wed, 1 Apr 2026 08:23:49 +0200
From: Christoph Hellwig <hch@lst.de>
To: Chuck Lever <cel@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>,
	Amir Goldstein <amir73il@gmail.com>
Subject: Re: [PATCH 2/4] exportfs: split out the ops for layout-based block
 device access
Message-ID: <20260401062349.GA24374@lst.de>
References: <20260331153406.4049290-1-hch@lst.de> <20260331153406.4049290-3-hch@lst.de> <88fb08eb-8494-4f3d-99cd-e0b7a459a3bb@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <88fb08eb-8494-4f3d-99cd-e0b7a459a3bb@app.fastmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Tue, Mar 31, 2026 at 02:07:12PM -0400, Chuck Lever wrote:
> > +struct exportfs_block_ops xfs_export_block_ops = {
> > +	.get_uuid		= xfs_fs_get_uuid,
> > +	.map_blocks		= xfs_fs_map_blocks,
> > +	.commit_blocks		= xfs_fs_commit_blocks,
> > +};
> 
> Should xfs_export_block_ops be declared "const" ?

Probably.  If something doesn't support that right now I'll need to fix
it.

