Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46507 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755932AbbJVPgA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Oct 2015 11:36:00 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Christoph Hellwig <hch@infradead.org>, Oleg Drokin <oleg.drokin@intel.com>,
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
        Abdul Hussain <habdul@visteon.com>, lustre-devel@lists.lustre.org,
        devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
        v9fs-developer@lists.sourceforge.net, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        cluster-devel@redhat.com, fuse-devel@lists.sourceforge.net,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        ocfs2-devel@oss.oracle.com
Subject: [PATCH 0/3] Minor cleanup for locks API
Date: Thu, 22 Oct 2015 11:35:53 -0400
Message-Id: <cover.1445524157.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS has recently been moving things around to cope with the situation where
a struct file may not be available during an unlock.  That work has
presented an opportunity to do a minor cleanup on the locks API.

Users of posix_lock_file_wait() (for FL_POSIX style locks) and
flock_lock_file_wait() (for FL_FLOCK style locks) can instead call
locks_lock_file_wait() for both lock types.  Because the passed-in file_lock
specifies its own type, the correct function can be selected on behalf of
the user.

This work allows further cleanup within NFS and lockd which will be
submitted separately.

Benjamin Coddington (3):
  locks: introduce locks_lock_inode_wait()
  Move locks API users to locks_lock_inode_wait()
  locks: cleanup posix_lock_inode_wait and flock_lock_inode_wait

 drivers/staging/lustre/lustre/llite/file.c |    8 +-----
 fs/9p/vfs_file.c                           |    4 +-
 fs/ceph/locks.c                            |    4 +-
 fs/cifs/file.c                             |    2 +-
 fs/dlm/plock.c                             |    4 +-
 fs/fuse/file.c                             |    2 +-
 fs/gfs2/file.c                             |    8 +++---
 fs/lockd/clntproc.c                        |   13 +----------
 fs/locks.c                                 |   31 +++++++++++++++++++++++----
 fs/nfs/file.c                              |   13 +----------
 fs/nfs/nfs4proc.c                          |   13 +----------
 fs/ocfs2/locks.c                           |    8 +++---
 include/linux/fs.h                         |   21 +++---------------
 13 files changed, 51 insertions(+), 80 deletions(-)

