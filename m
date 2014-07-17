Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:34573 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933145AbaGQPbX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jul 2014 11:31:23 -0400
Received: by mail-qa0-f46.google.com with SMTP id v10so1949556qac.19
        for <linux-nfs@vger.kernel.org>; Thu, 17 Jul 2014 08:31:22 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 17 Jul 2014 11:31:17 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 06/10] nfsd: Protect the nfs4_file delegation fields
 using the fi_lock
Message-ID: <20140717113117.7f8ca2a9@tlielax.poochiereds.net>
In-Reply-To: <20140717145534.GA21127@infradead.org>
References: <1405521125-2303-1-git-send-email-jlayton@primarydata.com>
	<1405521125-2303-7-git-send-email-jlayton@primarydata.com>
	<20140716180943.GA6920@infradead.org>
	<20140716150401.00757454@tlielax.poochiereds.net>
	<20140717145534.GA21127@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 17 Jul 2014 07:55:34 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Wed, Jul 16, 2014 at 03:04:01PM -0400, Jeff Layton wrote:
> > Hmm...maybe. It's a very unlikely race though, and I think the same
> > sort of race exists today. In fact, it's worse today since we don't do
> > any checking of the validity of the lease after acquiring it now.
> > 
> > The flag sounds like a good idea, but the code is structured completely
> > wrong for it currently. The delegation is only hashed after we get a
> > lease, so the lease break wouldn't find anything to set a flag on.
> > 
> > Quite frankly, I _really_ do not want to have to rework the locking in
> > the delegation code yet again. I think this scheme is an improvement
> > over what we have now, even if it's not 100% perfect.
> > 
> > Once we get the scalability set done, I'd like to go back and overhaul
> > the delegation code. There are a lot of ugly warts here, but fixing
> > them is really a separate project in its own right.
> 
> But in the old code we had the client lock over all of this, right?
> 

Yes, but it's still possible for the lease to get broken after setting
it but before the delegation is hashed in the existing code. You're
correct though that another nfsd wouldn't be able to set a lease on the
same file though.

One possibility to ensure that can't happen is to check whether
fp->fi_had_conflict became true after vfs_setlease returns. That would
also obviate the need for file_has_lease. I'm still trying to figure
out whether there are potential races there with that approach though.

> Anyway, if Bruce and you are fine with this I'm not going to block it,
> although it seems a little incomplete to me.

Thanks, and I agree. I think we're going to need to revisit this area,
but I suspect we need to do some surgery to the generic lease handling
code too.

For one thing, it's a little disturbing to me that vfs_setlease returns
a pointer to the file_lock that's sitting on the i_flock list. I'm not
sure that it's a problem today, but it seems like a caller could end up
trying to use that pointer after time_out_leases has been called, or
after the lease has been otherwise deleted.

-- 
Jeff Layton <jlayton@primarydata.com>
