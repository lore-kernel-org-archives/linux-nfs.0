From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [GIT] Please pull NFS client fixes against linux-2.6.25-rc8
Date: Wed, 9 Apr 2008 04:24:08 -0400
Message-ID: <20080409082408.GA17458@infradead.org>
References: <1207703414.21370.1.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:56340 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465AbYDIIYN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Apr 2008 04:24:13 -0400
In-Reply-To: <1207703414.21370.1.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +#ifdef CONFIG_MMU
>  	.mmap		= nfs_file_mmap,
> +#else
> +	.mmap		= generic_file_mmap,
> +#endif

This is with almost 100% chance wrong.  It might get you a kernel that
compiles but none where mmap actually works.  Just disable mmap on nfs
for mmu-less systems until someone hacks up a proper mmu-less mmap
method for nfs.
