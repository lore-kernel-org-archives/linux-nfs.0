Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49017 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752644AbdKIHuo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Nov 2017 02:50:44 -0500
From: NeilBrown <neilb@suse.com>
To: Ian Kent <ikent@redhat.com>, Latchesar Ionkov <lucho@ionkov.net>,
        Jeff Layton <jlayton@redhat.com>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Ron Minnich <rminnich@sandia.gov>,
        Trond Myklebust <trondmy@primarydata.com>
Date: Thu, 09 Nov 2017 18:20:24 +1100
Subject: [PATCH 0/3] VFS: name lookup improvements.
Cc: linux-nfs@vger.kernel.org, autofs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        v9fs-developer@lists.sourceforge.net,
        Linus Torvalds <torvalds@linux-foundation.org>
Message-ID: <151021179901.22743.15252956909042161062.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These three patches address two issues: d_weak_revalidate and
path_mountpoint lookups.

The former is poorly defined and doesn't actually do the one thing
that it would be useful for it to do.  So the nfs implemention
is improved, the 9p one discarded, and the documentation clarified.

Given this change and recent change to follow_automount() the
mountpoint path lookup functions are no longer needed.  The regular
path look functions are quite sufficient.
The second two patches remove this with detailed explanation of why
it is OK.

Thanks,
NeilBrown


---

NeilBrown (3):
      VFS/nfs/9p: revise meaning of d_weak_invalidate.
      VFS: remove user_path_mountpoint_at()
      VFS / autofs4: remove kern_path_mountpoint()


 Documentation/filesystems/porting |    5 +
 Documentation/filesystems/vfs.txt |   11 +--
 fs/9p/vfs_dentry.c                |    1 
 fs/autofs4/dev-ioctl.c            |    5 -
 fs/internal.h                     |    1 
 fs/namei.c                        |  150 -------------------------------------
 fs/namespace.c                    |    2 
 fs/nfs/dir.c                      |   60 ++-------------
 include/linux/namei.h             |    1 
 9 files changed, 24 insertions(+), 212 deletions(-)

--
Signature

