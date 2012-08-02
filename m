Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:30662 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752563Ab2HBTBS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Aug 2012 15:01:18 -0400
Date: Thu, 2 Aug 2012 15:01:15 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 00/10] Create NFS modules
Message-ID: <20120802150115.3647bf9e@tlielax.poochiereds.net>
In-Reply-To: <501AC947.6020001@netapp.com>
References: <1343678725-8659-1-git-send-email-bjschuma@netapp.com>
	<20120802112059.57e7bb82@corrin.poochiereds.net>
	<501A9C33.5010805@netapp.com>
	<20120802143333.0d28bab5@tlielax.poochiereds.net>
	<501AC947.6020001@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 02 Aug 2012 14:39:03 -0400
Bryan Schumaker <bjschuma@netapp.com> wrote:

> On 08/02/2012 02:33 PM, Jeff Layton wrote:
> > On Thu, 02 Aug 2012 11:26:43 -0400
> > Bryan Schumaker <bjschuma@netapp.com> wrote:
> > 
> >> On 08/02/2012 11:20 AM, Jeff Layton wrote:
> >>> On Mon, 30 Jul 2012 16:05:15 -0400
> >>> bjschuma@netapp.com wrote:
> >>>
> >>>> From: Bryan Schumaker <bjschuma@netapp.com>
> >>>>
> >>>> This is the final set of patches to turn NFS into modules.  The first patch
> >>>> creates an "nfs_subversion" structure that will represent a single NFS
> >>>> version.  The next 6 patches are cleanups that the nfs_subversion structure
> >>>> allows us to put in.  Finally, the last 3 patches convert v2, v3 and v4 into
> >>>> kernel modules.
> >>>>
> >>>> Changes in version 2:
> >>>> - Add a patch to keep nfs4 module parameters in the generic client.  Without
> >>>>   this we break backwards compatibility with older kernels.
> >>>>
> >>>> - Bryan
> >>>>
> >>>> Bryan Schumaker (10):
> >>>>   NFS: Add version registering framework
> >>>>   NFS: Remove the NFS v4 xdev mount function
> >>>>   NFS: Create a try_mount rpc op
> >>>>   NFS: Only initialize the ACL client in the v3 case
> >>>>   NFS: Pass super operations and xattr handlers in the nfs_subversion
> >>>>   NFS: Split out remaining NFS v4 inode functions
> >>>>   NFS: Keep module parameters in the generic NFS client
> >>>>   NFS: Convert v2 into a module
> >>>>   NFS: Convert v3 into a module
> >>>>   NFS: Convert v4 into a module
> >>>>
> >>>>  fs/nfs/Kconfig            |   6 +-
> >>>>  fs/nfs/Makefile           |  27 +++----
> >>>>  fs/nfs/callback.c         |  24 ------
> >>>>  fs/nfs/callback.h         |   2 +-
> >>>>  fs/nfs/client.c           | 191 +++++++++++++++++++++++++---------------------
> >>>>  fs/nfs/delegation.h       |   2 +-
> >>>>  fs/nfs/dir.c              |  20 ++++-
> >>>>  fs/nfs/direct.c           |   2 +-
> >>>>  fs/nfs/dns_resolve.c      |   4 +
> >>>>  fs/nfs/file.c             |  15 ++++
> >>>>  fs/nfs/idmap.c            |   3 -
> >>>>  fs/nfs/inode.c            | 105 ++++++++++++-------------
> >>>>  fs/nfs/internal.h         |  38 +++++----
> >>>>  fs/nfs/namespace.c        |  17 +----
> >>>>  fs/nfs/netns.h            |   2 +-
> >>>>  fs/nfs/nfs.h              |  29 +++++++
> >>>>  fs/nfs/nfs2super.c        |  31 ++++++++
> >>>>  fs/nfs/nfs3client.c       |  65 ++++++++++++++++
> >>>>  fs/nfs/nfs3proc.c         |   3 +
> >>>>  fs/nfs/nfs3super.c        |  31 ++++++++
> >>>>  fs/nfs/nfs4_fs.h          |  13 ++--
> >>>>  fs/nfs/nfs4client.c       |  23 ++----
> >>>>  fs/nfs/nfs4proc.c         |   9 +--
> >>>>  fs/nfs/nfs4super.c        | 106 +++++++++++++------------
> >>>>  fs/nfs/nfs4xdr.c          |   6 --
> >>>>  fs/nfs/pagelist.c         |   4 +
> >>>>  fs/nfs/pnfs.c             |   2 +
> >>>>  fs/nfs/proc.c             |   3 +
> >>>>  fs/nfs/read.c             |   5 ++
> >>>>  fs/nfs/super.c            | 172 ++++++++++++++++++++++++++++-------------
> >>>>  fs/nfs/write.c            |  35 +++------
> >>>>  include/linux/nfs_fs.h    |   6 +-
> >>>>  include/linux/nfs_fs_sb.h |   7 +-
> >>>>  include/linux/nfs_idmap.h |   2 +-
> >>>>  include/linux/nfs_xdr.h   |   9 ++-
> >>>>  35 files changed, 632 insertions(+), 387 deletions(-)
> >>>>  create mode 100644 fs/nfs/nfs.h
> >>>>  create mode 100644 fs/nfs/nfs2super.c
> >>>>  create mode 100644 fs/nfs/nfs3client.c
> >>>>  create mode 100644 fs/nfs/nfs3super.c
> >>>>
> >>>
> >>> I'm seeing a (minor?) regression that I think is probably due to these
> >>> patches. If I plug in nfs.ko, and then unplug it, I'm unable to plug it
> >>> back in again:
> >>
> >> Thanks for letting me know, I'll look into it today.
> >>
> >> - Bryan
> >>
> > 
> > It was blocking some other testing so I went ahead and fixed it. It
> > looks like this was not introduced by these patches, but was a
> > long-standing bug. That patch should probably go to stable too, but I
> > haven't vetted it to make sure it'll apply cleanly to earlier kernels
> > yet.
> 
> Ah, thank you!
> 
> > 
> > For the life of me though, I don't understand why it wasn't biting us
> > before the above set went in however...
> 
> Maybe something else that was recently merged broke it?
> 
> - Bryan
> 

That seems to be the case. Looks like the check for a duplicate cache
name is new for SLUB as of commit 20cea968.
-- 
Jeff Layton <jlayton@redhat.com>
