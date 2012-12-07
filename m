Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fn.samba.org ([216.83.154.106]:51617 "EHLO mail.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756397Ab2LGPhr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Dec 2012 10:37:47 -0500
Message-ID: <1354894665.14719.87.camel@pico.ipa.ssimo.org>
Subject: Re: [PATCH 0/3] Add O_DENY* flags to fcntl and cifs
From: simo <idra@samba.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Pavel Shilovsky <piastry@etersoft.ru>, linux-cifs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        wine-devel@winehq.org, linux-nfs@vger.kernel.org
Date: Fri, 07 Dec 2012 10:37:45 -0500
In-Reply-To: <20121207145206.GF17115@fieldses.org>
References: <1354818391-7968-1-git-send-email-piastry@etersoft.ru>
	 <CAKywueQ3d=wdq2nw5f-QS-D9PY70Axa3Cn0gi5GRk4Xso+iquA@mail.gmail.com>
	 <20121207145206.GF17115@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2012-12-07 at 09:52 -0500, J. Bruce Fields wrote:
> On Fri, Dec 07, 2012 at 01:08:46PM +0400, Pavel Shilovsky wrote:
> > 2012/12/6 Pavel Shilovsky <piastry@etersoft.ru>:
> > > Network filesystems CIFS, SMB2.0, SMB3.0 and NFSv4 have such flags - this change can benefit cifs and nfs modules. While this change is ok for network filesystems, itsn't not targeted for local filesystems due security problems (e.g. when a user process can deny root to delete a file).
> > >
> > > Share flags are used by Windows applications and WINE have to deal with them too. While WINE can process open share flags itself on local filesystems, it can't do it if a file stored on a network share and is used by several clients. This patchset makes it possible for CIFS/SMB2.0/SMB3.0.
> > >
> > > Pavel Shilovsky (3):
> > >   fcntl: Introduce new O_DENY* open flags for network filesystems
> > >   CIFS: Add O_DENY* open flags support
> > >   CIFS: Use NT_CREATE_ANDX command for forcemand mounts
> > >
> > >  fs/cifs/cifsacl.c                |   10 ++++----
> > >  fs/cifs/cifsglob.h               |   11 ++++++++-
> > >  fs/cifs/cifsproto.h              |    9 ++++----
> > >  fs/cifs/cifssmb.c                |   47 ++++++++++++++++++++------------------
> > >  fs/cifs/dir.c                    |   14 ++++++++----
> > >  fs/cifs/file.c                   |   18 ++++++++++-----
> > >  fs/cifs/inode.c                  |   11 +++++----
> > >  fs/cifs/link.c                   |   10 ++++----
> > >  fs/cifs/readdir.c                |    2 +-
> > >  fs/cifs/smb1ops.c                |   15 ++++++------
> > >  fs/cifs/smb2file.c               |   10 ++++----
> > >  fs/cifs/smb2inode.c              |    4 ++--
> > >  fs/cifs/smb2ops.c                |   10 ++++----
> > >  fs/cifs/smb2pdu.c                |    6 ++---
> > >  fs/cifs/smb2proto.h              |   14 +++++++-----
> > >  fs/fcntl.c                       |    5 ++--
> > >  include/uapi/asm-generic/fcntl.h |   11 +++++++++
> > >  17 files changed, 125 insertions(+), 82 deletions(-)
> > >
> > > --
> > > 1.7.10.4
> > >
> > 
> > First of all, sorry for being unclear at this proposal.
> > 
> > 
> > I am not from Wine team but I am working on things related to
> > Wine+CIFS-client+Samba.
> > 
> > We (at Etersoft) need to organize the work of Wine applications
> > through cifs-client share mounted to Samba (or Windows server). They
> > are related to accounting (mostly Russian ones - e.g.
> > http://www.1c.ru/eng/title.htm). So, the problem is that such
> > applications use share flags to control the parallel access to the
> > same files of several clients on a remote share. Also, there can be a
> > situation where Windows (native) clients and Wine clients are working
> > together in the same time.
> > 
> > That's why we need such flags in the kernel (patch #1). With these
> > flags Wine can pass them to every open and they will be used by CIFS
> > (and probably NFS) file systems to pass to the Samba server. In the
> > same time if the file is on local filesystem - these flags will be
> > simply ignored (not implemented).
> 
> NFS supports the deny-read and deny-write bits but not deny-delete.
> 
> If we could do such opens in-kernel on local and clustered filesystems,
> that could also be useful for multi-protocol (Samba and NFS) and
> clustered exports.
> 
> Currently knfsd tries to enforce deny bits in the nfsd code, which is a
> bit ugly.
> 
> And knfsd currently requires write permissions for deny-read.  My
> understanding is that Windows considers that wrong, but I'd be curious
> to know whether that breaks Windows applications in practice.

It probably does if you look hard enough.
IIRC Deny-reads are very loosely like read locks, and you can take read
locks if you have read-only access.
Why does knfsd restrict deny-read to read-write access ?

Simo.

-- 
Simo Sorce
Samba Team GPL Compliance Officer <simo@samba.org>
Principal Software Engineer at Red Hat, Inc. <simo@redhat.com>

