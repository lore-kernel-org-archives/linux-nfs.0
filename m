Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25880 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753323Ab2HBPVB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Aug 2012 11:21:01 -0400
Date: Thu, 2 Aug 2012 11:20:59 -0400
From: Jeff Layton <jlayton@redhat.com>
To: bjschuma@netapp.com
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 00/10] Create NFS modules
Message-ID: <20120802112059.57e7bb82@corrin.poochiereds.net>
In-Reply-To: <1343678725-8659-1-git-send-email-bjschuma@netapp.com>
References: <1343678725-8659-1-git-send-email-bjschuma@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 30 Jul 2012 16:05:15 -0400
bjschuma@netapp.com wrote:

> From: Bryan Schumaker <bjschuma@netapp.com>
> 
> This is the final set of patches to turn NFS into modules.  The first patch
> creates an "nfs_subversion" structure that will represent a single NFS
> version.  The next 6 patches are cleanups that the nfs_subversion structure
> allows us to put in.  Finally, the last 3 patches convert v2, v3 and v4 into
> kernel modules.
> 
> Changes in version 2:
> - Add a patch to keep nfs4 module parameters in the generic client.  Without
>   this we break backwards compatibility with older kernels.
> 
> - Bryan
> 
> Bryan Schumaker (10):
>   NFS: Add version registering framework
>   NFS: Remove the NFS v4 xdev mount function
>   NFS: Create a try_mount rpc op
>   NFS: Only initialize the ACL client in the v3 case
>   NFS: Pass super operations and xattr handlers in the nfs_subversion
>   NFS: Split out remaining NFS v4 inode functions
>   NFS: Keep module parameters in the generic NFS client
>   NFS: Convert v2 into a module
>   NFS: Convert v3 into a module
>   NFS: Convert v4 into a module
> 
>  fs/nfs/Kconfig            |   6 +-
>  fs/nfs/Makefile           |  27 +++----
>  fs/nfs/callback.c         |  24 ------
>  fs/nfs/callback.h         |   2 +-
>  fs/nfs/client.c           | 191 +++++++++++++++++++++++++---------------------
>  fs/nfs/delegation.h       |   2 +-
>  fs/nfs/dir.c              |  20 ++++-
>  fs/nfs/direct.c           |   2 +-
>  fs/nfs/dns_resolve.c      |   4 +
>  fs/nfs/file.c             |  15 ++++
>  fs/nfs/idmap.c            |   3 -
>  fs/nfs/inode.c            | 105 ++++++++++++-------------
>  fs/nfs/internal.h         |  38 +++++----
>  fs/nfs/namespace.c        |  17 +----
>  fs/nfs/netns.h            |   2 +-
>  fs/nfs/nfs.h              |  29 +++++++
>  fs/nfs/nfs2super.c        |  31 ++++++++
>  fs/nfs/nfs3client.c       |  65 ++++++++++++++++
>  fs/nfs/nfs3proc.c         |   3 +
>  fs/nfs/nfs3super.c        |  31 ++++++++
>  fs/nfs/nfs4_fs.h          |  13 ++--
>  fs/nfs/nfs4client.c       |  23 ++----
>  fs/nfs/nfs4proc.c         |   9 +--
>  fs/nfs/nfs4super.c        | 106 +++++++++++++------------
>  fs/nfs/nfs4xdr.c          |   6 --
>  fs/nfs/pagelist.c         |   4 +
>  fs/nfs/pnfs.c             |   2 +
>  fs/nfs/proc.c             |   3 +
>  fs/nfs/read.c             |   5 ++
>  fs/nfs/super.c            | 172 ++++++++++++++++++++++++++++-------------
>  fs/nfs/write.c            |  35 +++------
>  include/linux/nfs_fs.h    |   6 +-
>  include/linux/nfs_fs_sb.h |   7 +-
>  include/linux/nfs_idmap.h |   2 +-
>  include/linux/nfs_xdr.h   |   9 ++-
>  35 files changed, 632 insertions(+), 387 deletions(-)
>  create mode 100644 fs/nfs/nfs.h
>  create mode 100644 fs/nfs/nfs2super.c
>  create mode 100644 fs/nfs/nfs3client.c
>  create mode 100644 fs/nfs/nfs3super.c
> 

I'm seeing a (minor?) regression that I think is probably due to these
patches. If I plug in nfs.ko, and then unplug it, I'm unable to plug it
back in again:

# modprobe nfs
ERROR: could not insert 'nfs': Cannot allocate memory

The following shows up in dmesg:

[  344.024976] kmem_cache_create(nfs_commit_data): Cache name already exists.
[  344.033771] Pid: 1377, comm: modprobe Not tainted 3.6.0-0.rc0.git8.1.fc18.x86_64 #1
[  344.042741] Call Trace:
[  344.051119]  [<ffffffff811835f2>] kmem_cache_create+0x182/0x1e0
[  344.060250]  [<ffffffffa027509b>] ? nfs_fs_proc_init+0x9b/0x9b [nfs]
[  344.069477]  [<ffffffffa027509b>] ? nfs_fs_proc_init+0x9b/0x9b [nfs]
[  344.078508]  [<ffffffffa027537c>] nfs_init_writepagecache+0x77/0xcfb [nfs]
[  344.087653]  [<ffffffffa027515a>] init_nfs_fs+0xbf/0x190 [nfs]
[  344.096732]  [<ffffffff8100212a>] do_one_initcall+0x12a/0x180
[  344.105755]  [<ffffffff810e3636>] sys_init_module+0x156/0x2290
[  344.114936]  [<ffffffff81359320>] ? ddebug_proc_open+0xd0/0xd0
[  344.123905]  [<ffffffff811c5e40>] ? delayed_fput+0xb0/0xb0
[  344.132821]  [<ffffffff816d8369>] system_call_fastpath+0x16/0x1b
[  344.169419] FS-Cache: Netfs 'nfs' unregistered from caching
[  469.258735] FS-Cache: Netfs 'nfs' registered for caching
[  469.281508] kmem_cache_create(nfs_write_data): Cache name already exists.
[  469.290690] Pid: 1386, comm: modprobe Not tainted 3.6.0-0.rc0.git8.1.fc18.x86_64 #1
[  469.300182] Call Trace:
[  469.309102]  [<ffffffff811835f2>] kmem_cache_create+0x182/0x1e0
[  469.318609]  [<ffffffffa027509b>] ? nfs_fs_proc_init+0x9b/0x9b [nfs]
[  469.328103]  [<ffffffffa027509b>] ? nfs_fs_proc_init+0x9b/0x9b [nfs]
[  469.337475]  [<ffffffffa0275324>] nfs_init_writepagecache+0x1f/0xcfb [nfs]
[  469.347034]  [<ffffffffa027515a>] init_nfs_fs+0xbf/0x190 [nfs]
[  469.356541]  [<ffffffff8100212a>] do_one_initcall+0x12a/0x180
[  469.366093]  [<ffffffff810e3636>] sys_init_module+0x156/0x2290
[  469.375539]  [<ffffffff81359320>] ? ddebug_proc_open+0xd0/0xd0
[  469.385151]  [<ffffffff811c5e40>] ? delayed_fput+0xb0/0xb0
[  469.394555]  [<ffffffff816d8369>] system_call_fastpath+0x16/0x1b


I don't see where these are getting torn down now on module unload?

-- 
Jeff Layton <jlayton@redhat.com>
