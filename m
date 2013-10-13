Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:45302 "EHLO
	ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755268Ab3JMWxD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Oct 2013 18:53:03 -0400
Date: Mon, 14 Oct 2013 09:52:55 +1100
From: Dave Chinner <david@fromorbit.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>, Al Viro <viro@ZenIV.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, sandeen@redhat.com
Subject: Re: [PATCH 2/2] exportfs: fix 32-bit nfsd handling of 64-bit inode
 numbers
Message-ID: <20131013225255.GD4446@dastard>
References: <20131002210736.GA20598@fieldses.org>
 <1380749295-20854-1-git-send-email-bfields@redhat.com>
 <1380749295-20854-2-git-send-email-bfields@redhat.com>
 <20131004221216.GC18051@fieldses.org>
 <20131004221522.GD18051@fieldses.org>
 <20131008215656.GA3456@fieldses.org>
 <20131009001631.GD4446@dastard>
 <20131009145320.GD3456@fieldses.org>
 <20131010222807.GB4446@dastard>
 <20131011215351.GE22160@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131011215351.GE22160@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 11, 2013 at 05:53:51PM -0400, J. Bruce Fields wrote:
> On Fri, Oct 11, 2013 at 09:28:07AM +1100, Dave Chinner wrote:
> > On Wed, Oct 09, 2013 at 10:53:20AM -0400, J. Bruce Fields wrote:
> > > On Wed, Oct 09, 2013 at 11:16:31AM +1100, Dave Chinner wrote:
> > > > On Tue, Oct 08, 2013 at 05:56:56PM -0400, J. Bruce Fields wrote:
> > > > > On Fri, Oct 04, 2013 at 06:15:22PM -0400, J. Bruce Fields wrote:
> > > > > > On Fri, Oct 04, 2013 at 06:12:16PM -0400, bfields wrote:
> > > > > > > On Wed, Oct 02, 2013 at 05:28:14PM -0400, J. Bruce Fields wrote:
> > > > > > > > @@ -268,6 +268,16 @@ static int get_name(const struct path *path, char *name, struct dentry *child)
> > > > > > > >  	if (!dir->i_fop)
> > > > > > > >  		goto out;
> > > > > > > >  	/*
> > > > > > > > +	 * inode->i_ino is unsigned long, kstat->ino is u64, so the
> > > > > > > > +	 * former would be insufficient on 32-bit hosts when the
> > > > > > > > +	 * filesystem supports 64-bit inode numbers.  So we need to
> > > > > > > > +	 * actually call ->getattr, not just read i_ino:
> > > > > > > > +	 */
> > > > > > > > +	error = vfs_getattr_nosec(path, &stat);
> > > > > > > 
> > > > > > > Doh, "path" here is for the parent....  The following works better!
> > > > > > 
> > > > > > By the way, I'm testing this with:
> > > > > > 
> > > > > > 	- create a bunch of nested subdirectories, use
> > > > > > 	  name_to_fhandle_at to get a handle for the bottom directory.
> > > > > > 	- echo 2 >/proc/sys/vm/drop_caches
> > > > > > 	- open_by_fhandle_at on the filehandle
> > > > > > 
> > > > > > But this only actually exercises the reconnect path on the first run
> > > > > > after boot.  Is there something obvious I'm missing here?
> > > > > 
> > > > > Looking at the code....  OK, most of the work of drop_caches is done by
> > > > > shrink_slab_node, which doesn't actually try to free every single thing
> > > > > that it could free--in particular, it won't try to free anything if it
> > > > > thinks there are less than shrinker->batch_size (1024 in the
> > > > > super_block->s_shrink case) objects to free.
> > > 
> > > (Oops, sorry, that should have been "less than half of
> > > shrinker->batch_size", see below.)
> > > 
> > > > That's not quite right. Yes, the shrinker won't be called if the
> > > > calculated scan count is less than the batch size, but the left over
> > > > is added back the shrinker scan count to carry over to the next call
> > > > to the shrinker. Hence if you repeated call the shrinker on a small
> > > > cache with a large batch size, it will eventually aggregate the scan
> > > > counts to over the batch size and trim the cache....
> > > 
> > > No, in shrink_slab_count, we do this:
> > > 
> > > 	if (total_scan > max_pass * 2)
> > > 		total_scan = max_pass * 2;
> > > 
> > > 	while (total_scan >= batch_size) {
> > > 		...
> > > 	}
> > > 
> > > where max_pass is the value returned from count_objects.  So as long as
> > > count_objects returns less than half batch_size, nothing ever happens.
> > 
> > Ah, right - I hadn't considered what that does to small caches - the
> > intended purpose of that is to limit the scan size when caches are
> > extremely large and lots of deferral has occurred. Perhaps we need
> > to consider the batch size in this? e.g.:
> > 
> > 	total_scan = min(total_scan, max(max_pass * 2, batch_size));
> > 
> > Hence for small caches (max_pass <<< batch_size), it evaluates as:
> > 
> > 	total_scan = min(total_scan, batch_size);
> > 
> > and hence once aggregation of repeated calls pushes us over the
> > batch size we run the shrinker.
> > 
> > For large caches (max_pass >>> batch_size), it evaluates as:
> > 
> > 	total_scan = min(total_scan, max_pass * 2);
> > 
> > which gives us the same behaviour as the current code.
> > 
> > I'll write up a patch to do this...
> 
> It all feels a bit ad-hoc, but OK.
> 
> drop_caches could still end up leaving some small caches alone, right?

Yes, but it's iterative nature means that as long as it is making
progress it will continue to call the shrinkers and hence in most
cases caches will get more than just one call to be shrunk.

> I hadn't expected that, but then again maybe I don't really understand
> what drop_caches is for.

drop_caches is a "best attempt" to free memory, not a guaranteed
method of freeing pages or slab objects. It's a big hammer that can
free a lot of memory and it will continue to free memory as long as
it makes progress. But if it can't make progress, then it simply
stops, and that can happen at any time during slab cache
shrinking...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
