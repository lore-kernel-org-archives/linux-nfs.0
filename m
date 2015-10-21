Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51326 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755414AbbJUP5m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Oct 2015 11:57:42 -0400
Date: Wed, 21 Oct 2015 11:57:41 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>, hch@lst.de
Subject: Re: [PATCH v6 00/19] nfsd: open file caching
Message-ID: <20151021155741.GC27929@fieldses.org>
References: <1445362432-18869-1-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1445362432-18869-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I haven't reviewed this in detail yet, sorry.

I seem to recall that a filehandle cache was something Christoph (cc'd)
lobbied for for a long time, but I forget the issue--did getting rid of
the raparms cache allow some sort of further vfs cleanup?

But I don't know that this is justifiable just as cleanup, so some
understanding of the performance impact would be useful too.

--b.

On Tue, Oct 20, 2015 at 01:33:33PM -0400, Jeff Layton wrote:
> v6:
> - rename delayed_fput infrastructure to global_fput
> - drop list_lru_rotate patch, rework LRU list code to use LRU_ROTATE
>   and a new NFSD_FILE_REFERENCED flag
> - rework fsnotify_mark handling to be done with separate allocation
> - bugfixes
> 
> v5:
> - switch to using flush_delayed_fput instead of __fput_sync
> - hash on inode->i_ino instead of inode pointer
> - add /proc/fs/nfsd/file_cache_stats file to track stats on the hash
> - eliminate extra fh_verify in nfsd_file_acquire
> 
> v4:
> - squash some of the patches down into one patch to reduce churn
> - close cached open files after unlink instead of before
> - don't just close files after nfsd does an unlink, must do it
>   after any vfs-layer unlink. Use fsnotify to handle that.
> - use a SRCU notifier chain for setlease
> - add patch to allow non-kthreads to do a fput_sync
> 
> v3:
> - open files are now hashed on inode pointer instead of fh
> - eliminate the recurring workqueue job in favor of shrinker/LRU and
>   notifier from lease setting code
> - have nfsv4 use the cache as well
> - removal of raparms cache
> 
> v2:
> - changelog cleanups and clarifications
> - allow COMMIT to use cached open files
> - tracepoints for nfsd_file cache
> - proactively close open files prior to REMOVE, or a RENAME over a
>   positive dentry
> 
> This is the sixth posting of this patchset. For those just tuning in
> now, the basic idea here is to allow nfsd to keep a cache of open
> file descriptions, primarily to help NFSv3 workloads but also to clean
> up some nastiness in the NFSv4 file handling.
> 
> Of course, we can't keep files open indefinitely, so much of the new
> infrastructure is geared toward allowing the files to be closed on
> demand, in the following cases:
> 
> - nfsd_files are released whenever the inode's link count goes to zero
> - they are released when userspace wants to set a lease on the inode
> - when a shrinker callback occurs for the nfsd_file cache
> - when filesystems are unexported or nfsd is shut down, we clean
>   out the cache
> 
> This allows nfsd to keep the file open basically indefinitely. The
> tricky part is the setlease case. To handle that properly we have to
> allow userland processes to queue the fputs involved to a workqueue.
> This means allowing non-kthreads to queue fputs to the delayed_fput
> infrastructure.
> 
> Al, can you look and weigh in? Do the delayed_fput/global_fput
> changes look reasonable?
> 
> Jeff Layton (19):
>   nfsd: move include of state.h from trace.c to trace.h
>   fs: have flush_delayed_fput flush the workqueue job
>   fs: add a kerneldoc header to fput
>   fs: rename "delayed_fput" infrastructure to "fput_global"
>   fs: add fput_global
>   fsnotify: export several symbols
>   locks: create a new notifier chain for lease attempts
>   sunrpc: add a new cache_detail operation for when a cache is flushed
>   nfsd: add a new struct file caching facility to nfsd
>   nfsd: keep some rudimentary stats on nfsd_file cache
>   nfsd: allow filecache open to skip fh_verify check
>   nfsd: hook up nfsd_write to the new nfsd_file cache
>   nfsd: hook up nfsd_read to the nfsd_file cache
>   nfsd: hook nfsd_commit up to the nfsd_file cache
>   nfsd: convert nfs4_file->fi_fds array to use nfsd_files
>   nfsd: have nfsd_test_lock use the nfsd_file cache
>   nfsd: convert fi_deleg_file and ls_file fields to nfsd_file
>   nfsd: hook up nfs4_preprocess_stateid_op to the nfsd_file cache
>   nfsd: rip out the raparms cache
> 
>  fs/file_table.c              |  94 ++++--
>  fs/locks.c                   |  37 +++
>  fs/nfsd/Kconfig              |   2 +
>  fs/nfsd/Makefile             |   3 +-
>  fs/nfsd/export.c             |  14 +
>  fs/nfsd/filecache.c          | 712 +++++++++++++++++++++++++++++++++++++++++++
>  fs/nfsd/filecache.h          |  44 +++
>  fs/nfsd/nfs3proc.c           |   2 +-
>  fs/nfsd/nfs4layouts.c        |  12 +-
>  fs/nfsd/nfs4proc.c           |  32 +-
>  fs/nfsd/nfs4state.c          | 174 +++++------
>  fs/nfsd/nfs4xdr.c            |  16 +-
>  fs/nfsd/nfsctl.c             |  10 +
>  fs/nfsd/nfsproc.c            |   2 +-
>  fs/nfsd/nfssvc.c             |  16 +-
>  fs/nfsd/state.h              |  10 +-
>  fs/nfsd/trace.c              |   2 -
>  fs/nfsd/trace.h              | 137 +++++++++
>  fs/nfsd/vfs.c                | 269 ++++------------
>  fs/nfsd/vfs.h                |  11 +-
>  fs/nfsd/xdr4.h               |  15 +-
>  fs/notify/group.c            |   2 +
>  fs/notify/inode_mark.c       |   1 +
>  fs/notify/mark.c             |   4 +
>  include/linux/file.h         |   3 +-
>  include/linux/fs.h           |   1 +
>  include/linux/sunrpc/cache.h |   1 +
>  init/main.c                  |   2 +-
>  net/sunrpc/cache.c           |   3 +
>  29 files changed, 1249 insertions(+), 382 deletions(-)
>  create mode 100644 fs/nfsd/filecache.c
>  create mode 100644 fs/nfsd/filecache.h
> 
> -- 
> 2.4.3
