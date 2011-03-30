Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:59037 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754815Ab1C3Rdo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Mar 2011 13:33:44 -0400
Date: Wed, 30 Mar 2011 19:33:44 +0200
From: Christoph Hellwig <hch@lst.de>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Rees <rees@citi.umich.edu>, linux-nfs@vger.kernel.org
Subject: Re: [RFC] spnfs-block: restore i_op->fallocate
Message-ID: <20110330173344.GA24631@lst.de>
References: <1301500460-16467-1-git-send-email-bhalevy@panasas.com> <20110330155811.GA21931@lst.de> <4D936453.2070501@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D936453.2070501@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Mar 30, 2011 at 07:11:47PM +0200, Benny Halevy wrote:
> Makes sense. This could also be done by adding a respective flags argument
> to fallocate and have a common wrapper function look at the file descriptor
> and call the fs fallocate, that could then get the inode rather the file.
> In other words, why copy code rather than factor it out into a common
> function?

We can discuss that _iff_ a valid use for a file-less fallocate appears
in mainline.  The pnfs-block one is not.  It's just a racy hack, which
opens gapping holes.  Take a look what it does - it allocates block for
a client to write into directly, with absolutely zero guarantee the
block allocation actually stays around until that point.

You'll need to have some outstanding token on extent map changes like
done in CXFS or NEC's "gfs" which implemented something similar to pnfs
based on nfsv3.

