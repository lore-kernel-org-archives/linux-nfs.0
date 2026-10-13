Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 76C793ED5AC;
	Tue, 13 Oct 2026 14:38:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791902315; cv=none; b=GIX51q3tJrB9Dz6j/sVPTb3fv0WVAfBtJPccQUCUSN9F6kYSQ7GOWFP+jW1bktuM7O10e/gGeiDLTbuyAjJMGBmQWQLaKD1aDsvL4dfSYwyVd6gdmIJ3qCy91yWZTI/dC2q2HBzIJJIZcLwONHL24Nfqkh39pjBHneJ54YcfIdA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791902315; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Fn2nxabFAzZ3mD4YSanCRb2C7DndpYQOaGXa5H8LEP9jMfXjZTwkbPfmzUtlNsjYFhoe0HpnjLT1uKzLjh9ERWEHjHgqrngJqmZzTjLyWJR5X48iKLK+Vcxwa0qjIvPz2aKbJFvF0sx0qvIiP0ARJsJDWolUCu4em++AXPZ5i20=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 1BD9D227A8E; Tue, 13 Oct 2026 16:38:31 +0200 (CEST)
Date: Tue, 13 Oct 2026 16:38:29 +0200
From: "hch@lst.de" <hch@lst.de>
To: Daejun Park <daejun7.park@samsung.com>
Cc: "hch@lst.de" <hch@lst.de>, "sagi@grimberg.me" <sagi@grimberg.me>,
	"kch@nvidia.com" <kch@nvidia.com>,
	"kbusch@kernel.org" <kbusch@kernel.org>,
	"kanie@linux.alibaba.com" <kanie@linux.alibaba.com>,
	"linux-nvme@lists.infradead.org" <linux-nvme@lists.infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 1/2] nvmet: fix use-after-free of the old registrant in
 nvmet_pr_preempt()
Message-ID: <20261013143829.GA15964@lst.de>
References: <20261002065931epcms2p1cb2c16f98cf3b05f8c859ad92b0ad465@epcms2p1> <CGME20261002065931epcms2p1cb2c16f98cf3b05f8c859ad92b0ad465@epcms2p5> <20261002070200epcms2p593a0aa8ac482e776e8f1de89d9f212ae@epcms2p5>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261002070200epcms2p593a0aa8ac482e776e8f1de89d9f212ae@epcms2p5>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

