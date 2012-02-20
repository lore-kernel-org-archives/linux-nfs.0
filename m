Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:41048 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754287Ab2BTWc6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Feb 2012 17:32:58 -0500
Date: Mon, 20 Feb 2012 23:32:54 +0100
From: Jan Kara <jack@suse.cz>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Eric Sandeen <sandeen@redhat.com>, Dave Chinner <david@fromorbit.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 10/11] nfs: Push file_update_time() into
 nfs_vm_page_mkwrite()
Message-ID: <20120220223254.GC32708@quack.suse.cz>
References: <1329399979-3647-1-git-send-email-jack@suse.cz>
 <1329399979-3647-11-git-send-email-jack@suse.cz>
 <1329400219.2924.1.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1329400219.2924.1.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu 16-02-12 13:50:19, Myklebust, Trond wrote:
> On Thu, 2012-02-16 at 14:46 +0100, Jan Kara wrote:
> > CC: Trond Myklebust <Trond.Myklebust@netapp.com>
> > CC: linux-nfs@vger.kernel.org
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  fs/nfs/file.c |    3 +++
> >  1 files changed, 3 insertions(+), 0 deletions(-)
> > 
> > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> > index c43a452..2407922 100644
> > --- a/fs/nfs/file.c
> > +++ b/fs/nfs/file.c
> > @@ -525,6 +525,9 @@ static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
> >  	/* make sure the cache has finished storing the page */
> >  	nfs_fscache_wait_on_page_write(NFS_I(dentry->d_inode), page);
> >  
> > +	/* Update file times before taking page lock */
> > +	file_update_time(filp);
> > +
> >  	lock_page(page);
> >  	mapping = page->mapping;
> >  	if (mapping != dentry->d_inode->i_mapping)
> 
> Hi Jan,
> 
> file_update_time() is a no-op in NFS, since we set S_NOATIME|S_NOCMTIME
> on all inodes.
  Thanks. I've discarded the patch.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR
