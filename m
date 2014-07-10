Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:57368 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585AbaGJKxo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 06:53:44 -0400
Date: Thu, 10 Jul 2014 03:53:43 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 003/114] nfsd: wait to initialize work struct just
 prior to using it
Message-ID: <20140710105343.GB21461@infradead.org>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
 <1404143423-24381-4-git-send-email-jlayton@primarydata.com>
 <20140708211133.GA26851@fieldses.org>
 <20140709082121.GA30099@infradead.org>
 <20140709194114.GC26851@fieldses.org>
 <20140709163744.1aa6126c@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140709163744.1aa6126c@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Unfortunately there are a few (fairly trivial) merge conflicts later in
> the series due to this change. Bruce, do you want me to repost the
> whole set, or would you rather just cherry-pick them from my updated
> branch?

Can you resend just the whole fi_fds and access/deny mode patches as a
series for the next step?  This seems useful and complicated enough to
do a standalone review.  I also don't think the additional few spinlocks
would have enough performance impact to avoid them until the big client
lock is gone, although all those logic changes could probably be done
easily enough without the new locking if someone cared enough (I don't).

