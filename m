Return-Path: linux-nfs-owner@vger.kernel.org
Received: from peace.netnation.com ([204.174.223.2]:57677 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758198Ab2CAWpm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Mar 2012 17:45:42 -0500
Date: Thu, 1 Mar 2012 14:45:39 -0800
From: Simon Kirby <sim@netnation.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [3.2.5] Stale NFS file handle issue on subdirectory of NFSv3
	mount
Message-ID: <20120301224539.GA27595@hostway.ca>
References: <20120229010629.GC24948@hostway.ca> <1330477890.3053.93.camel@lade.trondhjem.org> <20120229195916.GB8092@hostway.ca> <20120229201401.GA5253@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120229201401.GA5253@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 29, 2012 at 03:14:01PM -0500, J. Bruce Fields wrote:

> On Wed, Feb 29, 2012 at 11:59:16AM -0800, Simon Kirby wrote:
> > On Wed, Feb 29, 2012 at 01:11:31AM +0000, Myklebust, Trond wrote:
> > 
> > > On Tue, 2012-02-28 at 17:06 -0800, Simon Kirby wrote:
> > > > Hi,
> > > > 
> > > > Since upgrading from 2.6.39-ish to 3.1-ish, and on 3.2.5, we are seeing a
> > > > lot of occurrences of Stale NFS file handle errors when accessing a mount
> > > > whose NFSv3 source is a subdirectory of another mount point. For example,
> > > > in this case:
> > > > 
> > > > # mount | grep /shared
> > > > 10.10.1.1:/storage/vg1/shared on /shared type nfs (rw,hard,intr,tcp,timeo=300,retrans=2,vers=3,addr=10.10.1.1)
> > > > 10.10.1.1:/storage/vg1/shared/fp on /usr/local/fp type nfs (rw,hard,intr,tcp,timeo=300,retrans=2,vers=3,addr=10.10.1.1)
> > > > 
> > > > When the issue occurs, the /shared mount point is fine as is /shared/fp,
> > > > but "df" or "ls" or anything on /usr/local/fp will ESTALE. This somehow
> > > > corrected itself while I was trying to gather information this time, but
> > > > usually the d_ino returned by getdents() on the parent directory shows a
> > > > different inode number than for /shared/fp.
> > > > 
> > > > When this happens, I am unable to umount -f or umount -l /usr/local/fp
> > > > (ESTALE), but I can actually umount /shared; umount /usr/local/fp; and
> > > > mount -a, which seems to "fix" it.
> > > > 
> > > > is this acting similar to a bind mount internally now and revalidation or
> > > > something is breaking in this case? This is happening fairly often, so I
> > > > will try to collect more info again next time.
> > > 
> > > ESTALE is a server side error, not a client side error. What server are
> > > you using here, and what do the export options look like?
> > 
> > An older 2.6.33 host running DRBD HA knfsd bits. We had problems with the
> > XFS inode reclaim changes causing crashes on newer kernels (actually on
> > 2.6.33, too, but not so much on this node with only locally-attached
> > disks), so these kernels haven't been upgraded for some time. It's likely
> > time to try again. The export is:
> > 
> > /storage/vg1 /10.10.1.0/24(rw,sync,no_root_squash,no_subtree_check,fsid=1)
> > 
> > I just found it weird to see the ESTALE when accessing /usr/local/fp,
> > while /shared/fp works fine at the same time, even though they're the
> > same path on the server.
> 
> Is /storage/vg1/shared/fp on that server something that can ever be
> removed?  (Say to be replaced by something else?)
> 
> For normal directories that's not a problem, the client's used to
> dealing with the fact that directories may come and go.
> 
> For a directory that you've told the client to *mount*, that's dirty
> trick--it's really expecting that directory to be there as long as it's 
> mounted....

Sure, but nope, the directory hasn't moved or been deleted since it was
created. It only grows.

Simon-
