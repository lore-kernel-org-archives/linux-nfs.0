Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:53383 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751051Ab3LKOMn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Dec 2013 09:12:43 -0500
Date: Wed, 11 Dec 2013 15:12:40 +0100
From: Jan Kara <jack@suse.cz>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jan Kara <jack@suse.cz>, Chuck Lever <chuck.lever@oracle.com>,
        Dan Duval <dan.duval@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: Re: NFS file size anomaly?
Message-ID: <20131211141240.GA1163@quack.suse.cz>
References: <3a1854bb-6a06-4924-810a-aa8ba69f642b@default>
 <9FBE3B61-C265-460A-A92E-A4DFE8D27114@oracle.com>
 <4233F512-B1BB-4DEA-91B9-6B2566A02AC8@oracle.com>
 <20131210143643.GD1543@quack.suse.cz>
 <1386694881.2879.16.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="k+w/mQv8wyuph6w0"
In-Reply-To: <1386694881.2879.16.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--k+w/mQv8wyuph6w0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue 10-12-13 19:01:21, Trond Myklebust wrote:
> On Tue, 2013-12-10 at 15:36 +0100, Jan Kara wrote:
> > On Mon 09-12-13 19:56:16, Chuck Lever wrote:
> > > On Dec 9, 2013, at 4:05 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> > > > Copying Trond's new work address.
> > > > 
> > > > Begin forwarded message:
> > > > 
> > > >> From: Dan Duval <dan.duval@oracle.com>
> > > >> Subject: NFS file size anomaly?
> > > >> Date: December 9, 2013 3:04:27 PM EST
> > > >> To: Trond Myklebust <Trond.Myklebust@netapp.com>
> > > >> Cc: <linux-nfs@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>
> > > >> 
> > > >> [NOTE: cross-posted to linux-nfs and linux-fsdevel]
> > > >> 
> > > >> I'm seeing some unexpected behavior with NFS and file sizes.
> > > >> 
> > > >> The test cases are from the LTP (Linux Test Project), tests
> > > >> ftest01, ftest05, and ftest07.  I'll concentrate on ftest01
> > > >> to explain what I've found.
> > > >> 
> > > >> ftest01 fires off 5 subprocesses, each of which opens an empty
> > > >> file and does the following, repeatedly:
> > > >> 
> > > >>       . lseek to some point in the file
> > > >>       . read 2048 bytes
> > > >>       . lseek back to the same point
> > > >>       . write 2048 bytes
> > > >> 
> > > >> The "point in the file" is determined by a pseudo-random
> > > >> sequence.  All such points are on 2048-byte boundaries.
> > > >> 
> > > >> Occasionally, also driven pseudo-randomly, ftest01 will throw
> > > >> in a call to ftruncate(), truncate(), sync(), or fstat().
> > > >> 
> > > >> With the fstat() calls, the returned .st_size is compared
> > > >> with the test's expected size for the file, and an error is
> > > >> declared if they don't match.
> > > >> 
> > > >> What's happening is that, some way into the test, this fstat()
> > > >> check is failing.  Specifically, the .st_size reported by
> > > >> fstat() is greater than the computed size.
> > > >> 
> > > >> The sequence of operations leading up to this is:
> > > >> 
> > > >>       lseek 1034240 0
> > > >>       read 2048
> > > >>       lseek 0 1
> > > >>       write 2048
> > > >> 
> > > >>       lseek 638976 0
> > > >>       (read, lseek, write)
> > > >> 
> > > >>       lseek 708608 0
> > > >>       (read, lseek, write)
> > > >> 
> > > >>       lseek 708608 0
> > > >>       (read, lseek, write)
> > > >> 
> > > >>       lseek 679584 0
> > > >>       (read, lseek, write)
> > > >> 
> > > >>       truncate 266240
> > > >> 
> > > >>       lseek 960512 0
> > > >>       (read, lseek, write)
> > > >> 
> > > >>       (a bunch of lseek/read/lseek/write ops that do not
> > > >>        extend the file)
> > > >> 
> > > >>       fstat
> > > >> 
> > > >> So the expected size of the file is 960512 + 2048 == 960560.
> > > >> But the fstat reports a size of 1036288.
> > > >> 
> > > >> A look at what's happening on the wire, distilled from the
> > > >> output of tethereal, is instructive.
> > > >> 
> > > >>       READ Call 638976 4096 (byte offset and size to read)
> > > >>       READ Reply 4096 995382 (bytes read and current file size)
> > > >> 
> > > >>       SETATTR Call 266240 (this corresponds to the truncate() call)
> > > >> 
> > > >>       WRITE Call 638976 4096 (byte offset and size to write)
> > > >>       WRITE Call 708608 4096
> > > >>       WRITE Call 1032192 4096
> > > >> 
> > > >>       SETATTR Reply 266240 (current size of file)
> > > >> 
> > > >>       WRITE Reply 643072 (current size of file after write)
> > > >>       WRITE Reply 1036288
> > > >>       WRITE Reply 1036288
> > > >> 
> > > >>       GETATTR (initiated internally by NFS code?)
> > > >> 
> > > >>       READ Call 958464 4096 READ Reply 4096 1036288
> > > >> 
> > > >>       ... (a bunch of READ and WRITE ops that do not extend the file)
> > > >> 
> > > >>       GETATTR Call (this corresponds to the fstat() call)
> > > >>       GETATTR Reply 1036288
> > > >> 
> > > >> So what appears to have happened here is that three of the
> > > >> WRITE operations that the program issued before the truncate()
> > > >> call have "bled past" the SETATTR, extending the file further
> > > >> than the SETATTR did.  Since none of the operations issued
> > > >> after SETATTR extends the file further, by the time we get to
> > > >> the GETATTR, the file is larger than the test expects.
> > > >> 
> > > >> There are two strange things going on here.  The first,
> > > >> identified above, is that write()s that were initiated before
> > > >> the truncate() call are being processed after the resulting
> > > >> SETATTR call.  The second is that WRITE operations are being
> > > >> initiated while the SETATTR is outstanding.
> > > >> 
> > > >> It seems to me that a size-changing SETATTR operation should
> > > >> act essentially as an I/O barrier. It should wait for all outstanding
> > > >> read/write requests to complete, then issue the SETATTR,
> > > >> wait for the reply, and only then re-enable read/write requests.
> > > >> 
> > > >> In other words, SETATTR should be atomic with respect to other
> > > >> I/O operations.
> > > 
> > > nfs_setattr() relies on writeback_single_inode() [ via nfs_setattr() ->
> > > nfs_wb_all() -> sync_inode() -> writeback_single_inode() ] to serialize
> > > itself with other pending I/O operations.  The NFS client already treats
> > > SETATTR as an I/O barrier. 
> > > 
> > > >> A git bisect indicates that this problem first appeared (or
> > > >> was first uncovered) with this commit:
> > > >> 
> > > >>   4f8ad65 writeback: Refactor writeback_single_inode()
> > > >> 
> > > >> It continues to the most recent mainline kernels.
> > > >> 
> > > >> NFS v3 vs. v4 doesn't seem to matter.
> > > >> 
> > > >> Has anyone else seen this?  Any pointers you can provide?
> > > 
> > > After commit 4f8ad65, writeback_single_inode() occasionally returns
> > > immediately instead of waiting for writeback to finish.  The behavior
> > > would be difficult or impossible to spot with a local filesystem, but
> > > with NFS, a race is clearly exposed.
> >   That looks like a bug. But the only thing that's changed by 4f8ad65 is
> > the additional test:
> > 	if (!(inode->i_state & I_DIRTY))
> > 		goto out;
> > So it seems NFS has inodes that have dirty data but don't have (any of) inode
> > dirty bits set? But I've been staring at the code and don't see any
> > problem. Any idea Chuck? Otherwise I guess I'll have to reproduce this and
> > debug what's going on.
> 
> Hi Jan,
> 
> I'm guessing that the problem is the fact that you can clear the
> I_DIRTY_PAGES flag inside __writeback_single_inode() on a non-waiting
> call (i.e. one which does not have WB_SYNC_ALL set).
> When that happens, the NFS client ends up with inode->i_state == 0 until
> one of the WRITEs returns with the "unstable" flag set (which triggers a
> call to __mark_inode_dirty(inode, I_DIRTY_DATASYNC) so that we call
> write_inode()).
> 
> Basically, if you have WB_SYNC_ALL set, I think that you cannot apply
> the test for (inode->i_state & I_DIRTY) until you have called 
> filemap_fdatawait().
  Ah, thanks for explanation. I should have spotted this myself. So
