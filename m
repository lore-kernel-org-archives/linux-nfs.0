Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:46981 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760786Ab0HFTjc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Aug 2010 15:39:32 -0400
Subject: Re: Tuning NFS client write pagecache
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Peter Chacko <peterchacko35@gmail.com>
Cc: Jim Rees <rees@umich.edu>, Matthew Hodgson <matthew@mxtelecom.com>,
        linux-nfs@vger.kernel.org
In-Reply-To: <AANLkTimArNXgDSJeHrqsdAhCQo_O0=bhRuqsQEp0ofN7@mail.gmail.com>
References: <4C5BFE47.8020905@mxtelecom.com>
	 <20100806132620.GA2921@merit.edu>
	 <AANLkTin_pg7GCw9jcB2JK+0TbGu+MrQEcv4H_qAg_A3H@mail.gmail.com>
	 <1281116260.2900.6.camel@heimdal.trondhjem.org>
	 <AANLkTimArNXgDSJeHrqsdAhCQo_O0=bhRuqsQEp0ofN7@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 06 Aug 2010 15:39:25 -0400
Message-ID: <1281123565.2900.17.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 2010-08-07 at 00:59 +0530, Peter Chacko wrote:
> Imagine a third party backup app for which a customer has no source
> code. (that doesn't use open system call O_DIRECT mode) backing up
> millions of files through NFS....How can we do a non-cached IO to the
> target server ?  we cannot use O_DIRECT option here as we don't have
> the source code....If we have mount option, its works just right
> ....if we can have read-only mounts, why not have a dio-only mount ?
> 
> A true application-aware storage systems(in this case NFS client) ,
> which is the next generation storage systems should do, should absorb
> the application needs that may apply to the whole FS....
> 
> i don't say O_DIRECT flag is a bad idea, but it will only work with a
> regular application that do IO to some files.....this is not the best
> solution when NFS server is used as the storage for secondary data,
> where NFS client runs third party applications thats otherwise run
> best in a local storage as there is no caching issues....
> 
> What do you think ?

I think that we've had O_DIRECT support in the kernel for more than six
years now. If there are backup vendors out there that haven't been
paying attention, then I'd suggest looking at other vendors.

Trond

> On Fri, Aug 6, 2010 at 11:07 PM, Trond Myklebust
> <trond.myklebust@fys.uio.no> wrote:
> > On Fri, 2010-08-06 at 15:05 +0100, Peter Chacko wrote:
> >> Some distributed file systems such as IBM's SANFS, support direct IO
> >> to the target storage....without going through a cache... ( This
> >> feature is useful, for write only work load....say, we are backing up
> >> huge data to an NFS share....).
> >>
> >> I think if not available, we should add a DIO mount option, that tell
> >> the VFS not to cache any data, so that close operation will not stall.
> >
> > Ugh no! Applications that need direct IO should be using open(O_DIRECT),
> > not relying on hacks like mount options.
> >
> >> With the open-to-close , cache coherence protocol of NFS, an
> >> aggressive caching client, is a performance downer for many work-loads
> >> that is write-mostly.
> >
> > We already have full support for vectored aio/dio in the NFS for those
> > applications that want to use it.
> >
> > Trond
> >
> >>
> >>
> >>
> >> On Fri, Aug 6, 2010 at 2:26 PM, Jim Rees <rees@umich.edu> wrote:
> >> > Matthew Hodgson wrote:
> >> >
> >> >  Is there any way to tune the linux NFSv3 client to prefer to write
> >> >  data straight to an async-mounted server, rather than having large
> >> >  writes to a file stack up in the local pagecache before being synced
> >> >  on close()?
> >> >
> >> > It's been a while since I've done this, but I think you can tune this with
> >> > vm.dirty_writeback_centisecs and vm.dirty_background_ratio sysctls.  The
> >> > data will still go through the page cache but you can reduce the amount that
> >> > stacks up.
> >> >
> >> > There are other places where the data can get buffered, like the rpc layer,
> >> > but it won't sit there any longer than it takes for it to go out the wire.
> >> > --
> >> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> > the body of a message to majordomo@vger.kernel.org
> >> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >> >
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> >
> >
> >



