Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:59635 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751675Ab0A0TJm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jan 2010 14:09:42 -0500
Subject: Re: nfs client performance while server is down
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Whoop Whouzer <tiredandnumb@gmail.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "Muntz, Daniel" <Dan.Muntz@netapp.com>,
        Peter Chacko <peterchacko35@gmail.com>, linux-nfs@vger.kernel.org
In-Reply-To: <d7f0b3a81001271047l72adcc14ycf24cceb64a50644@mail.gmail.com>
References: <d7f0b3a81001230745h18dbb14fi42f28adff0c45294@mail.gmail.com>
	 <d7f0b3a81001230827y52727993nf60210ae610643b7@mail.gmail.com>
	 <7A24DF798E223B4C9864E8F92E8C93EC0527810C@SACMVEXC1-PRD.hq.netapp.com>
	 <d7f0b3a81001241609v35e54740yea3fa1a251b4f953@mail.gmail.com>
	 <0BA6F612-CE3A-47E9-B436-57E48506D769@oracle.com>
	 <d7f0b3a81001251102p5e631706jfd9f147a00487061@mail.gmail.com>
	 <641EC97D-2252-41FB-AEE8-0F1B77B5EA65@oracle.com>
	 <20100126232148.GA806@fieldses.org> <4B608492.2020702@oracle.com>
	 <1264617603.3788.77.camel@localhost>
	 <d7f0b3a81001271047l72adcc14ycf24cceb64a50644@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 27 Jan 2010 14:09:32 -0500
Message-ID: <1264619372.3788.96.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

So? I don't see why that would be an NFS problem.

As far as I can see from this thread, you are basically asking us to fix
these broken applications by implementing a "disconnected NFS" mode.
While that may indeed be a cool thing to support, I haven't seen anybody
so far stepping up and saying that they have the time and resources to
work on it. Are you volunteering?

Trond

On Wed, 2010-01-27 at 19:47 +0100, Whoop Whouzer wrote: 
> ok, but it's not just GNOME/nautilus behaviour. For one, I am
> experiencing problems with just about all applications that require
> (local) disk access. Furthermore, problems have also been reported
> with xfce/thunar and also with KDE.
> 
> A bug for this issue has just been created for xfce/thunar:
> http://bugzilla.xfce.org/show_bug.cgi?id=6185
> 
> On Wed, Jan 27, 2010 at 7:40 PM, Trond Myklebust
> <trond.myklebust@fys.uio.no> wrote:
> > On Wed, 2010-01-27 at 13:23 -0500, Chuck Lever wrote:
> >> On 01/26/2010 06:21 PM, J. Bruce Fields wrote:
> >> > I wonder if nautilus (or some library it uses) likes to regularly
> >> > "statfs" all the filesystems it knows about?
> >>
> >> The NFS client seems to like to send these periodically, but I've never
> >> looked into why.  It's probably triggered by some cache timeout, and
> >> gathers recent server file system information.
> >
> > No. It is entirely application driven. Furthermore, most of the statfs
> > data is uncached, since it should not be performance critical in any
> > sane application environment.
> >
> > IOW: I agree with Bruce that this is most likely GNOME or nautilus
> > triggering statfs calls. Indeed, when I do actually open a window on
> > some directory it also appears to display the free space.
> >
> > Trond
> >
> >
> >



