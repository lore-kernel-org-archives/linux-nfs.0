Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CA0712EEE79;
	Wed,  2 Sep 2026 05:31:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788327122; cv=none; b=b5mBOVlpeK6xu4J6ja3TUHlARtcExjkrGG8GvSBulvwb+qb/lAj0tolroq5xMwp5eLpqRZrA6eUzkB6ChgDLP+nDdY6DXm1j9I3B4YmIMzk2pAKOVs0VvPKUpF/WQ51qAEGPGIVaT+bpBPqZQyrjyxzEHvc89lCOsPho6lIkLdk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788327122; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Ektz5bMnnjjVR5D//xYCUx7fhTsp+LqngvjvF8YOYpxWXtHTxJWOl2aHKh4mHrGH2uIzOZgHFMDLd6XZNEcMYG0Yad0x/TKLgJkm8K3TPIRUMUHd3RiN9p8B9Yl9Bnzjh/tTX9agmcMZUulR7IoIpojJsvE9NjkdsGMFreUAnbQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=D9h7Vf81; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="D9h7Vf81"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=; b=D9h7Vf81jdtJ9zUr9DgBJCLBL4
	a3k2IOs2xkayeL7NrbzjFpgj3E8cFJ+qaDorSlqo9ysHX6JY10AHJZYtf3eHfyBmFZzg/2kPx0a1C
	t9iXozcJ1jXdp5ayl2cNSJV20VMW5/mXjD9sBoW8a4YvoOr9iltzxhx9jQYPR5OgwxoeOw4fy29IF
	lv/euZJdBb+QBRiOj+GMdzDVcfOhx2OXZZ9tzEtYJwNomle3L5mO8/jDxpWlRw+dE7kE4rfpvuiN5
	N5mJHbfVIOnQwIHhd5RGgIwVotn0xYiw5dIAnRMi5H+IavUOOWZp58gQlcbch63xNgq/YHaVXEtGj
	EY8yy2Hw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1x1dZk-0000000Do5U-0hod;
	Wed, 02 Sep 2026 05:31:56 +0000
Date: Tue, 1 Sep 2026 22:31:56 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <cel@kernel.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	Ameer Hamza <ameer.hamza@truenas.com>,
	Amir Goldstein <amir73il@gmail.com>
Subject: Re: [PATCH v2] splice: emit a single fsnotify access event per NFSD
 READ
Message-ID: <ape0zOxQ27heB40D@infradead.org>
References: <20260901135329.487666-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260901135329.487666-1-cel@kernel.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>
