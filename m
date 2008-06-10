From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 4/5] knfsd: convert knfsd to kthread API
Date: Tue, 10 Jun 2008 16:19:14 -0400
Message-ID: <20080610161914.51a23481@tleilax.poochiereds.net>
References: <1213101639-26423-1-git-send-email-jlayton@redhat.com>
	<1213101639-26423-2-git-send-email-jlayton@redhat.com>
	<1213101639-26423-3-git-send-email-jlayton@redhat.com>
	<1213101639-26423-4-git-send-email-jlayton@redhat.com>
	<1213101639-26423-5-git-send-email-jlayton@redhat.com>
	<20080610162426.GD20184@fieldses.org>
	<20080610162526.GE20184@fieldses.org>
	<20080610130651.331abdae@tleilax.poochiereds.net>
	<20080610200542.GQ20184@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48696 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756134AbYFJUTS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jun 2008 16:19:18 -0400
In-Reply-To: <20080610200542.GQ20184@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 10 Jun 2008 16:05:42 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Jun 10, 2008 at 01:06:51PM -0400, Jeff Layton wrote:
> > On Tue, 10 Jun 2008 12:25:26 -0400
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Tue, Jun 10, 2008 at 12:24:26PM -0400, bfields wrote:
> > > > On Tue, Jun 10, 2008 at 08:40:38AM -0400, Jeff Layton wrote:
> > > > In fact, I don't think you really need to take a reference till there's
> > > > a chance the new thread will decrement the reference--and since the
> > > > first thing the new thread does is take the mutex (which we're also
> > > > holding here), you could wait till after the succesful kthread_create()
> > > > to take the reference.  But maybe that's more fragile.  So I'd just
> > > > move the module_get to right before the kthread_create().
> > > 
> > > Anyway, that's very minor, and this all seems OK otherwise, so I might
> > > make this one small modification and just apply if there's no further
> > > comments.
> > > 
> > > --b.
> > 
> > Thanks. That sounds right to me. Let me know if you want me to formally
> > respin the patch instead.
> 
> I went ahead and applied with that one change; results are in
> 
> 	git://linux-nfs.org/~bfields/linux.git for-2.6.27
> 
> Thanks!  It'll be good to have this taken care of.
> 
> --b.
> 

Thanks for the cleanup and the patience through the different patch
gyrations...

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>
