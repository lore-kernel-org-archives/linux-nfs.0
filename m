Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44284 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933486AbbJHQmZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Oct 2015 12:42:25 -0400
Date: Thu, 8 Oct 2015 12:42:25 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v5 00/20] nfsd: open file caching
Message-ID: <20151008164225.GA496@fieldses.org>
References: <1444042962-6947-1-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1444042962-6947-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I get a this on the client running some lease tests:

[   38.552120] BUG: unable to handle kernel NULL pointer dereference at (null)
[   38.552723] IP: [<ffffffff811fcb3f>] vfs_setlease+0x1f/0x70
[   38.553111] PGD 56c2d067 PUD 51145067 PMD 0 
[   38.553534] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC 
[   38.554128] Modules linked in: nfsd auth_rpcgss oid_registry nfs_acl lockd grace sunrpc
[   38.555102] CPU: 0 PID: 4890 Comm: lease_tests Not tainted 4.3.0-rc3-14186-g7619b8e #322
[   38.555593] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140709_153950- 04/01/2014
[   38.556005] task: ffff880075bd8080 ti: ffff880055560000 task.ti: ffff880055560000
[   38.556005] RIP: 0010:[<ffffffff811fcb3f>]  [<ffffffff811fcb3f>] vfs_setlease+0x1f/0x70
[   38.556005] RSP: 0018:ffff880055563e98  EFLAGS: 00010246
[   38.556005] RAX: 0000000000000000 RBX: 0000000000000002 RCX: ffff880055563ec8
[   38.556005] RDX: 0000000000000000 RSI: 0000000000000002 RDI: ffff880051133e40
[   38.556005] RBP: ffff880055563eb8 R08: 0000000000000000 R09: 00007ffc941da360
[   38.556005] R10: 0000000000000008 R11: 0000000000000212 R12: ffff880051133e40
[   38.556005] R13: 0000000000000000 R14: ffff880051133e40 R15: ffff880051133e40
[   38.556005] FS:  00007fbbe6864700(0000) GS:ffff88007f800000(0000) knlGS:0000000000000000
[   38.556005] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   38.556005] CR2: 0000000000000000 CR3: 00000000590b0000 CR4: 00000000000406f0
[   38.556005] Stack:
[   38.556005]  ffff880056dd1f88 0000000000000002 0000000000000400 0000000000000002
[   38.556005]  ffff880055563ef8 ffffffff811fd4c1 ffff880051133e40 ffffffff8157b913
[   38.556005]  0000000000000000 0000000000000000 0000000000000400 0000000000000002
[   38.556005] Call Trace:
[   38.556005]  [<ffffffff811fd4c1>] fcntl_setlease+0xa1/0xd0
[   38.556005]  [<ffffffff8157b913>] ? security_file_fcntl+0x43/0x60
[   38.556005]  [<ffffffff811bc74f>] SyS_fcntl+0x31f/0x630
[   38.556005]  [<ffffffff81a77117>] entry_SYSCALL_64_fastpath+0x12/0x6f
[   38.556005] Code: ff ff 66 2e 0f 1f 84 00 00 00 00 00 66 66 66 66 90 55 48 89 e5 41 55 41 54 53 49 89 d5 49 89 fc 48 89 f3 48 83 ec 08 48 83 fe 02 <48> 8b 12 74 14 48 c7 c7 40 cb 27 83 48 89 4d e0 e8 9c d8 e9 ff 
[   38.556005] RIP  [<ffffffff811fcb3f>] vfs_setlease+0x1f/0x70
[   38.556005]  RSP <ffff880055563e98>
[   38.556005] CR2: 0000000000000000
[   38.573673] ---[ end trace 2e6e1d4b9df8a11e ]---

--b.

On Mon, Oct 05, 2015 at 07:02:22AM -0400, Jeff Layton wrote:
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
> This is the fifth iteration of the open file cache patches for nfsd.
> The main changes from the v4 set are the conversion of the code to
> use flush_delayed_fput instead of __fput_sync, and some changes to
> improve performance.
> 
> The kbuild test robot noted a drop in performance with this set,
> which turned out to be lousy hash distribution due to hashing on
> inode pointer value. Hashing on inode->i_ino gives a much better
> distribution.
> 
> For those seeing this for the first time, main impetus here is to help
> speed up NFSv3 I/O. nfsd will do an open+read/write+close for every READ
> or WRITE RPC. This patchset allows us to cache those open files more or
> less indefinitely, and close them out in response to certain vfs-layer
> activity (unlinks and setlease attempts primarily).
> 
> The first few patches in the series make (small) changes to several
> subsystems to enable the caching infrastructure. The tenth patch adds
> the cache itself, and then the remaining patches hook the nfsd code
> up to the cache. The final patch rips out the raparms cache since it's
> no longer needed with these changes.
> 
> Again, the most controversial part of the set is probably the changes
> to allow normal user processes to use the delayed_fput infrastructure.
> Al, if you could weigh in on those, then that would be helpful. We
> really do need a way to allow a thread to flush the final fput work
> without returning to userland.
> 
> Jeff Layton (20):
>   list_lru: add list_lru_rotate
>   fs: have flush_delayed_fput flush the workqueue job
>   fs: add a kerneldoc header to fput
>   fs: add fput_queue
>   fs: export flush_delayed_fput
>   fsnotify: export several symbols
>   locks: create a new notifier chain for lease attempts
>   nfsd: move include of state.h from trace.c to trace.h
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
>  fs/file_table.c              |  76 +++++-
>  fs/locks.c                   |  37 +++
>  fs/nfsd/Kconfig              |   2 +
>  fs/nfsd/Makefile             |   3 +-
>  fs/nfsd/export.c             |  14 +
>  fs/nfsd/filecache.c          | 613 +++++++++++++++++++++++++++++++++++++++++++
>  fs/nfsd/filecache.h          |  38 +++
>  fs/nfsd/nfs3proc.c           |   2 +-
>  fs/nfsd/nfs4layouts.c        |  12 +-
>  fs/nfsd/nfs4proc.c           |  32 +--
>  fs/nfsd/nfs4state.c          | 174 ++++++------
>  fs/nfsd/nfs4xdr.c            |  16 +-
>  fs/nfsd/nfsctl.c             |  10 +
>  fs/nfsd/nfsproc.c            |   2 +-
>  fs/nfsd/nfssvc.c             |  16 +-
>  fs/nfsd/state.h              |  10 +-
>  fs/nfsd/trace.c              |   2 -
>  fs/nfsd/trace.h              | 129 +++++++++
>  fs/nfsd/vfs.c                | 269 +++++--------------
>  fs/nfsd/vfs.h                |  11 +-
>  fs/nfsd/xdr4.h               |  15 +-
>  fs/notify/group.c            |   2 +
>  fs/notify/mark.c             |   3 +
>  include/linux/file.h         |   1 +
>  include/linux/fs.h           |   1 +
>  include/linux/list_lru.h     |  13 +
>  include/linux/sunrpc/cache.h |   1 +
>  mm/list_lru.c                |  15 ++
>  net/sunrpc/cache.c           |   3 +
>  29 files changed, 1149 insertions(+), 373 deletions(-)
>  create mode 100644 fs/nfsd/filecache.c
>  create mode 100644 fs/nfsd/filecache.h
> 
> -- 
> 2.4.3
