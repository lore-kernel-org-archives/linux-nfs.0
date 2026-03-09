Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D4CC531B83B
	for <linux-nfs@vger.kernel.org>; Mon,  9 Mar 2026 15:34:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773070501; cv=none; b=S10qxdfK4TcqYgXYFGUG447VuNx3rnJ0vkB2w7KE/fbWUPVkGAcOcI0OoMwoKgjzNVO34iSarqYTsMLncKsLdmvjO9V7hfNefv/AM/CoVCI2AewvaWAYLgBZIFjq5Odk/iWTLfmMd3sUw/LXQERIJt7mmCkLDX5IvtDbVWCentM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773070501; c=relaxed/simple;
	bh=427ZvkUzVFFMvLThem11YuzJa7D/URZN2wzzZ2NA6rI=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=TISu6pd3Unx1yqf5zQ6bvLNVsHCenAmdCn26atb0YWVbQXjvFFB69ODUT0URyfR10heGhveYgKcIhsrXYvDfR7D4p4hOtr6ESXrhRuuBjNB9KL5GJdLns1l4gyKLqPwblzG8aHCXtDyz50/9A2hAOxS+4/PeUvCpkqCdEHX3Sqo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=aO+0eyf9; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="aO+0eyf9"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=Wdnk2OX0s7DvB+szi06A6oToFWqEgGCa3+gaJdSwiPY=; b=aO+0eyf9NKRZFEf/3abap9ckzr
	9axr3TwECFug2xq9K5tM/Meo13QxXNn3+APKB2YCMTG9OjxOSrOA+a4HBkzSEghO9TkgjRR3ZfoLy
	Afe6kYfpPWKpXH4ZLrbPCcRr0I7VVNs/VSEwfpptHg9+Dbacjode2UKaTaT9+2dYkTe6aYAfCVCmZ
	7k8JNcy1WIqopPKXAYyb4a2NQgUAddlh6NlJOdidoqX/OaES3evHzXBE+Hasngba/dWSPyWK2f96k
	xsEN29wOESSQnRX3gYNjJi4YqMmUIQnmfTUmK1uFKwn6o9aXmBVVjNjp2K37NCr3H6zAE9x+JiLDh
	OqyrTedw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.98.2 #2 (Red Hat Linux))
	id 1vzcdH-00000007cN2-1khe;
	Mon, 09 Mar 2026 15:34:59 +0000
Date: Mon, 9 Mar 2026 08:34:59 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Dai Ngo <dai.ngo@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
	Trond Myklebust <trondmy@kernel.org>, anna@kernel.org
Subject: Re: [PATCH v3 1/1] pNFS: Serialize SCSI PR registration to avoid
 reservation conflicts
Message-ID: <aa7oo3sOTe-WKjVl@infradead.org>
References: <20260306162927.3276695-1-dai.ngo@oracle.com>
 <fc0a566a-9cba-4fd0-99a0-d7fb7043a77b@oracle.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fc0a566a-9cba-4fd0-99a0-d7fb7043a77b@oracle.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Fri, Mar 06, 2026 at 10:46:00AM -0800, Dai Ngo wrote:
> Christoph,
> 
> The new mutex, pbd_registration_mutex, is initialized only for the
> top-level pnfs_block_dev in this patch. The mutexes for child pnfs_block_dev
> instances allocated by bl_parse_concat() and bl_parse_stripe() are not
> initialized.
> 
> Should we initialize these child mutexes as well, in case we later want
> to support concatenated and striped SCSI devices for pNFS?

I don't think we need to, as the registration would happen on the
actual SCSI devices, not the meta devices.