something like the attached patch should fix the issue. Dan, can you try
whether the attached patch fixes your problem?

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--k+w/mQv8wyuph6w0
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-writeback-Fix-data-corruption-on-NFS.patch"

>From 18eb76f3c2c7e8f3f57380846677097fe886232e Mon Sep 17 00:00:00 2001
From: Jan Kara <jack@suse.cz>
Date: Wed, 11 Dec 2013 12:15:57 +0100
Subject: [PATCH] writeback: Fix data corruption on NFS

Commit 4f8ad655dbc8 "writeback: Refactor writeback_single_inode()" added
a condition to skip clean inode. However this is wrong in WB_SYNC_ALL
mode because there we also want to wait for outstanding writeback on
possibly clean inode. This was causing occasional data corruption issues
on NFS because it uses sync_inode() to make sure all outstanding writes
are flushed to the server before truncating the inode and with
sync_inode() returning prematurely file was sometimes extended back
by an outstanding write after it was truncated.

So modify the test to also check for pages under writeback in
WB_SYNC_ALL mode.

CC: stable@vger.kernel.org # >= 3.5
Fixes: 4f8ad655dbc82cf05d2edc11e66b78a42d38bf93
Reported-by: Dan Duval <dan.duval@oracle.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 1f4a10ece2f1..e0259a163f98 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -516,13 +516,16 @@ writeback_single_inode(struct inode *inode, struct bdi_writeback *wb,
 	}
 	WARN_ON(inode->i_state & I_SYNC);
 	/*
-	 * Skip inode if it is clean. We don't want to mess with writeback
-	 * lists in this function since flusher thread may be doing for example
-	 * sync in parallel and if we move the inode, it could get skipped. So
-	 * here we make sure inode is on some writeback list and leave it there
-	 * unless we have completely cleaned the inode.
+	 * Skip inode if it is clean and we have no outstanding writeback in
+	 * WB_SYNC_ALL mode. We don't want to mess with writeback lists in this
+	 * function since flusher thread may be doing for example sync in
+	 * parallel and if we move the inode, it could get skipped. So here we
+	 * make sure inode is on some writeback list and leave it there unless
+	 * we have completely cleaned the inode.
 	 */
-	if (!(inode->i_state & I_DIRTY))
+	if (!(inode->i_state & I_DIRTY) &&
+	    (wbc->sync_mode != WB_SYNC_ALL ||
+	     !mapping_tagged(inode->i_mapping, PAGECACHE_TAG_WRITEBACK)))
 		goto out;
 	inode->i_state |= I_SYNC;
 	spin_unlock(&inode->i_lock);
-- 
1.8.1.4


--k+w/mQv8wyuph6w0--
