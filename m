Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:39882 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757382Ab3J1UAV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Oct 2013 16:00:21 -0400
Date: Mon, 28 Oct 2013 13:00:18 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <bjschuma@netapp.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/4] NFSD: Add support for WRITE_PLUS and SEEK
Message-ID: <20131028200018.GA17089@infradead.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 28, 2013 at 10:57:22AM -0400, Anna Schumaker wrote:
> Patch 3 (Add WRITE_PLUS support for hole punches) exports the do_fallocate()
> function from fs/open.c.  Should this be its own patch submitted somewhere
> else?  Is there a better way to get into the VFS fallocate routines?

Should defintively be a separate patch, and Cc linux-fsdevel on the
whole series.  Also I'd suggest to rename it to vfs_fallocate given that
it takes a file structure.

