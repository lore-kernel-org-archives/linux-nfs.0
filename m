Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55610 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752784Ab2D2UuZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Apr 2012 16:50:25 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 00/15] Optimise away unnecessary NFSv4 post-op attributes
Date: Sun, 29 Apr 2012 16:50:05 -0400
Message-Id: <1335732620-10445-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following set of patches adds support for simulating 'change attributes'
in NFSv2/v3 by converting the file ctime into a 64-bit value that can
be stored in inode->i_version.
With this change, we can then proceed to simplify the attribute cache
consistency code so that it only uses the change attribute to determine
whether or not the data and attribute caches are consistent.

Once the cache consistency only depends on the change attribute, we
can optimise away unnecessary requests for the directory post-op
attributes on NFSv4 OPEN, CREATE, REMOVE, LINK and RENAME compounds,
since those operations all supply a 'change_info4' field describing
the directory change attribute.

Finally, we can stop requesting cache consistency attributes altogether
for O_DIRECT and delegated WRITEs, as well as for all COMMIT calls.

v2: Don't request cache consistency attributes on writes and commits
    Delegreturn only needs the cache consistency bitmask
    Simplify the simulated change attribute calculation for v2/v3
v3: Fix a race in delegreturn
v4: Fix an Oops in nfs4_write_done_cb because data->res.fattr was not set.
    COMMIT does not need to return post-op attributes at all.
    Don't force page cache revalidations when holding a delegation
    Optimise away nfs_check_inode_attributes() when holding a delegation
    Always trust the PageUptodate flag when we have a delegation

Trond Myklebust (15):
  NFSv4: Fix a typo in NFS4_enc_link_sz
  NFSv4: Delegreturn only needs the cache consistency bitmask
  NFSv4: Retrieve attributes _before_ calling delegreturn
  NFS: Don't force page cache revalidations when holding a delegation
  NFS: Optimise away nfs_check_inode_attributes() when holding a
    delegation
  NFS: Always trust the PageUptodate flag when we have a delegation
  NFS: Simplify nfs_fhget()
  NFS: Change attribute updates should set NFS_INO_REVAL_PAGECACHE
  NFSv2/v3: Simulate the change attribute
  NFS: Simplify the cache invalidation code
  NFSv4: Simplify the NFSv4 OPEN compound
  NFSv4: Simplify the NFSv4 CREATE compound
  NFSv4: Simplify the NFSv4 REMOVE, LINK and RENAME compounds
  NFSv4: Don't request cache consistency attributes on some writes
  NFSv4: COMMIT does not need post-op attributes

 fs/nfs/client.c         |    2 +-
 fs/nfs/inode.c          |   73 +++++++++++++-----------------------
 fs/nfs/internal.h       |   12 ++++++
 fs/nfs/nfs2xdr.c        |    2 +
 fs/nfs/nfs3xdr.c        |    3 +
 fs/nfs/nfs4proc.c       |   83 +++++++++++++----------------------------
 fs/nfs/nfs4xdr.c        |   94 ++++++-----------------------------------------
 fs/nfs/write.c          |   10 +++-
 include/linux/nfs_xdr.h |   11 +----
 9 files changed, 92 insertions(+), 198 deletions(-)

-- 
1.7.7.6

