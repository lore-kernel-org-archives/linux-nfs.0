Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51764 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756697AbcJ1UXv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Oct 2016 16:23:51 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        Andreas Gruenbacher <agruenba@redhat.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 0/2] NFSv4.2 umask support
Date: Fri, 28 Oct 2016 16:23:46 -0400
Message-Id: <1477686228-12158-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The following patches allow the umask to be ignored in the presence of
inheritable NFSv4 ACLs.  Otherwise inheritable ACLs can be rendered
mostly useless whenever the umask masks out group bits.

This solves a problem we've seen complaints about for some time, both
upstream and from RHEL users.

The new protocol has been discussed in the IETF working group and is
documented at:

	https://tools.ietf.org/html/draft-ietf-nfsv4-umask-02

It's unlikely that we'll discover problems requiring an incompatible
change, so I think we should consider this for 4.10.

--b.

Andreas Gruenbacher (2):
  nfs: add support for the umask attribute
  nfsd: add support for the umask attribute

 fs/nfs/dir.c              |  7 ++++++-
 fs/nfs/nfs4proc.c         | 21 ++++++++++++++++-----
 fs/nfs/nfs4xdr.c          | 36 ++++++++++++++++++++++++------------
 fs/nfsd/nfs4xdr.c         | 26 +++++++++++++++++++++-----
 fs/nfsd/nfsd.h            |  9 +++++++--
 fs/nfsd/nfssvc.c          |  4 ++--
 include/linux/nfs4.h      |  1 +
 include/linux/nfs_fs_sb.h |  1 +
 include/linux/nfs_xdr.h   |  2 ++
 9 files changed, 80 insertions(+), 27 deletions(-)

-- 
2.7.4

