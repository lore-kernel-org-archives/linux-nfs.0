Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:42596 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753371Ab3KEJhE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Nov 2013 04:37:04 -0500
Date: Tue, 5 Nov 2013 01:37:00 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <bjschuma@netapp.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] NFS: Use WRITE_PLUS for hole punches
Message-ID: <20131105093700.GA31277@infradead.org>
References: <1382972418-2249-1-git-send-email-bjschuma@netapp.com>
 <1382972418-2249-2-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1382972418-2249-2-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 28, 2013 at 11:00:16AM -0400, Anna Schumaker wrote:
> +	struct nfs42_write_plus_args args = {
> +		.wp_fh		= NFS_FH(inode),
> +		.wp_stable	= NFS_FILE_SYNC,
> +		.wp_content	= NFS4_CONTENT_HOLE,
> +		.wp_offset	= offset,
> +		.wp_length	= len,
> +		.wp_allocated	= (mode == 0),
> +	};

After spending some time with draft 21 of the NFSv4.2 spec I don't think
we can use WRITE_PLUS for the prealloc mode of fallocate.  The problem
with the NFS4_CONTENT_HOLE arm of WRITE_PLUS is that it is defined to
zero the whole range, while fallocate is defined as being a no-op for
parts of the range that already contain data.  

In addition we'll also need more sanity checks on the flags argument,
there already is a FALLOC_FL_KEEP_SIZE not supportable by the NFS
semantics (not that it nessecarily should), and more may be added
in the future.  Take a a look at the other fallocate implementations tha
t have a quick check on the top for flags they don't support:

	if (mode & ~(FALLOC_FL_KEEP_SIZE | FALLOC_FL_PUNCH_HOLE))
		return -EOPNOTSUPP;

