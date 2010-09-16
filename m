Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29752 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752984Ab0IPVCF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Sep 2010 17:02:05 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: viro@zeniv.linux.org.uk, hch@infradead.org
Subject: [PATCH 0/6] Remove struct nameidata from lower level NFS code
Date: Thu, 16 Sep 2010 17:01:37 -0400
Message-Id: <1284670903-28475-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Hi,

The following patches attempt to clean up the atomic open code so that we
keep all the functions that depend on the struct nameidata in fs/nfs/dir.c.
Instead of passing down the struct nameidata, we have the lower layer NFSv4
code fill in the nfs_open_context, which can then be used by nfs_atomic_lookup
to fill in the struct file.

Cheers
  Trond

Trond Myklebust (6):
  NFSv4: Clean up nfs4_atomic_open
  NFSv4: Further minor cleanups for nfs4_atomic_open()
  NFSv4: Clean up nfs4_open_revalidate
  NFSv4: Further cleanups for nfs4_open_revalidate()
  NFS: Clean up nfs4_proc_create()
  NFS: Add an 'open_context' element to struct nfs_rpc_ops

 fs/nfs/dir.c            |  179 ++++++++++++++++++++++++++++++++++++++++++----
 fs/nfs/inode.c          |    8 +-
 fs/nfs/nfs3proc.c       |    2 +-
 fs/nfs/nfs4_fs.h        |    2 -
 fs/nfs/nfs4proc.c       |  148 ++++++---------------------------------
 fs/nfs/proc.c           |    2 +-
 include/linux/nfs_fs.h  |    2 +
 include/linux/nfs_xdr.h |    6 ++-
 8 files changed, 198 insertions(+), 151 deletions(-)

-- 
1.7.2.3

