Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:49705 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbaHXBdG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Aug 2014 21:33:06 -0400
Date: Sat, 23 Aug 2014 18:33:05 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org, bfields@fieldses.org, hch@infradead.org,
        cluster-devel@redhat.com, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 06/10] locks: plumb an "aux" pointer into the setlease
 routines
Message-ID: <20140824013305.GB21609@infradead.org>
References: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
 <1408804878-1331-7-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1408804878-1331-7-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 23, 2014 at 10:41:14AM -0400, Jeff Layton wrote:
> In later patches, we're going to add a new lock_manager_operation to
> finish setting up the lease while still holding the i_lock.  To do
> this, we'll need to pass a little bit of info in the fcntl setlease
> case (primarily an fasync structure). Plumb the extra pointer into
> there in advance of that.
> 
> We declare this pointer as a void ** to make it clear that this is
> auxillary info, and that the caller isn't required to set this unless
> the lm_setup specifically requires it.

Can you just return -EEXIST if reusing an existing one and make it a
normal private pointer a we use elsewhere?

Btw, two things I came up with to make the lease filesystem API nicer:

 - bypass vfs_setlease/->setlease for deletes and just call directly
   into the lease code.  no one does anything special for it (except
   cifs, which forgets about it), and then rename the method to
   ->add_lease.
 - provide a no_add_lease for nfs/gfs to centralize the no-op version
   in a single place (similar no no_lseek).

Otherwise this looks really nice.
