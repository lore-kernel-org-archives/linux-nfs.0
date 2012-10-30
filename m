Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45194 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756339Ab2J3Tpi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Oct 2012 15:45:38 -0400
Date: Tue, 30 Oct 2012 15:45:20 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        michael.brantley@deshaw.com, hch@infradead.org, miklos@szeredi.hu,
        pstaubach@exagrid.com
Subject: Re: [PATCH v8 11/32] vfs: make do_unlinkat retry on ESTALE errors
Message-ID: <20121030154520.4f3503e8@tlielax.poochiereds.net>
In-Reply-To: <20121030192809.GE24618@fieldses.org>
References: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
	<1351341219-17837-12-git-send-email-jlayton@redhat.com>
	<20121030161429.GD24618@fieldses.org>
	<20121030123355.5c404373@tlielax.poochiereds.net>
	<20121030192809.GE24618@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 30 Oct 2012 15:28:09 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Oct 30, 2012 at 12:33:55PM -0400, Jeff Layton wrote:
> > On Tue, 30 Oct 2012 12:14:29 -0400
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Sat, Oct 27, 2012 at 08:33:18AM -0400, Jeff Layton wrote:
> > > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > > > ---
> > > >  fs/namei.c | 12 ++++++++++--
> > > >  1 file changed, 10 insertions(+), 2 deletions(-)
> > > > 
> > > > diff --git a/fs/namei.c b/fs/namei.c
> > > > index 7c9bb50..467b9f1 100644
> > > > --- a/fs/namei.c
> > > > +++ b/fs/namei.c
> > > > @@ -3446,9 +3446,13 @@ static long do_unlinkat(int dfd, const char __user *pathname)
> > > >  	struct filename *name;
> > > >  	struct dentry *dentry;
> > > >  	struct nameidata nd;
> > > > -	struct inode *inode = NULL;
> > > > +	struct inode *inode;
> > > > +	unsigned int try = 0;
> > > > +	unsigned int lookup_flags = LOOKUP_PARENT;
> > > >  
> > > > -	name = user_path_parent(dfd, pathname, &nd, 0);
> > > > +retry:
> > > > +	inode = NULL;
> > > 
> > > So, you fail after "inode" was set (say vfs_unlink returned an error)
> > > the first time, then before "inode" was set (lookup_hash returns an
> > > error), and you end up incorrectly doing another iput() the second time
> > > through if you don't reset inode here?
> > > 
> > > (I think I made the same mistake in another patch, actually....)
> > > 
> > > --b.
> > > 
> > 
> > Correct. That's a new delta in this patch, btw. The original patch
> > didn't do that and it was causing a busy inodes on umount bug in
> > testing.
> > 
> > It would occasionally hit an ESTALE error in this function and
> > because "inode" wasn't reset to NULL, it would do a double-put of the
> > inode and cause the counter to underflow.
> > 
> > It might be good to restructure this code to make those sorts of bugs
> > less likely, but the error handling in here is already so hairy that I
> > decided to punt on that for now...
> 
> Understood.  I might find it just a little more obvious why we're doing
> this if the assignment was next to the final iput:
> 
> 	if (inode)
> 		iput(inode);
> 	inode = NULL;
> 	...
> 

Yeah, my initial patch did something similar (but inside the "if"
block). Ultimately, though I figured it was best to avoid setting
"inode" unless it was needed.

The patch I've got basically does that, but it's not as obvious as the
other way. Maybe I should just go ahead and try to clean up that logic
after all. Unrolling the error handling there is pretty nasty though.

-- 
Jeff Layton <jlayton@redhat.com>
