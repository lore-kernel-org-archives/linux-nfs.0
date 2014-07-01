Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15958 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756563AbaGAQrX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Jul 2014 12:47:23 -0400
Date: Tue, 1 Jul 2014 11:46:52 -0500
From: David Teigland <teigland@redhat.com>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Joe Perches <joe@perches.com>, Christine Caulfield <ccaulfie@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, cluster-devel@redhat.com,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [RFC PATCH] dlm: Remove unused conf from lm_grant
Message-ID: <20140701164652.GB32565@redhat.com>
References: <1404220810.2717.39.camel@joe-AO725>
 <20140701104313.5317400a@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140701104313.5317400a@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 01, 2014 at 10:43:13AM -0400, Jeff Layton wrote:
> On Tue, 01 Jul 2014 06:20:10 -0700
> Joe Perches <joe@perches.com> wrote:
> 
> > While doing a bit of adding argument names to fs.h,
> > I looked at lm_grant and it seems the 2nd argument
> > is always NULL.
> > 
> > How about removing it?
> > 
> > This doesn't apply as it depends on some other patches
> > but it should be clear enough...
> > 
> 
> ACK on the general idea from my standpoint. Anything that simplifies
> the file locking interfaces is a good thing, particularly the deferred
> locking code.

Fine with me.  I'd be happy to remove all the deferred locking code from
dlm; it never really worked.

Dave
