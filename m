Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35296 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751990AbbJVSfm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Oct 2015 14:35:42 -0400
Date: Thu, 22 Oct 2015 14:35:40 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>,
        Oleg Drokin <oleg.drokin@intel.com>,
        Andreas Dilger <andreas.dilger@intel.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>,
        Yan Zheng <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
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
Message-ID: <20151022183540.GC5205@fieldses.org>
References: <cover.1445535305.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1445535305.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 22, 2015 at 01:38:12PM -0400, Benjamin Coddington wrote:
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

Looks good to me.--b.

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
