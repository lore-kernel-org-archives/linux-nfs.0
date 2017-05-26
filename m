Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59946 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S967810AbdEZPaR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 26 May 2017 11:30:17 -0400
Date: Fri, 26 May 2017 11:30:16 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: Stephen Smalley <sds@tycho.nsa.gov>
Cc: selinux@tycho.nsa.gov, linux-nfs@vger.kernel.org,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trondmy@primarydata.com>
Subject: Re: [PATCH RFC 0/2] Fix setting of security labels over NFSv4.2
Message-ID: <20170526153016.5qd5vmotf5lk6s2v@tonberry.usersys.redhat.com>
References: <20170404232646.GB24146@parsley.fieldses.org>
 <20170525210754.24265-1-smayhew@redhat.com>
 <1495810097.12091.14.camel@tycho.nsa.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <1495810097.12091.14.camel@tycho.nsa.gov>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 26 May 2017, Stephen Smalley wrote:

> On Thu, 2017-05-25 at 17:07 -0400, Scott Mayhew wrote:
> > Red Hat QE reported that chcon fails over NFSv4.2 on recent kernels.
> > The problem is related to how filesystems are mounted in NFSv4.
> 
> What kernel version and what is a reproducer for the problem?  I don't
> seem to see it on e.g. Fedora 25 with 4.10, unless I misunderstand.

I'm testing with Fedora 25 but with the upstream kernel.  The Fedora
kernel doesn't have commit 32ddd944 ("nfsd: opt in to labeled nfs per
export") yet.

-Scott
> 
> > 
> > When an NFSv4 client performs a mount operation, it first mounts the
> > NFSv4 root and then does path walk to the exported path and performs
> > a
> > submount on that, cloning the security mount options from the root's
> > superblock to the submount's superblock in the process.
> > 
> > Unless the NFS server has an explicit fsid=0 export with the
> > "security_label" option, the NFSv4 root superblock will not have
> > SBLABEL_MNT set, and neither will the submount superblock after
> > cloning
> > the security mount options.  As a result, setxattr's of security
> > labels
> > over NFSv4.2 will fail.
> > 
> > NFS servers with a modern nfs-utils package will automatically create
> > a
> > pseudo fs to fill in the gaps (including the root itself) leading up
> > to
> > the actual export, so it is uncommon these days for an NFS server to
> > have an explicit fsid=0 export.
> > 
> > Allowing the NFSv4 client to override the SECURITY_LSM_NATIVE_LABELS
> > flag on an initialized superblock would ensure that SBLABEL_MNT is
> > set
> > when the client traverses from an exported path without the
> > "security_label" option to one with the "security_label" option.
> > 
> > Scott Mayhew (2):
> >   selinux: allow SECURITY_LSM_NATIVE_LABELS to be set on an already
> >     initialized superblock
> >   nfs: update labeling behavior on a superblock when submounting
> > 
> >  fs/nfs/super.c           | 23 ++++++++++++++++++++++-
> >  security/selinux/hooks.c |  4 ++--
> >  2 files changed, 24 insertions(+), 3 deletions(-)
> > 
