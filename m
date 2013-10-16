Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53669 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934006Ab3JPN4s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Oct 2013 09:56:48 -0400
Date: Wed, 16 Oct 2013 09:56:25 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/5] exportfs: clear DISCONNECTED on all parents sooner
Message-ID: <20131016135625.GB3759@pad.fieldses.org>
References: <1381869574-10662-1-git-send-email-bfields@redhat.com>
 <1381869574-10662-2-git-send-email-bfields@redhat.com>
 <20131016071343.GB27799@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131016071343.GB27799@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 16, 2013 at 12:13:43AM -0700, Christoph Hellwig wrote:
> On Tue, Oct 15, 2013 at 04:39:29PM -0400, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > Once we've found any connected parent, we know all our parents are
> > connected--that's true even if there's a concurrent rename.  May as well
> > clear them all at once.
> > 
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> Looks good,
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> 
> >  		if (!IS_ROOT(pd)) {
> >  			/* must have found a connected parent - great */
> > -			spin_lock(&pd->d_lock);
> > -			pd->d_flags &= ~DCACHE_DISCONNECTED;
> > -			spin_unlock(&pd->d_lock);
> > +			clear_disconnected(target_dir);
> >  			noprogress = 0;
> >  		} else if (pd == mnt->mnt_sb->s_root) {
> >  			printk(KERN_ERR "export: Eeek filesystem root is not connected, impossible\n");
> 
> You might as well throw a patch in to make this condition a BUG_ON, it
> would indicate a nasty bug in the dcache and has never triggered in the
> last 10 years as far as I know.

We've seen some ugly crashes made uglier by unnecessary BUG()s.  I guess
that wouldn't be the case here as we're not holding any critical locks
and all we're going to kill is an nfsd thread or open_by_handle caller.
And like you say it's a very unlikely case anyway.

So, OK, I'll turn this case into a BUG_ON in a separate patch.

--b.
