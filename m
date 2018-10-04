Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55978 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726804AbeJDHyE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 Oct 2018 03:54:04 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Trond Myklebust <trond.myklebust@hammerspace.com>
Date: Thu, 04 Oct 2018 11:02:43 +1000
Subject: [PATCH 0/3] Fix regression in NFSv3 ACL setting
Cc: Jan Harkes <jaharkes@cs.cmu.edu>, linux-nfs@vger.kernel.org,
        Miklos Szeredi <miklos@szeredi.hu>,
        Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, David Howells <dhowells@redhat.com>,
        coda@cs.cmu.edu, linux-fsdevel@vger.kernel.org,
        Christoph Hellwig <hch@lst.de>
Message-ID: <153861471803.30373.6184444014227748848.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 013cdf1088d7 ("nfs: use generic posix ACL infrastructure for v3
Posix ACLs") introduce a regression for NFSv3 ACL setting.
An owner should be able to set an ACL, but the new code tests for
ownership in a way that is not reliable for NFSv3.  For NFSv3 the only
reliable test is to send the request to the server and see if it works.

The first patch introduces MAY_ACT_AS_OWNER and relies on the
filesystem to do the appropriate ownership test.  This touches
several filesystems, hence the long 'Cc' list.
Following two patches are small code cleanups relating to this.

Thanks,
NeilBrown


---

NeilBrown (3):
      VFS: introduce MAY_ACT_AS_OWNER
      VFS: allow MAY_ flags to be easily extended.
      NFSD - Use MAY_ACT_AS_OWNER


 fs/afs/security.c  |   10 ++++++++++
 fs/attr.c          |   12 +++++-------
 fs/coda/dir.c      |   10 ++++++++++
 fs/fcntl.c         |    2 +-
 fs/fuse/dir.c      |   10 ++++++++++
 fs/namei.c         |    9 +++++++++
 fs/nfs/dir.c       |    8 ++++++++
 fs/nfsd/vfs.c      |   11 ++++++-----
 fs/nfsd/vfs.h      |   33 ++++++++++++++++++---------------
 fs/posix_acl.c     |    2 +-
 fs/xattr.c         |    2 +-
 include/linux/fs.h |   10 ++++++++++
 12 files changed, 89 insertions(+), 30 deletions(-)

--
Signature
