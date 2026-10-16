Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D4161420E89
	for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 12:56:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792155387; cv=none; b=sCHz0M+l1VsuVOKbyfcfdiYMYCQQ+MK/GERusZ3oBiodAT3jRSKMKN8MYlvw20kYkw2fyCJTVrJLRocGUAdmWL1NS87Krm5VaNn0vS483g+gB7eVw6fMZFAf2zePzGV0H07b6MLIpUp5Rr7PfAAE8O+x/puQE5PvIvMWbpgobYw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792155387; c=relaxed/simple;
	bh=jc4gOYsUg2NdNwof8dgjiS17Gqhr7MeFZ91dnFY3oo4=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=hAwZar0YMIqtIAvEGiti2zwyAYrwH9QHgxnoRg+SmDa29ByM23UjRH++9ElfZ42iW7qdAcK9cEEBeoDqXhGI2x/KxUtC+lgKY/fwq2o3IpfISj22OTgrvjssEWOPFSj0BX6KOp/01Pe+WszlflXyVk21OF8rR1ehqA+KxzQV3HE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 23C4268C4E; Fri, 16 Oct 2026 14:56:21 +0200 (CEST)
Date: Fri, 16 Oct 2026 14:56:20 +0200
From: Christoph Hellwig <hch@lst.de>
To: Benjamin Coddington <ben.coddington@hammerspace.com>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org, Daejun Park <daejun7.park@samsung.com>,
	Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/2] pnfs/blocklayout: report data lost to a failed
 LAYOUTCOMMIT
Message-ID: <20261016125620.GB5871@lst.de>
References: <cover.1792097970.git.bcodding@hammerspace.com> <735df39cfa1873f3ed5b20702fb7d7a79cf49fba.1792097970.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <735df39cfa1873f3ed5b20702fb7d7a79cf49fba.1792097970.git.bcodding@hammerspace.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Fri, Oct 16, 2026 at 07:36:39AM -0400, Benjamin Coddington wrote:
> From: Benjamin Coddington <bcodding@hammerspace.com>
> 
> Data written through a block or SCSI layout into PNFS_BLOCK_INVALID_DATA
> extents stays unwritten on the server until a LAYOUTCOMMIT converts
> those extents.  When the LAYOUTCOMMIT fails, ext_tree_mark_committed()
> tags the extents written again so that a later LAYOUTCOMMIT can cover
> them, and reports nothing.  nfs4_layoutcommit_done() also zeroes the
> task status for NFS4ERR_BADLAYOUT, NFS4ERR_BADIOMODE,
> NFS4ERR_DELEG_REVOKED and NFS4ERR_GRACE, so a synchronous LAYOUTCOMMIT
> returns 0 for those.  A server that has revoked the layout answers
> NFS4ERR_BADLAYOUT; once the client drops that layout its extent tree
> goes with it, and fsync() and close() have returned 0 for data that
> reads back as zeroes.
> 
> When ext_tree_mark_committed() puts extents back, record -EIO in the
> mapping's writeback error and the superblock's, and have
> pnfs_generic_sync(), which only the block and SCSI layouts use, return
> an error recorded during its LAYOUTCOMMIT.  The files and flexfiles
> layouts, whose LAYOUTCOMMIT does not decide what a read of the file
> returns, are unchanged.

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

Should pnfs_generic_sync move into the blocklayout code as that is
the only user and it thus isn't exactly overly generic?

