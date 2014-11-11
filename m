Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33214 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752038AbaKKVmI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Nov 2014 16:42:08 -0500
Date: Tue, 11 Nov 2014 16:42:06 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd: implement chage_attr_type attribute
Message-ID: <20141111214205.GG20062@fieldses.org>
References: <1415448664-25815-1-git-send-email-hch@lst.de>
 <1415448664-25815-3-git-send-email-hch@lst.de>
 <20141110175424.GC32702@fieldses.org>
 <20141111102735.GB17313@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141111102735.GB17313@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 11, 2014 at 11:27:35AM +0100, Christoph Hellwig wrote:
> On Mon, Nov 10, 2014 at 12:54:24PM -0500, J. Bruce Fields wrote:
> > Shouldn't that be NFS4_CHANGE_TYPE_IS_MONOTONIC_INCR?
> > 
> > The draft says that e.g. "If the client sees
> > NFS4_CHANGE_TYPE_IS_VERSION_COUNTER, it has the ability to predict what
> > the resulting change attribute value should be after a COMPOUND
> > containing a SETATTR, WRITE, or CREATE."
> > 
> > Admittedly, I'm not completely sure what that means.  (Is a SETATTR of
> > multiple attributes a single atomic change?  Can we predict the change
> > attribute on a newly created file, or only on the parent directory?)  I
> > also don't know where the filesystems do the i_version increment (can we
> > guarantee it happens once per nfs WRITE?).
> 
> Actually the server may increment it many times for a single WRITE,
> for XFS it is incremented for each dirty transaction, which could
> happen many times during a single write:
> 
>  (1) c/mtime update
>  (2) suid/sgid bit removal
>  (3) block allocation (could be multiple transactions)
> 
> 
> So I guess we really should move to NFS4_CHANGE_TYPE_IS_MONOTONIC_INCR
> instead.

I'm applying your patch for 3.19 with that one-line change.

--b.
