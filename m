Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from esrismtp2.esri.com ([198.102.62.103]:42747 "EHLO esri3.esri.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751202Ab0A0Taa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jan 2010 14:30:30 -0500
Date: Wed, 27 Jan 2010 11:30:08 -0800
From: Ray Van Dolson <rvandolson@esri.com>
To: Whoop Whouzer <tiredandnumb@gmail.com>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "Muntz, Daniel" <Dan.Muntz@netapp.com>,
        Peter Chacko <peterchacko35@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfs client performance while server is down
Message-ID: <20100127193008.GA31295@esri.com>
References: <d7f0b3a81001241609v35e54740yea3fa1a251b4f953@mail.gmail.com> <0BA6F612-CE3A-47E9-B436-57E48506D769@oracle.com> <d7f0b3a81001251102p5e631706jfd9f147a00487061@mail.gmail.com> <641EC97D-2252-41FB-AEE8-0F1B77B5EA65@oracle.com> <20100126232148.GA806@fieldses.org> <4B608492.2020702@oracle.com> <1264617603.3788.77.camel@localhost> <d7f0b3a81001271047l72adcc14ycf24cceb64a50644@mail.gmail.com> <1264619372.3788.96.camel@localhost> <d7f0b3a81001271125t6a4bd395mc77d04ef663094da@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <d7f0b3a81001271125t6a4bd395mc77d04ef663094da@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jan 27, 2010 at 11:25:39AM -0800, Whoop Whouzer wrote:
> I am not stating this is an NFS problem at all. I am not asking
> anybody to fix anything.  I asked if this issue was by design. I was
> told it wasn't (as nfs is stateless).  So, therefore I considered it
> as a bug (which I don't believe to reside in either nfs or nautilus).
> I am just trying to figure out where the problem lies.
> 
> I am not talking about implementing "disconnected NFS" mode,
> synchronisation or anything like that. There is not something
> missing, there is something not working properly, somewhere, and I'm
> trying to find out where..

My impression is that this is "by design" in that NFS mounts, when
mounted in "hard" mode (which is the case by default) will "block"
until the remote server responds.

For the most part this is a good thing.  Applications expect their
filesystem calls to behave a certain way regardless of what type of
filesystem is underneath.

In this case, it seems like Nautilus tries to open the mount point and
it just hangs... forever.  This would be expected with an NFS mount in
my view.

One way I could think of getting around it would be to ensure that the
NFS mount is mounted with "intr", and then get Nautilus to monitor how
long it takes to read a mount point and "terminate" after a timeout is
reached, perhaps flagging that mount so future accesses are quicker.

Anyways, that goes beyond the scope of NFS... and good luck convincing
the GNOME developers to make a change like that. :)

Also, even if you mount an NFS share with "intr", you can't always
guarantee that you'll be able to kill a process trying to access said
mount..... at least in my experience.

Ray
