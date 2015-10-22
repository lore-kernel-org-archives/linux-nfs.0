Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:35852 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758116AbbJVSpi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Oct 2015 14:45:38 -0400
Received: by qkca6 with SMTP id a6so58193635qkc.3
        for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2015 11:45:37 -0700 (PDT)
Date: Thu, 22 Oct 2015 14:45:33 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>,
        Oleg Drokin <oleg.drokin@intel.com>,
        Andreas Dilger <andreas.dilger@intel.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>,
        "Yan Zheng" <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
        Ilya Dryomov <idryomov@gmail.com>, Steve French <sfrench@samba.org>,
        Christine Caulfield <ccaulfie@redhat.com>,
        David Teigland <teigland@redhat.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        Steven Whitehouse <swhiteho@redhat.com>,
        Bob Peterson <rpeterso@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        aybuke ozdemir <aybuke.147@gmail.com>,
        Julia Lawall <Julia.Lawall@lip6.fr>,
        Abdul Hussain <habdul@visteon.com>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH V2 0/3] Minor cleanup for locks API
Message-ID: <20151022144533.5c8471bc@synchrony.poochiereds.net>
In-Reply-To: <cover.1445535305.git.bcodding@redhat.com>
References: <cover.1445535305.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 22 Oct 2015 13:38:12 -0400
Benjamin Coddington <bcodding@redhat.com> wrote:

> NFS has recently been moving things around to cope with the situation where
> a struct file may not be available during an unlock.  That work has
> presented an opportunity to do a minor cleanup on the locks API.
> 
> Users of posix_lock_file_wait() (for FL_POSIX style locks) and
> flock_lock_file_wait() (for FL_FLOCK style locks) can instead call
> locks_lock_file_wait() for both lock types.  Because the passed-in file_lock
> specifies its own type, the correct function can be selected on behalf of
> the user.
> 
> This work allows further cleanup within NFS and lockd which will be
> submitted separately.
> 
> Changes in v2:
> 	- fix typo that caused build failure for CONFIG_FILE_LOCKS=n
> 	- make posix_lock_inode_wait and flock_lock_inode_wait static
> 	- trimmed away a number of distro-lists to minimize cross-posting
> 
> Benjamin Coddington (3):
>   locks: introduce locks_lock_inode_wait()
>   Move locks API users to locks_lock_inode_wait()
>   locks: cleanup posix_lock_inode_wait and flock_lock_inode_wait
> 
>  drivers/staging/lustre/lustre/llite/file.c |    8 +----
>  fs/9p/vfs_file.c                           |    4 +-
>  fs/ceph/locks.c                            |    4 +-
>  fs/cifs/file.c                             |    2 +-
>  fs/dlm/plock.c                             |    4 +-
>  fs/fuse/file.c                             |    2 +-
>  fs/gfs2/file.c                             |    8 +++---
>  fs/lockd/clntproc.c                        |   13 +---------
>  fs/locks.c                                 |   35 ++++++++++++++++++++++-----
>  fs/nfs/file.c                              |   13 +---------
>  fs/nfs/nfs4proc.c                          |   13 +---------
>  fs/ocfs2/locks.c                           |    8 +++---
>  include/linux/fs.h                         |   21 +++-------------
>  13 files changed, 53 insertions(+), 82 deletions(-)
> 

Looks good to me too. I'll plan to merge them for v4.4.

Thanks!
-- 
Jeff Layton <jlayton@poochiereds.net>
