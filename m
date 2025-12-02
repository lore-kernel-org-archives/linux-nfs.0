Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 260472FB601;
	Tue,  2 Dec 2025 06:02:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1764655374; cv=none; b=A5Xf591ojFYzQyKyUXymowkw9jF+6L9BBiFje5/UesISaNLh/WDwVlIIcxaUTkLTDmLpKhqYU0lvBK9KdoG2hCJXQ2oy/MpR7+lQ4Y3xmExK/TnKQuzfEbnQIfpw3N6BepfvHwJzxJzks7d06QdBMzatuXzeIKkg/PXhmfPlKCw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1764655374; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=L+F9h0uuZdqxSCG+JhDW3dSa4fYwZQqW7YXFROeWIOBJELk6NdFjRrJIXxBfxtmnbO5GcJXgKp/rLcTCKBpGs9DkIboMstxGwqhV7l73a82L7Cq+t67W8NlR+/Bc9upoZ+v7i25Tu7S7Cj9M4BXlRY93tEZhiaO31ST/KRm3xTI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 8045868BEB; Tue,  2 Dec 2025 07:02:49 +0100 (CET)
Date: Tue, 2 Dec 2025 07:02:48 +0100
From: Christoph Hellwig <hch@lst.de>
To: alistair23@gmail.com
Cc: chuck.lever@oracle.com, hare@kernel.org,
	kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-nvme@lists.infradead.org, linux-nfs@vger.kernel.org,
	kbusch@kernel.org, axboe@kernel.dk, hch@lst.de, sagi@grimberg.me,
	kch@nvidia.com, hare@suse.de,
	Alistair Francis <alistair.francis@wdc.com>
Subject: Re: [PATCH v6 5/5] nvmet-tcp: Support KeyUpdate
Message-ID: <20251202060248.GB16055@lst.de>
References: <20251202013429.1199659-1-alistair.francis@wdc.com> <20251202013429.1199659-6-alistair.francis@wdc.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20251202013429.1199659-6-alistair.francis@wdc.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

