Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:16573 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751473Ab1K3TZ3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Nov 2011 14:25:29 -0500
Date: Wed, 30 Nov 2011 14:25:05 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Malahal Naineni <malahal@us.ibm.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: only do COMMIT for range written with direct I/O
Message-ID: <20111130142505.65c738e1@tlielax.poochiereds.net>
In-Reply-To: <20111130145657.GA7883@us.ibm.com>
References: <1322662074-3843-1-git-send-email-jlayton@redhat.com>
	<20111130145657.GA7883@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 30 Nov 2011 08:56:57 -0600
Malahal Naineni <malahal@us.ibm.com> wrote:

> Jeff Layton [jlayton@redhat.com] wrote:
> > When given a range to write with unstable writes, the current code
> > always does a COMMIT of the entire file afterward. This is potentially
> > expensive on some servers and unnecessary. Instead, just do a COMMIT for
> > the offset and count that was written.
> > 
> > Khoa, who reported this bug, stated that this made a big difference in
> > performance in their environment, which I believe involves GPFS on the
> > server. He didn't pass along any hard numbers so I can't quantify the
> > gain, but it stands to reason that clustered filesystems might suffer
> > more contention issues when issuing a commit over the whole file.
> > 
> > Reported-by: Khoa Huynh <khoa@us.ibm.com>
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/nfs/direct.c |    6 ++++--
> >  1 files changed, 4 insertions(+), 2 deletions(-)
> > 
> > diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> > index 1940f1a..33f2be7 100644
> > --- a/fs/nfs/direct.c
> > +++ b/fs/nfs/direct.c
> > @@ -77,6 +77,7 @@ struct nfs_direct_req {
> >  	/* completion state */
> >  	atomic_t		io_count;	/* i/os we're waiting for */
> >  	spinlock_t		lock;		/* protect completion state */
> > +	loff_t			pos;		/* offset into file */
> 
> Why not call it "offset"?

Why should we call it "offset"? The rest of the code refers to this
value as "pos". Essentially this patch replaces a field that was
removed from this struct several years ago. At the time, that field was
also called "pos".

> Should we set this to zero in
> nfs_direct_req_alloc (just like count is set to zero there)?
> 

Yes, that certainly wouldn't hurt. I'll plan to add that into the next
respin which I'll plan to send out once I've collected some more
feedback.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
