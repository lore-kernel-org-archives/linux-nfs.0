Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50762 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753624AbdF2Pqv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 29 Jun 2017 11:46:51 -0400
Date: Thu, 29 Jun 2017 11:46:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: trond.myklebust@primarydata.com, jlayton@poochiereds.net,
        schumaker.anna@gmail.com, linux-nfs@vger.kernel.org
Subject: Re: open by handle support for NFS V2
Message-ID: <20170629154650.GC1651@fieldses.org>
References: <20170629133453.19641-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170629133453.19641-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 29, 2017 at 06:34:49AM -0700, Christoph Hellwig wrote:
> this resurrects parts of an old series to add open by handle support to
> NFS.  The prime intent here is to support the actual open by handle
> ioctls, although it will also allow very crude re-exporting.  Without
> the other patches from Jeff's series that re-exporting will suck badly
> though.

Why do we want this?

Any re-export support is going to have some major limitations.  (No file
locking, and re-export of NFSv4 probably not possible?)

Last I heard the only motivation was extremely specific to Primary
Data's setup.  I'm happy to help them, but I think we need *some*
evidence this will be useful to upstream users.

--b.
