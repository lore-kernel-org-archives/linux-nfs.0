Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx5-phx2.redhat.com ([209.132.183.37]:33693 "EHLO
	mx5-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756862AbaGARQo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jul 2014 13:16:44 -0400
Date: Tue, 1 Jul 2014 13:16:32 -0400 (EDT)
From: Bob Peterson <rpeterso@redhat.com>
To: David Teigland <teigland@redhat.com>
Cc: Jeff Layton <jlayton@poochiereds.net>, cluster-devel@redhat.com,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        linux-fsdevel@vger.kernel.org, Joe Perches <joe@perches.com>
Message-ID: <1781051691.1348978.1404234992108.JavaMail.zimbra@redhat.com>
In-Reply-To: <20140701164652.GB32565@redhat.com>
References: <1404220810.2717.39.camel@joe-AO725> <20140701104313.5317400a@tlielax.poochiereds.net> <20140701164652.GB32565@redhat.com>
Subject: Re: [Cluster-devel] [RFC PATCH] dlm: Remove unused conf from
	lm_grant
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message -----
> On Tue, Jul 01, 2014 at 10:43:13AM -0400, Jeff Layton wrote:
> > On Tue, 01 Jul 2014 06:20:10 -0700
> > Joe Perches <joe@perches.com> wrote:
> > 
> > > While doing a bit of adding argument names to fs.h,
> > > I looked at lm_grant and it seems the 2nd argument
> > > is always NULL.
> > > 
> > > How about removing it?
> > > 
> > > This doesn't apply as it depends on some other patches
> > > but it should be clear enough...
> > > 
> > 
> > ACK on the general idea from my standpoint. Anything that simplifies
> > the file locking interfaces is a good thing, particularly the deferred
> > locking code.
> 
> Fine with me.  I'd be happy to remove all the deferred locking code from
> dlm; it never really worked.
> 
> Dave

Hi,

GFS2 uses deferred locks, at the very least in its direct_io path
(gfs2_direct_IO in aops.c). So AFAIK we can't remove THAT without a certain
amount of pain. Steve is on vacation / holiday this week, but he will
be back on Thursday and Friday (which is a holiday).

I'm all for getting rid of useless parameters, and I've done so on
several occasions in GFS2.

Regards,

Bob Peterson
Red Hat File Systems
