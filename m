Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38278 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755913AbcJ2WUz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 29 Oct 2016 18:20:55 -0400
From: Andreas Gruenbacher <agruenba@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Andreas Gruenbacher <agruenba@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 0/2] NFSv4.2 mode_umask support
Date: Sun, 30 Oct 2016 00:20:50 +0200
Message-Id: <1477779652-29859-1-git-send-email-agruenba@redhat.com>
References: <1477686228-12158-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce and all,

On Fri, Oct 28, 2016 at 10:23 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
>
> The following patches allow the umask to be ignored in the presence of
> inheritable NFSv4 ACLs.  Otherwise inheritable ACLs can be rendered
> mostly useless whenever the umask masks out group bits.
>
> This solves a problem we've seen complaints about for some time, both
> upstream and from RHEL users.
>
> The new protocol has been discussed in the IETF working group and is
> documented at:
>
>         https://tools.ietf.org/html/draft-ietf-nfsv4-umask-02
>
> It's unlikely that we'll discover problems requiring an incompatible
> change, so I think we should consider this for 4.10.

the patches still refer to the new attribute as FATTR4_WORD2_UMASK which is
confusing.  Can we please call it FATTR4_WORD2_MODE_UMASK as in the patches in
this series to better match what the attribute is called in
draft-ietf-nfsv4-umask-02.

Other than refreshing the patches and renaming FATTR4_WORD2_UMASK to
FATTR4_WORD2_MODE_UMASK and NFS_CAP_UMASK to NFS_CAP_MODE_UMASK, the patches
here are the same.

Thanks,
Andreas

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

