Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:42250 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751748Ab2D1UZ3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Apr 2012 16:25:29 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 00/11] Optimise away unnecessary NFSv4 post-op attributes
Date: Sat, 28 Apr 2012 16:25:09 -0400
Message-Id: <1335644720-28305-1-git-send-email-Trond.Myklebust@netapp.com>
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
for O_DIRECT writes and commits (they are uncached) as well as for
delegated writes and commits.

v2: Don't request cache consistency attributes on writes and commits
    Delegreturn only needs the cache consistency bitmask
    Simplify the simulated change attribute calculation for v2/v3
v3: Fix a race in delegreturn

Trond Myklebust (11):
  NFSv4: Fix a typo in NFS4_enc_link_sz
  NFSv4: Delegreturn only needs the cache consistency bitmask
  NFSv4: Retrieve attributes _before_ calling delegreturn
  NFS: Simplify nfs_fhget()
  NFS: Change attribute updates should set NFS_INO_REVAL_PAGECACHE
  NFSv2/v3: Simulate the change attribute
  NFS: Simplify the cache invalidation code
  NFSv4: Simplify the NFSv4 OPEN compound
  NFSv4: Simplify the NFSv4 CREATE compound
  NFSv4: Simplify the NFSv4 REMOVE, LINK and RENAME compounds
  NFSv4: Don't request cache consistency attributes on some writes and
    commits

 fs/nfs/client.c         |    2 +-
 fs/nfs/inode.c          |   58 +++++++-----------------------
 fs/nfs/internal.h       |   12 ++++++
 fs/nfs/nfs2xdr.c        |    2 +
 fs/nfs/nfs3xdr.c        |    3 ++
 fs/nfs/nfs4proc.c       |   88 ++++++++++++++++++++---------------------------
 fs/nfs/nfs4xdr.c        |   82 +++++--------------------------------------
 include/linux/nfs_xdr.h |   11 ++----
 8 files changed, 82 insertions(+), 176 deletions(-)

-- 
1.7.7.6

