Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57961 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964792Ab2EaUL7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 May 2012 16:11:59 -0400
Date: Thu, 31 May 2012 16:11:50 -0400
To: Jan Kara <jack@suse.cz>
Cc: "J. Bruce Fields" <bfields@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 2/6] vfs: fix outdated i_mutex_lock_class documentation
Message-ID: <20120531201150.GE25955@fieldses.org>
References: <1338429016-20119-1-git-send-email-bfields@redhat.com>
 <1338429016-20119-3-git-send-email-bfields@redhat.com>
 <20120531185111.GA13647@quack.suse.cz>
 <20120531185439.GB13647@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120531185439.GB13647@quack.suse.cz>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 31, 2012 at 08:54:39PM +0200, Jan Kara wrote:
> On Thu 31-05-12 20:51:11, Jan Kara wrote:
> > On Wed 30-05-12 21:50:12, J. Bruce Fields wrote:
> > > From: "J. Bruce Fields" <bfields@redhat.com>
> > > 
> > > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > > ---
> > >  include/linux/fs.h |    3 ++-
> > >  1 file changed, 2 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > > index 038076b..5584a29 100644
> > > --- a/include/linux/fs.h
> > > +++ b/include/linux/fs.h
> > > @@ -861,7 +861,8 @@ static inline int inode_unhashed(struct inode *inode)
> > >   * 0: the object of the current VFS operation
> > >   * 1: parent
> > >   * 2: child/target
> > > - * 3: quota file
> > > + * 3: xattr
> > > + * 4: quota file
> >   This isn't correct anymore, is it? Just remove references to quota in this
> > comment...
>   Oh, now I've noticed patch 6/6. Maybe this patch and 6/6 should be just
> joined into one?

Sure.--b.
