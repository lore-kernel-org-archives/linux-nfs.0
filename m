From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/2] NFS: Fix a bug in nfs_fscache_release_page()
Date: Mon, 08 Feb 2010 08:23:55 -0500
Message-ID: <1265635435.5235.4.camel@localhost>
References: <1265409793-18314-1-git-send-email-Trond.Myklebust@netapp.com>
	 <4B6EA357.3000604@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Suresh Jayaraman <sjayaraman@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:10164 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751747Ab0BHNYI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Feb 2010 08:24:08 -0500
In-Reply-To: <4B6EA357.3000604@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2010-02-07 at 16:56 +0530, Suresh Jayaraman wrote: 
> On 02/06/2010 04:13 AM, Trond Myklebust wrote:
> > Not having an fscache cookie is perfectly valid if the user didn't mount
> > with the fscache option.
> > 
> > This patch fixes http://bugzilla.kernel.org/show_bug.cgi?id=15234
> > 
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > Cc: stable@kernel.org
> > ---
> >  fs/nfs/fscache.c |    6 +++---
> >  1 files changed, 3 insertions(+), 3 deletions(-)
> > 
> > diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
> > index fa58800..534adb8 100644
> > --- a/fs/nfs/fscache.c
> > +++ b/fs/nfs/fscache.c
> > @@ -355,11 +355,11 @@ void nfs_fscache_reset_inode_cookie(struct inode *inode)
> >  int nfs_fscache_release_page(struct page *page, gfp_t gfp)
> >  {
> >  	struct nfs_inode *nfsi = NFS_I(page->mapping->host);
> > -	struct fscache_cookie *cookie = nfsi->fscache;
> > -
> > -	BUG_ON(!cookie);
> >  
> >  	if (PageFsCache(page)) {
> > +		struct fscache_cookie *cookie = nfsi->fscache;
> > +
> > +		BUG_ON(!cookie);
> >  		dfprintk(FSCACHE, "NFS: fscache releasepage (0x%p/0x%p/0x%p)\n",
> >  			 cookie, page, nfsi);
> >  
> 
> There are only two callers for nfs_fscache_release_page() -
> nfs_release_page() and nfs_migrate_page(). nfs_migrate_page already does
> this:
> 
>        if (PageFsCache(page))
>                 nfs_fscache_release_page(page, GFP_KERNEL);
> 
> and the assumption in nfs_release_page() is that the page should have
> either PG_private set or PG_fscache set and nfs_fscache_release_page
> gets called only if PG_private is not set.

...or if it gets cleared.

> I think the idea is that nfs_fscache_release_page should not get called
> if fsc option is not used. So it appears to me this patch is fixing the
> symptom not the actual issue. Perhaps, this the assumption in
> nfs_release_page is wrong or the PageFsCache() check should be moved to
> nfs_release_page?

No. We should rather get rid of the redundant check for PageFsCache() in
nfs_migrate_page. PageFsCache() is particular to fscache, so the test
belongs in the fscache code.

Trond
