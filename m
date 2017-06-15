Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50794 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751732AbdFOU7Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 15 Jun 2017 16:59:16 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>, mszeredi@redhat.com,
        bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/2] nfs_complete_rename() calls d_move() without i_mutex
Date: Thu, 15 Jun 2017 16:59:12 -0400
Message-Id: <cover.1497559453.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Once commit 920b4530fb80430ff30ef83efe21ba1fa5623731 "NFS: nfs_rename()
handle -ERESTARTSYS dentry left behind" moved the local d_move() into the
RPC asyncronous context, d_move() could be called without holding the
directories' i_mutex.

Let's revert that commit, and a follow-up fix for it in 1/2, and then fix
the original problem once more by forcing a revalidation of the old and new
directories if we notice that the rename was interrupted in 2/2.

v2:  Add memory barrier, hold directory i_locks while revalidating, specify
     single-bit field width for cancelled flag.

Benjamin Coddington (2):
  Revert "NFS: nfs_rename() handle -ERESTARTSYS dentry left behind"
  NFS: nfs_rename() - revalidate directories on -ERESTARTSYS

 fs/nfs/dir.c            | 50 ++++++++++++++++++++++---------------------------
 fs/nfs/unlink.c         | 11 +++++++++++
 include/linux/nfs_xdr.h |  1 +
 3 files changed, 34 insertions(+), 28 deletions(-)

-- 
2.9.3

