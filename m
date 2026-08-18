Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6AE2E37FF70;
	Tue, 18 Aug 2026 14:42:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787064140; cv=none; b=nQFxmIVLSv/UUb7BAonnJ9JI6aa4n1eghdVR3cltcPdTOiymfSbH43F221ml+V7JiPjtQC3STrpkRGIJvA9SSJey5NC28vC2EQl2pCV71rVw5SU+XlcjM6+O9EKURw81AonYMFEMWBZ2gKpRlKbExTz8VBBgCgFZRGeHIG1iPK8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787064140; c=relaxed/simple;
	bh=Id74b1B5cMLkkqKKwpOwPS1kDh8VNxQ3HcuAAR7EWrE=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=cySBuBw+XbVfiQTH2gNEdUIc+gFcAFBmXod+KFGE8QtnB9Wr4BKZO43PjOceljeArqayZfqKJVnX5ciQ2jO5cHImHFF6LUyiDle71W6CJNVCI1Hpacd6miCFUUjaOsJtbCkAM/a5UcVxXWGY1673bCBrkKTbggEqYm4sCaATRrE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=YPYOJ/eO; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="YPYOJ/eO"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=YQv3t7geZIzXnJjXPeFn9F+0B6WArUjYzw0LCayjqNQ=; b=YPYOJ/eOpxJPeGEIe0GboGB1Gx
	SJftE2f57AfElL0X4bUGT/aEUCDr3qLd/pgTNkdWAyHhcOYRebmapFt/NslaBAm/7N+KSvvnyzTO3
	Tm5271Jv+HXl9Vg3dW467GGAVV6dimbqngOtXpSMnBtlQLPV0DgE6xpogVOwdDUHBAyw0Cf2VwY4D
	63F8v4diJ3D4ovWP3wQJt5w8HWO/wtXt9ZpyCqNJS+fbbhFSgKrO3J0qXyrefZgWJoMXtwhkwD8CL
	XMh/1sGdbdf70nT52nsOljEI/g4w35H15pe5mGzlGHQrOhYY/2IJb9Jo5Z2S/vz0Nfcee1jiIWxE4
	D0blYKYQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wwL0r-00000008C2F-0un9;
	Tue, 18 Aug 2026 14:42:01 +0000
Date: Tue, 18 Aug 2026 07:42:01 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Ameer Hamza <ameer.hamza@truenas.com>
Cc: cel@kernel.org, jlayton@kernel.org, neil@brown.name,
	okorniev@redhat.com, Dai.Ngo@oracle.com, tom@talpey.com,
	trondmy@kernel.org, anna@kernel.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, alexander.motin@truenas.com,
	caleb.stjohn@truenas.com
Subject: Re: [PATCH 1/2] NFSD: Use nfsd_iter_read() when ->splice_read is not
 zero-copy
Message-ID: <aoRvOZTxA1kxBO9x@infradead.org>
References: <20260817210811.3984663-1-ameer.hamza@truenas.com>
 <20260817210811.3984663-2-ameer.hamza@truenas.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260817210811.3984663-2-ameer.hamza@truenas.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Tue, Aug 18, 2026 at 02:08:10AM +0500, Ameer Hamza wrote:
> For some files splicing a READ cannot avoid a copy: gfs2, kernfs
> and the cifs direct-I/O modes use copy_splice_read() as their
> ->splice_read, and the VFS substitutes it for DAX files.
> copy_splice_read() allocates a fresh page for every page of
> payload and reads into it; nfsd_splice_actor() then installs
> those pages in rq_respages, displacing Reply pages the thread
> already owns. Both sets of pages are then freed.
> 
> Route these READs through nfsd_iter_read() instead. It performs

No.  None of the above are sensible use cases for NFSD exports.
There is no good reason to add a barely maintained special code path
thae pokes into internals for this.

