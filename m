Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f42.google.com ([209.85.216.42]:39162 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751205AbaGJNXm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 09:23:42 -0400
Received: by mail-qa0-f42.google.com with SMTP id j15so1364736qaq.1
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 06:23:41 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 10 Jul 2014 09:23:37 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 003/114] nfsd: wait to initialize work struct just
 prior to using it
Message-ID: <20140710092337.3eac8aa0@tlielax.poochiereds.net>
In-Reply-To: <20140710105343.GB21461@infradead.org>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
	<1404143423-24381-4-git-send-email-jlayton@primarydata.com>
	<20140708211133.GA26851@fieldses.org>
	<20140709082121.GA30099@infradead.org>
	<20140709194114.GC26851@fieldses.org>
	<20140709163744.1aa6126c@tlielax.poochiereds.net>
	<20140710105343.GB21461@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 10 Jul 2014 03:53:43 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> > Unfortunately there are a few (fairly trivial) merge conflicts later in
> > the series due to this change. Bruce, do you want me to repost the
> > whole set, or would you rather just cherry-pick them from my updated
> > branch?
> 
> Can you resend just the whole fi_fds and access/deny mode patches as a
> series for the next step?  This seems useful and complicated enough to
> do a standalone review.  I also don't think the additional few spinlocks
> would have enough performance impact to avoid them until the big client
> lock is gone, although all those logic changes could probably be done
> easily enough without the new locking if someone cared enough (I don't).
> 

Yes, that sounds reasonable. I'll go ahead and move the patches
necessary for it to the front of the series and address your comments
and we can see about getting them merged ahead of the rest.

I agree that the extra spinlocking probably won't matter while the
client_mutex is in play. If it does, then not needing to walk the whole
stateids list in order to do deny mode enforcement may help make up for
it.

-- 
Jeff Layton <jlayton@primarydata.com>
