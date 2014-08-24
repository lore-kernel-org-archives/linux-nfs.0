Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f45.google.com ([209.85.213.45]:61279 "EHLO
	mail-yh0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752416AbaHXKIE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Aug 2014 06:08:04 -0400
Received: by mail-yh0-f45.google.com with SMTP id 29so10181075yhl.32
        for <linux-nfs@vger.kernel.org>; Sun, 24 Aug 2014 03:08:04 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Sun, 24 Aug 2014 06:08:01 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, bfields@fieldses.org,
        cluster-devel@redhat.com, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 06/10] locks: plumb an "aux" pointer into the setlease
 routines
Message-ID: <20140824060801.5402880c@synchrony.poochiereds.net>
In-Reply-To: <20140824013305.GB21609@infradead.org>
References: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
 <1408804878-1331-7-git-send-email-jlayton@primarydata.com>
 <20140824013305.GB21609@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 23 Aug 2014 18:33:05 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Sat, Aug 23, 2014 at 10:41:14AM -0400, Jeff Layton wrote:
> > In later patches, we're going to add a new lock_manager_operation to
> > finish setting up the lease while still holding the i_lock.  To do
> > this, we'll need to pass a little bit of info in the fcntl setlease
> > case (primarily an fasync structure). Plumb the extra pointer into
> > there in advance of that.
> > 
> > We declare this pointer as a void ** to make it clear that this is
> > auxillary info, and that the caller isn't required to set this unless
> > the lm_setup specifically requires it.
> 
> Can you just return -EEXIST if reusing an existing one and make it a
> normal private pointer a we use elsewhere?
> 

That sounds a little confusing...

We have two pointers we pass down to generic_setlease: the file_lock
itself and with this patch, the "aux" pointer. We can end up using
either, neither or both during a call to generic_setlease.

A simple error code can't properly indicate which of the two pointers
got used. It might be clearer to turn the file_lock into a normal
pointer and return -EEXIST if we reused it, but leave aux as a double
pointer.


> Btw, two things I came up with to make the lease filesystem API nicer:
> 
>  - bypass vfs_setlease/->setlease for deletes and just call directly
>    into the lease code.  no one does anything special for it (except
>    cifs, which forgets about it), and then rename the method to
>    ->add_lease.
>  - provide a no_add_lease for nfs/gfs to centralize the no-op version
>    in a single place (similar no no_lseek).
> 
> Otherwise this looks really nice.


Both of those sound good. I'll plan to roll those changes in with the
next iteration.

Thanks!
-- 
Jeff Layton <jlayton@primarydata.com>
