Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41158 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753397Ab3JHV5b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Oct 2013 17:57:31 -0400
Date: Tue, 8 Oct 2013 17:56:56 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Christoph Hellwig <hch@infradead.org>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        sandeen@redhat.com
Subject: Re: [PATCH 2/2] exportfs: fix 32-bit nfsd handling of 64-bit inode
 numbers
Message-ID: <20131008215656.GA3456@fieldses.org>
References: <20131002210736.GA20598@fieldses.org>
 <1380749295-20854-1-git-send-email-bfields@redhat.com>
 <1380749295-20854-2-git-send-email-bfields@redhat.com>
 <20131004221216.GC18051@fieldses.org>
 <20131004221522.GD18051@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131004221522.GD18051@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 04, 2013 at 06:15:22PM -0400, J. Bruce Fields wrote:
> On Fri, Oct 04, 2013 at 06:12:16PM -0400, bfields wrote:
> > On Wed, Oct 02, 2013 at 05:28:14PM -0400, J. Bruce Fields wrote:
> > > @@ -268,6 +268,16 @@ static int get_name(const struct path *path, char *name, struct dentry *child)
> > >  	if (!dir->i_fop)
> > >  		goto out;
> > >  	/*
> > > +	 * inode->i_ino is unsigned long, kstat->ino is u64, so the
> > > +	 * former would be insufficient on 32-bit hosts when the
> > > +	 * filesystem supports 64-bit inode numbers.  So we need to
> > > +	 * actually call ->getattr, not just read i_ino:
> > > +	 */
> > > +	error = vfs_getattr_nosec(path, &stat);
> > 
> > Doh, "path" here is for the parent....  The following works better!
> 
> By the way, I'm testing this with:
> 
> 	- create a bunch of nested subdirectories, use
> 	  name_to_fhandle_at to get a handle for the bottom directory.
> 	- echo 2 >/proc/sys/vm/drop_caches
> 	- open_by_fhandle_at on the filehandle
> 
> But this only actually exercises the reconnect path on the first run
> after boot.  Is there something obvious I'm missing here?

Looking at the code....  OK, most of the work of drop_caches is done by
shrink_slab_node, which doesn't actually try to free every single thing
that it could free--in particular, it won't try to free anything if it
thinks there are less than shrinker->batch_size (1024 in the
super_block->s_shrink case) objects to free.

So for now I'm just nesting deeper (2048 subdirectories) to get a
reliable way to exercise reconnect_path.

--b.
