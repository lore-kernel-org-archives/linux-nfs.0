Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:40721 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753327AbcHANar (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Aug 2016 09:30:47 -0400
Date: Mon, 1 Aug 2016 06:30:46 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        Trond.Myklebust@primarydata.com
Subject: Re: [PATCH v4 0/3] NFSv4.2: Add support for the COPY operation
Message-ID: <20160801133046.GB26191@infradead.org>
References: <1461962533-26534-1-git-send-email-Anna.Schumaker@Netapp.com>
 <20160501173733.GA556@infradead.org>
 <20160513203135.GE5658@fieldses.org>
 <8d09611c-31c1-baca-8e8f-6dc599731c8c@Netapp.com>
 <20160729185933.GA7964@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160729185933.GA7964@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 29, 2016 at 02:59:33PM -0400, J. Bruce Fields wrote:
> > > I don't see any obvious problem with the nfsd code, other than the
> > > obvious issue with large synchronous copies tying up server threads and
> > > leaving clients waiting--but maybe we should just see how people end up
> > > using it and deal with the problems as they come up.
> 
> I'm still worrying about this, though.
> 
> As a simple stopgap, could we just set *some* maximum on the size of the
> copy?  Or better yet on the time?--that'd let filesystems with
> clone-like features copy the whole file without blocking an nfsd thread
> indefinitely in the case of other filesystems.

I'm still really worried about corner cases in the copy_file_range
syscall and the COPY nfs implementation.  When Darrick implemented
xfstests support for clone we found various bugs in the existing
implementation and corner cases handled different by xfs/btrfs/nfs and
the documentation.  I'd really like to see something similar for
the copy side.  Especially as clone should always be a valid
implementation for copy as well.
