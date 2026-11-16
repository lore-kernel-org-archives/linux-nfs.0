Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794811704;
	b=iBLcuZp1pJjPAA6jKqFCVxggmq2YC3YGgNtGzMHdEJffFPwaRLY7DDmgSYHNkCf2xcTv
	 XCwCgt2wU0WM2ahp4LT+Wv6pIEgz5R6xIcZnMkVhiz7SljIYzVS4G8o4ECKVUm5V8r6+k
	 dJ40zJamOuJtR6HYRDRrK1fLlDYJEDlzF7brXeq8xVLARGx45XvKeGq2N+/Va6vcr/J/X
	 ZV2kYWqWRA5LJwHUdsYnxHZo3QS2CdtuQlqeC9UWRNvuq6Q/i8OYcjCya0L78JxnnhpDS
	 jgHlzkFKSU1NM6KubRWF7KjeiyWT9yPr+YlwcwmLfl44PpedMpGB8+YGuYnr9egOxkw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794811704;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=AQ2NoHNfE6JuTHElpIAm4hcefTgCPppw1N23euXgdyE=;
	b=bKVqyKNp/KhkZPs5PeT6uVx/bUQm5BjLjqnOV/y0sHxjkQnOQ+KYzCuPpPzb+HHeFKqd
	 +bQ3BccFv/KPAEvgmiP61XGBKIM9DihRJWq764JLgPRt/3V3e1+XZAteavOE7ImVswoP2
	 xwOLb1BL0NL3RQlf8JwfVsNogbCjRm+PFBqEy9YvdYi85mkXFn3DNIAd/WVNXOYkr2m66
	 VWKOaRPYd+V/6af+MpNZhI24fFKXFvwjF5g5Lr0pIJPDOKq3ywzBRA1qb1QkQLnX7UY7p
	 MCjdppaXwnjjxbQLmMb7OMiQTj9CH8gqkeM9JRU+Q7DlyPcpp4rAishx9fvEbYWJ0DQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 503F1606A31C;
	Mon, 16 Nov 2026 06:48:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 503F1606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id EAFB168B05; Mon, 16 Nov 2026 07:48:20 +0100 (CET)
Date: Mon, 16 Nov 2026 07:48:20 +0100
From: Christoph Hellwig <hch@lst.de>
To: Christian Brauner <brauner@kernel.org>
Cc: Jan Kara <jack@suse.cz>, Shakeel Butt <shakeel.butt@linux.dev>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jens Axboe <axboe@kernel.dk>, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, io-uring@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>, linux-block@vger.kernel.org,
	linux-nvme@lists.infradead.org, linux-scsi@vger.kernel.org,
	target-devel@vger.kernel.org, linux-unionfs@vger.kernel.org,
	bpf@vger.kernel.org, linux-nfs@vger.kernel.org,
	stable@vger.kernel.org
Subject: Re: [PATCH 07/12] zloop: take freeze protection when recording
 write pointers
Message-ID: <20261116064820.GB2964@lst.de>
References: <20261114-work-fs-frozen_writes-v1-0-f5ae61c898b1@kernel.org> <20261114-work-fs-frozen_writes-v1-7-f5ae61c898b1@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261114-work-fs-frozen_writes-v1-7-f5ae61c898b1@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

Can we get some kind of debug check into vfs_setxattr to enforce
callers have taken the write protection?

