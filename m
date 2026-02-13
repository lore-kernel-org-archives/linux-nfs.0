Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 56DB31DE8BF;
	Fri, 13 Feb 2026 06:24:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770963886; cv=none; b=eSefSsEbyuwLlzqyhDUmJGTpn5yMxICmDkApK4VDRTNT12bVWtR75fWbW1VM4c/3lP6KXNYnMCU2Zn6nnYKdmETAtofFtNKh+AAXFeTiB1aIG1VCeEbGC1Iuln5pxafGRIzo2MMDsn9a2pb5/wmQMniy3UpFZMOwVFeCAzKS+Lw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770963886; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=UVeXu7wGGfqSN51q0g9U261uRRolbPkT09wGdFab0swDlg2fYBhPFU3ovtedk9vV71GuBhxGKM34DYn384Y0nl0t1a0OLexw1TMfcffLvIvbhWUy7zAR5CqvpUcXPDuqa4iG034HGFYEuRBv5ivOVkAr5kOyHnM3zQgwD2Bwh8c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 4017668B05; Fri, 13 Feb 2026 07:24:35 +0100 (CET)
Date: Fri, 13 Feb 2026 07:24:35 +0100
From: Christoph Hellwig <hch@lst.de>
To: Kundan Kumar <kundan.kumar@samsung.com>
Cc: jaegeuk@kernel.org, chao@kernel.org, agruenba@redhat.com,
	trondmy@kernel.org, anna@kernel.org, hch@lst.de, brauner@kernel.org,
	jack@suse.cz, viro@zeniv.linux.org.uk, djwong@kernel.org,
	jlayton@kernel.org, linux-f2fs-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, gfs2@lists.linux.dev,
	linux-nfs@vger.kernel.org, gost.dev@samsung.com,
	anuj20.g@samsung.com, vishak.g@samsung.com, joshi.k@samsung.com
Subject: Re: [PATCH v2 0/4] Avoid filesystem references to writeback
 internals
Message-ID: <20260213062435.GA27228@lst.de>
References: <CGME20260213055123epcas5p25f52d5961c04b1a1f514827a494a0773@epcas5p2.samsung.com> <20260213054634.79785-1-kundan.kumar@samsung.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260213054634.79785-1-kundan.kumar@samsung.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

