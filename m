Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58054 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750912AbdBUPOI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 21 Feb 2017 10:14:08 -0500
Date: Tue, 21 Feb 2017 10:14:06 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, Jeff Layton <jlayton@poochiereds.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>, stable@kernel.org
Subject: Re: [PATCH] nfsd: special case truncates some more
Message-ID: <20170221151406.GA2355@parsley.fieldses.org>
References: <20170220062133.26607-1-hch@lst.de>
 <20170220062133.26607-2-hch@lst.de>
 <5B8D7C50-70C3-43F8-B8D6-0B845B84D5F2@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5B8D7C50-70C3-43F8-B8D6-0B845B84D5F2@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 21, 2017 at 10:07:51AM -0500, Chuck Lever wrote:
> 
> > On Feb 20, 2017, at 1:21 AM, Christoph Hellwig <hch@lst.de> wrote:
> > 
> > Both the NFS protocols and the Linux VFS use a setattr operation with a
> > bitmap of attributs to set to set various file attributes including the
> > file size and the uid/gid.
> > 
> > The Linux syscalls never mixes size updates with unrelated updates like
> > the uid/gid, and some file systems like XFS and GFS2 rely on the fact
> > that truncates might not update random other attributes, and many other
> > file systems handle the case but do not update the different attributes
> > in the same transaction.  NFSD on the other hand passes the attributes
> > it gets on the wire more or less directly through to the VFS, leading to
> > updates the file systems don't expect.  XFS at least has an assert on
> > the allowed attributes, which caught an unusual NFS client setting the
> > size and group at the same time.
> > 
> > To handle this issue properly this splits the notify_change call in
> > nfsd_setattr into two separate ones.
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > Cc: stable@kernel.org
> 
> Tested-by: Chuck Lever <chuck.lever@oracle.com>

Thanks.--b.
