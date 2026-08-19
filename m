Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 03C1F3CB546;
	Wed, 19 Aug 2026 06:02:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787119377; cv=none; b=H2Sniw0UBLnxYlRPkMFWAZ2FGeX6KqCSnYCIdU+afYjn/zVpq9qICYtobNqgjq5bJH3ehJ8Ta2gIiIgIMePK9TdOcW1L1N5OMe75zC2ISsx//hPNijcvDpm3D/wYfGJTfDq7OGzn/vbi/eXWu3D7e6Tk9yx1yVkvhcNBiMXndB4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787119377; c=relaxed/simple;
	bh=VnWGsUe8nYajKgB9OTaJ0hg62Z4NTe0MX04Y7k0cxG8=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=W2Yhay/nzInNMxQZRkdi/j/U6jOWR1dSKMX0FVco1GB9SWC2ThLDiVhEbB4GvmnwmuGqd2oidAmtyKX9QmiRCpwQjMPQybHuiFfZdyYYP3AnxaCxRFb+02Wl1kxxRWo9+NmK572DxDMzhIg9oY/8B2IGXUwtB2FGIOGR4f/PE8o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=ZhTkCPj3; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ZhTkCPj3"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=HNztdT4bqAJDFiSjduNFZDzOpvwoP++R/MUoamuhs4w=; b=ZhTkCPj3E5KEIjk+8eooUpL9jK
	jG9n8yEsCtaYjXPr7CmDXopOuSpDidjvVnPpHPVKkqQOeDjzoUjXX+Qqz2zQVOjG5dpGlUQ9j1Z+e
	EopO/ggbO7j6aQr22BPz6hTr7KkQHsoV1MVq1IQi0q28AHDYkIz4JlPU+01g3YRuIbPSqFs753Wo5
	vDnvHknE3kZbpuoYGVnDcsk7owvFqUb8hjvQ6DzwPfyp664Fs31dz+CJ+kwQB777b25x6GL04MZe5
	erzLXKssYkwE0uovPxMwuys1fxHqIaLr53dSR+KvTOJsVNJxF0ff9ZYP/uLWS55UscJDmZlScDXXH
	kVgYT46g==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wwZNu-000000093kl-1aCZ;
	Wed, 19 Aug 2026 06:02:46 +0000
Date: Tue, 18 Aug 2026 23:02:46 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Ameer Hamza <ameer.hamza@truenas.com>
Cc: cel@kernel.org, jlayton@kernel.org, neil@brown.name,
	okorniev@redhat.com, Dai.Ngo@oracle.com, tom@talpey.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Kara <jack@suse.cz>, Amir Goldstein <amir73il@gmail.com>
Subject: Re: [PATCH 1/2] NFSD: Fix duplicate fsnotify access events for
 iterator READs
Message-ID: <aoVHBkmPNSRakbYW@infradead.org>
References: <20260818225715.572140-1-ameer.hamza@truenas.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260818225715.572140-1-ameer.hamza@truenas.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Wed, Aug 19, 2026 at 03:57:14AM +0500, Ameer Hamza wrote:
> NFSD_IO_DIRECT modes do. Spliced READs are not affected, since
> splice_direct_to_actor() emits no event and nfsd_finish_read()
> emits their only one.

Well, that is the underlying bug here.  ->splice_read should not
skip fsnotify events and nfsd should not work around this as
fsnotify is not the business of the users of VFS APIs.

