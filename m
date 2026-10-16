Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6C677371D01
	for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 12:54:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792155282; cv=none; b=tahaUIuLaEKtyMFE4kFxxkhrAEh/A38Uo+7DqL3CwzSBgqsakafGizy9SGjn8u7qGOmmcWkiUtQPai9COSEX7jmC0Z9oZvMz6o/EPZe7gNTUyZN7mGG48Pnhs/Wjhq0Sgv5ggO/PO+nlE9ciTFRPikTF/eH/FNkrlmhEo+Cc178=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792155282; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=DSErUqcUjPerE7sRPTvxT/lZgn2WXcbX4iHzKuRTKbkjmApEBZzpK8Quw7wjBEPzkBX62j5QcH7dWBkgh5UTRZpOk/X+hV7OTG33AGyPPUFq1zeqlX4ce4S4sTpO2Aoy24TY3WjkBCITMp0b7lm51OLK/gKXH/skTDHxv3ifcjw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 1BB0A68C4E; Fri, 16 Oct 2026 14:54:37 +0200 (CEST)
Date: Fri, 16 Oct 2026 14:54:36 +0200
From: Christoph Hellwig <hch@lst.de>
To: Benjamin Coddington <ben.coddington@hammerspace.com>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org, Daejun Park <daejun7.park@samsung.com>,
	Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/2] pnfs/blocklayout: don't mark extents committed
 after a failed LAYOUTCOMMIT
Message-ID: <20261016125436.GA5871@lst.de>
References: <cover.1792097970.git.bcodding@hammerspace.com> <8b5b2e8ecc7e1150c9b4505d1094da893db2e1a6.1792097970.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8b5b2e8ecc7e1150c9b4505d1094da893db2e1a6.1792097970.git.bcodding@hammerspace.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

