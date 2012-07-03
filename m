Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57152 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754397Ab2GCLVU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Jul 2012 07:21:20 -0400
Date: Tue, 3 Jul 2012 07:20:51 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "harshula@redhat.com" <harshula@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "mgorman@suse.de" <mgorman@suse.de>,
        "jan.kratochvil@redhat.com" <jan.kratochvil@redhat.com>
Subject: Re: [RFC PATCH v2] nfs: skip commit in releasepage if we're freeing
 memory for fs-related reasons
Message-ID: <20120703072051.4e7a9d34@corrin.poochiereds.net>
In-Reply-To: <1341258017.8197.46.camel@lade.trondhjem.org>
References: <1340895773.5293.18.camel@lade.trondhjem.org>
	<1340897113-18449-1-git-send-email-jlayton@redhat.com>
	<20120702111751.3ac78d2c@tlielax.poochiereds.net>
	<1341258017.8197.46.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2 Jul 2012 19:40:22 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Mon, 2012-07-02 at 11:17 -0400, Jeff Layton wrote:
> > nfs: broaden the cases where we use a non-blocking commit in releasepage
> > 
> > Currently, we just do a non-blocking commit when called from kswapd, but
> > that still gives us some cases where we end up blocking after recursing
> > back into the filesystem. Instead, turn that check into a check for
> > PF_MEMALLOC so that we never block when trying to free memory in order to
> > satisfy an allocation.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/nfs/file.c |    4 ++--
> >  1 files changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> > index 9075769..61d3670 100644
> > --- a/fs/nfs/file.c
> > +++ b/fs/nfs/file.c
> > @@ -466,8 +466,8 @@ static int nfs_release_page(struct page *page, gfp_t gfp)
> >  	    !(current->flags & PF_FSTRANS)) {
> >  		int how = FLUSH_SYNC;
> >  
> > -		/* Don't let kswapd deadlock waiting for OOM RPC calls */
> > -		if (current_is_kswapd())
> > +		/* Don't block if we're freeing for a memory allocation */
> > +		if (current->flags & PF_MEMALLOC)
> >  			how = 0;
> >  		nfs_commit_inode(mapping->host, how);
> >  	}
> 
> Umm... So which process will actually call nfs_release_page() with
> GFP_KERNEL, but without the PF_MEMALLOC flag being set?
> 

Well...there are a number of callers of try_to_release_page with
GFP_KERNEL that are not involved with reclaim:

The migrate_page codepaths and the splice code, for instance. Also
invalidate_complete_page2, which we call when invalidating an inode and
maybe also when truncating? Those are almost certainly less traveled
than the reclaim codepaths though.

-- 
Jeff Layton <jlayton@redhat.com>
