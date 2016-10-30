Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36694 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751012AbcJ3N7v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 30 Oct 2016 09:59:51 -0400
Date: Sun, 30 Oct 2016 09:59:49 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Subject: Re: [PATCH 0/2] NFSv4.2 mode_umask support
Message-ID: <20161030135949.GA32718@parsley.fieldses.org>
References: <1477686228-12158-1-git-send-email-bfields@redhat.com>
 <1477779652-29859-1-git-send-email-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1477779652-29859-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Oct 30, 2016 at 12:20:50AM +0200, Andreas Gruenbacher wrote:
> Bruce and all,
> 
> On Fri, Oct 28, 2016 at 10:23 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> >
> > The following patches allow the umask to be ignored in the presence of
> > inheritable NFSv4 ACLs.  Otherwise inheritable ACLs can be rendered
> > mostly useless whenever the umask masks out group bits.
> >
> > This solves a problem we've seen complaints about for some time, both
> > upstream and from RHEL users.
> >
> > The new protocol has been discussed in the IETF working group and is
> > documented at:
> >
> >         https://tools.ietf.org/html/draft-ietf-nfsv4-umask-02
> >
> > It's unlikely that we'll discover problems requiring an incompatible
> > change, so I think we should consider this for 4.10.
> 
> the patches still refer to the new attribute as FATTR4_WORD2_UMASK which is
> confusing.  Can we please call it FATTR4_WORD2_MODE_UMASK as in the patches in
> this series to better match what the attribute is called in
> draft-ietf-nfsv4-umask-02.

Thanks!--b.

> 
> Other than refreshing the patches and renaming FATTR4_WORD2_UMASK to
> FATTR4_WORD2_MODE_UMASK and NFS_CAP_UMASK to NFS_CAP_MODE_UMASK, the patches
> here are the same.
> 
> Thanks,
> Andreas
> 
> Andreas Gruenbacher (2):
>   nfs: add support for the umask attribute
>   nfsd: add support for the umask attribute
> 
>  fs/nfs/dir.c              |  7 ++++++-
>  fs/nfs/nfs4proc.c         | 21 ++++++++++++++++-----
>  fs/nfs/nfs4xdr.c          | 36 ++++++++++++++++++++++++------------
>  fs/nfsd/nfs4xdr.c         | 26 +++++++++++++++++++++-----
>  fs/nfsd/nfsd.h            |  9 +++++++--
>  fs/nfsd/nfssvc.c          |  4 ++--
>  include/linux/nfs4.h      |  1 +
>  include/linux/nfs_fs_sb.h |  1 +
>  include/linux/nfs_xdr.h   |  2 ++
>  9 files changed, 80 insertions(+), 27 deletions(-)
> 
> -- 
> 2.7.4
> 
