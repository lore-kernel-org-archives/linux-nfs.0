From: Quentin Barnes <qbarnes+nfs@yahoo-inc.com>
Subject: Re: nfs_file_flush() question
Date: Tue, 19 Aug 2008 22:38:14 -0500
Message-ID: <20080820033814.GA2528@yahoo-inc.com>
References: <20080819201731.GA25036@yahoo-inc.com> <1219192252.7150.30.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip4-fw.champ.corp.yahoo.com ([64.198.211.64]:31324 "EHLO
	enemycanmeet.champ.corp.yahoo.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753020AbYHTDjp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2008 23:39:45 -0400
In-Reply-To: <1219192252.7150.30.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 19, 2008 at 05:30:52PM -0700, Trond Myklebust wrote:
> On Tue, 2008-08-19 at 15:17 -0500, Quentin Barnes wrote:
> > > If I don't know the correct mtime attribute of the file when I close it,
> >
> > If I follow the code, you do know the mtime when closing the
> > file.  With V3, from the WRITE and COMMIT, you're given weak cache
> > consistency data containing the the updated mtimes, correct?
> 
> No. Please note the difference between a call to nfs_update_inode(), and
> a call to nfs_refresh_inode(). The latter tries to be more careful about
> updating the inode attributes if there is a chance that we may have
> raced with another RPC call to the same inode, and hence that the
> attributes returned may be stale.
> 
> > But making the change to nfs_revalidate_inode() by itself only
> > helps in the case where the file was open O_RDWR and no write(2)
> > was done.  The code still needed to be updated to use the WCC data
> > at the right time.  In the older kernels when nfs_wb_all() ended up
> > calling nfs_update_inode() which was clearing the cache when it saw
> > the mtime change from the WRITE.  I tracked down why.  Newer kernels
> > (2.6.24 and later) had nfs_post_op_update_inode_force_wcc() call
> > added to nfs3_write_done() which updated the inode with the WCC data
> > from the WRITE so the later call to nfs_update_inode() didn't see
> > an unexpected mtime change flagging the attribute and data cache as
> > invalid.
> 
> See above.

I'm not sure I'm following what you mean.  What I wrote in the
second part is what's happening from watching the traces.  I may not
have gotten the exact call chain right, but the end result is what's
going on.  I'll go into more detail.

But what I'm wondering is what exactly is wrong.  Is it my
understanding or something in my analysis?  Are you indicating
that the 2.6.24 kernel and later are misbehaving since they don't
invalidate the caches and do a GETATTR?

Here's a debug trace on a 2.6.24 kernel of a process doing an
open(2), write(2), and close(2):
======
NFS: permission(0:14/33685649), mask=0x1, res=0
NFS: nfs_lookup_revalidate(/.xtest1) is valid
NFS: permission(0:14/33686480), mask=0x6, res=0
nfs: write(/.xtest1(33686480), 23@0)
NFS:      nfs_updatepage(/.xtest1 23@0)
NFS:      nfs_updatepage returns 0 (isize 23)
nfs: flush(0:14/33686480)
*nfs: flush pre-nfs_do_fsync cache_validity = 0x00000000
NFS:     0 initiated write call (req 0:14/33686480, 23 bytes @ offset 0)
NFS:    38 nfs_writeback_done (status 23)
NFS: nfs_update_inode(0:14/33686480 ct=2 info=0x7)
NFS: write (0:14/33686480 23@0) marked for commit
NFS:     0 initiated commit call
NFS:    39 nfs_commit_done (status 0) 
NFS: nfs_update_inode(0:14/33686480 ct=2 info=0x6)
NFS: commit (0:14/33686480 23@0) OK
*nfs: flush post-nfs_do_fsync cache_validity = 0x00000000
NFS: dentry_delete(/.xtest1, 8)       
======

I added some extra debug of my own just before and after the call to
nfs_do_fsync() in nfs_file_flush().  I noted them with "*"s.  Note
that after the commit, the attribute and data cache are still valid
with 2.6.24 (cache_validity is still 0x0, so nothing's invalidated).
When that's the case, there is no GETATTR call.

Now the same thing on 2.6.9:
======
nfs: flush(0:13/33686480)
*nfs: flush pre-nfs_wb_all cache_validity = 0x00000000
NFS:  103 initiated write call (req 0:13/33686480, 23 bytes @ offset 0)
NFS: nfs_update_inode(0:13/33686480 ct=2 info=0x6)
NFS: mtime change on server for file 0:13/33686480
NFS:  103 nfs_writeback_done (status 23) 
NFS: write (0:13/33686480 23@0) marked for commit 
NFS:  104 initiated commit call
NFS: nfs_update_inode(0:13/33686480 ct=2 info=0x6)
NFS:  104 nfs_commit_done (status 0)
NFS: commit (0:13/33686480 23@0) OK
*nfs: flush post-nfs_wb_all cache_validity = 0x0000001b
NFS: revalidating (0:13/33686480)
NFS call  getattr
NFS reply getattr
NFS: nfs_update_inode(0:13/33686480 ct=1 info=0x6)
NFS: (0:13/33686480) data cache invalidated
NFS: nfs3_forget_cached_acls(0:13/33686480)
NFS: (0:13/33686480) revalidation complete
NFS: dentry_delete(//.xtest1, 0)
======

The extra debug this time is around the nfs_wb_all() call.  As you
can see during the flush the attribute and data caches get marked
invalid (cache_validity goes from 0x0 to 0x1b) so a GETATTR call is
made.  In nfs_update_inode(), it tells us why it happened, "mtime
change on server for file" which does not happen on 2.6.24.

I ported over the nfs_post_op_update_inode_force_wcc() function
to 2.6.9 and hooked it into the *write_done() functions and that
got rid of the "mtime change on server for file" message from
nfs_update_inode() on that kernel.

Is 2.6.24 doing the right thing?

> Cheers
>   Trond

Quentin
