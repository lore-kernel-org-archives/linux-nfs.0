Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:48811 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756030Ab1C3P6M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Mar 2011 11:58:12 -0400
Date: Wed, 30 Mar 2011 17:58:11 +0200
From: Christoph Hellwig <hch@lst.de>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Christoph Hellwig <hch@lst.de>, Jim@lst.de, "Rees <rees"@citi.umich.edu,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC] spnfs-block: restore i_op->fallocate
Message-ID: <20110330155811.GA21931@lst.de>
References: <1301500460-16467-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1301500460-16467-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Mar 30, 2011 at 05:54:20PM +0200, Benny Halevy wrote:
> spnfsd-blocks needs the old inode_operations API for fallocate
> as it does not have a struct_file in hand.
> 
> As all file systems (but xfs) currently use the struct file argument
> to get to the inode move their implementation back into a inode operation.
> Introduce generic_file_fallocate that can be used as the file_operations
> method that just does that and calls i_op->fallocate.
> 
> Refactor the xfs implementation and introduce _xfs_vn_fallocate
> that takes an addition attr_flags, which value depends on the struct file
> argument to xfs_file_fallocate.

NAK.  Not only isn't spnfsd-block not upstream, but I probably never will be
given what a piece of junk it is.

Second making fallocate a file operation was done on purpose, and all the
other filesystem need the same fix that xfs has - making the allocation
stable if done on an O_SYNC file descriptor.

