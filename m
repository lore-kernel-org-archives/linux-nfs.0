Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38550 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S968363AbdEZPSx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 26 May 2017 11:18:53 -0400
Date: Fri, 26 May 2017 11:18:43 -0400
From: "J . Bruce Fields" <bfields@fieldses.org>
To: Stephen Smalley <sds@tycho.nsa.gov>
Cc: Scott Mayhew <smayhew@redhat.com>, selinux@tycho.nsa.gov,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <trondmy@primarydata.com>
Subject: Re: [PATCH RFC 0/2] Fix setting of security labels over NFSv4.2
Message-ID: <20170526151843.GD4593@fieldses.org>
References: <20170404232646.GB24146@parsley.fieldses.org>
 <20170525210754.24265-1-smayhew@redhat.com>
 <1495810097.12091.14.camel@tycho.nsa.gov>
 <20170526151722.GC4593@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20170526151722.GC4593@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 26, 2017 at 11:17:22AM -0400, J . Bruce Fields wrote:
> On Fri, May 26, 2017 at 10:48:17AM -0400, Stephen Smalley wrote:
> > On Thu, 2017-05-25 at 17:07 -0400, Scott Mayhew wrote:
> > > Red Hat QE reported that chcon fails over NFSv4.2 on recent kernels.
> > > The problem is related to how filesystems are mounted in NFSv4.
> > 
> > What kernel version and what is a reproducer for the problem?  I don't
> > seem to see it on e.g. Fedora 25 with 4.10, unless I misunderstand.
> 
> Basically just mount an export with security_label set, mount over NFS,
> "ls -Z" will (correctly) show you the server-side security labels, but
> "chcon" will fail with ENOTSUP.
> 
> If that's not reproducing, maybe you chould show us "exports -v" and
> "mount" output--it might not reproduce if you have an "fsid=0" export or
> if you're mounting with a protocol version older than 4.2.

Oh, and, sorry, kernel version: I think you just need something recent
enough to support "security_label", which went into 4.11.

--b.

> 
> --b.
> 
> > 
> > > 
> > > When an NFSv4 client performs a mount operation, it first mounts the
> > > NFSv4 root and then does path walk to the exported path and performs
> > > a
> > > submount on that, cloning the security mount options from the root's
> > > superblock to the submount's superblock in the process.
> > > 
> > > Unless the NFS server has an explicit fsid=0 export with the
> > > "security_label" option, the NFSv4 root superblock will not have
> > > SBLABEL_MNT set, and neither will the submount superblock after
> > > cloning
> > > the security mount options.  As a result, setxattr's of security
> > > labels
> > > over NFSv4.2 will fail.
> > > 
> > > NFS servers with a modern nfs-utils package will automatically create
> > > a
> > > pseudo fs to fill in the gaps (including the root itself) leading up
> > > to
> > > the actual export, so it is uncommon these days for an NFS server to
> > > have an explicit fsid=0 export.
> > > 
> > > Allowing the NFSv4 client to override the SECURITY_LSM_NATIVE_LABELS
> > > flag on an initialized superblock would ensure that SBLABEL_MNT is
> > > set
> > > when the client traverses from an exported path without the
> > > "security_label" option to one with the "security_label" option.
> > > 
> > > Scott Mayhew (2):
> > >   selinux: allow SECURITY_LSM_NATIVE_LABELS to be set on an already
> > >     initialized superblock
> > >   nfs: update labeling behavior on a superblock when submounting
> > > 
> > >  fs/nfs/super.c           | 23 ++++++++++++++++++++++-
> > >  security/selinux/hooks.c |  4 ++--
> > >  2 files changed, 24 insertions(+), 3 deletions(-)
> > > 
