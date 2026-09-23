Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AAC4128B4FA
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 04:40:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790138457; cv=none; b=M/SSQLnyt7ovQ2xiL7lIryoowHP4vUWCZwwdDmPyDoZJfsFa2IWhmzOR1hWHIftafW2jLPbTmB24Awi1ALWtHHDvpuiWKZcYe+yVW2kg8Qr4b+xnosE2E9RjDEJliEtv2trPR/IVBcmkmRqIQC7zJjbRV6w47n7y4SjU+npUs5w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790138457; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=oFIcsLSeLtkfNRzmQad+lkUlP/Mle9zwmYP5BGilkNxYcADKo/P+KTmwJmr06xv1gKj7mTvZxfw0A8JRVVGU/LzBO7fGox8xgi2Ap1O2UI7VFAu4D6t0XMs8tKQPG9s5XpuMjuQeNzkmVmJKUpfGYLbzNyZ9TSfIRcMGdVEqOyM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=OPRANCzb; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="OPRANCzb"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=; b=OPRANCzb9Jw1Cti3ESp5XcuGJs
	wsTLT18RKzD8b+tpKK8+TXpqMwR/9bUfPV+GoorKmPb0S8GSq5y2CngtVT+TfMuuBzLw5SikUYHSv
	iChsM61uy9a6GNmHfEAl/HyP3psJhB7Qgckig1dwcN3AklBD82MDp3ctnozhw+OaSlKSs86K5Q9mv
	lnLNshlxIMuVTlymdFyjRAlezoW/XIemwpLtyf884XFjLzUFriTNr58g6uavuOUGZ/yF995GTWiv4
	YDbxZOD3WGizplf5uY+w3GaV9grpfyV7VUTpqs4Dxm4dr33VqxpiVdO5U6c2LI4Z/57FAI7zVfP59
	WHc9It0Q==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1x9Ems-000000077oP-0Qr4;
	Wed, 23 Sep 2026 04:40:54 +0000
Date: Tue, 22 Sep 2026 21:40:54 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Scott Mayhew <smayhew@redhat.com>
Cc: trondmy@kernel.org, anna@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3] nfs: split up block layout and SCSI layout support
Message-ID: <arNYVnnxlSXiLtq4@infradead.org>
References: <20260922182436.957454-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260922182436.957454-1-smayhew@redhat.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>
