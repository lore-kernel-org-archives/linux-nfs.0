Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:54998 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753207AbaIIP41 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2014 11:56:27 -0400
Date: Tue, 9 Sep 2014 08:56:26 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna.Schumaker@netapp.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] nfsd: Add DEALLOCATE support
Message-ID: <20140909155626.GC21928@infradead.org>
References: <1410274182-30740-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1410274182-30740-4-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1410274182-30740-4-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -	status = nfsd4_vfs_fallocate(&cstate->current_fh, file,
> +	status = nfsd4_vfs_fallocate(&cstate->current_fh, file, false,
>  				     allocate->alloc_offset,
>  				     allocate->alloc_length);

Maye just pass the normal Linux fallocate flags to nfsd4_vfs_fallocate
for future extensibility?

Otherwise looks as good as the previous one.

