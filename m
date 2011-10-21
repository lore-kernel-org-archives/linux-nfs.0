Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:5122 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753736Ab1JURKZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Oct 2011 13:10:25 -0400
Subject: Re: Does NFS4 need st_gen?
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Nikolaus Rath <Nikolaus@rath.org>
Cc: linux-nfs@vger.kernel.org
Date: Fri, 21 Oct 2011 13:10:23 -0400
In-Reply-To: <4EA1994D.6060700@rath.org>
References: <87ipnlcbg8.fsf@inspiron.ap.columbia.edu>
		 <20111019171551.GA32028@fieldses.org>
		 <87d3dsdcf4.fsf@inspiron.ap.columbia.edu>
		 <20111020120207.GL5444@fieldses.org>
		 <877h3za89w.fsf@inspiron.ap.columbia.edu>
		 <20111020195731.GC9987@fieldses.org>
		 <871uu79z7m.fsf@inspiron.ap.columbia.edu>
		 <1319155647.2768.4.camel@lade.trondhjem.org>
		 <87vcrisb5y.fsf@inspiron.ap.columbia.edu>
	 <1319212854.4537.9.camel@lade.trondhjem.org> <4EA1994D.6060700@rath.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1319217023.4537.28.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2011-10-21 at 12:09 -0400, Nikolaus Rath wrote: 
> On 10/21/2011 12:00 PM, Trond Myklebust wrote:
> > On Fri, 2011-10-21 at 09:54 -0400, Nikolaus Rath wrote: 
> >> Trond Myklebust <Trond.Myklebust@netapp.com> writes:
> >>> On Thu, 2011-10-20 at 16:37 -0400, Nikolaus Rath wrote: 
> >>>> "J. Bruce Fields" <bfields@fieldses.org> writes:
> >>>>> On Thu, Oct 20, 2011 at 01:21:31PM -0400, Nikolaus Rath wrote:
> >>>>>> I'm working on a FUSE file system that stores file system metadata in an
> >>>>>> SQL database (http://code.google.com/p/s3ql/). Not having to keep track
> >>>>>> of inode generation numbers would keep the code much simpler, because I
> >>>>>> want to delete inode-rows from the SQL table when the last reference to
> >>>>>> the inode is deleted (so I can't keep track of the generation no).
> >>>>>
> >>>>> You can use current time, or a counter, or something, as the generation
> >>>>> number.
> >>>>
> >>>> With current time I'm screwed if the system clock doesn't have
> >>>> sufficiently fine granularity. With a counter, I either have to remember
> >>>> counter values per-inode even after the inode is deleted, or the global
> >>>> counter will overflow at some point (in which case I may just as well
> >>>> require unique inodes in the first place).
> >>>
> >>> The filehandle is between 32 (NFSv2) and 128(NFSv4) bytes long. How long
> >>> do you expect it to take you to create+destroy between 2^256 and 2^1024
> >>> inodes? I'm guessing that we'll all be long dead and the universe will
> >>> have undergone heat death before that happens...
> >>
> >> Please stop assuming that I'm stupid or haven't thought about the
> >> problem at all. The bottleneck is not the length of the NFS file handle,
> >> but the length of the inode and generation number (both of which are
> >> restricted to 32bit by FUSE) together with the requirement that not only
> >> both of them together need to be unique forever, but the inode also
> >> needs to be unique at any given instant (so they cannot be trivially
> >> combined to form a 64bit value).
> > 
> > No. The point is you don't need a generation number if you don't want to
> > implement one...
> > 
> > You can use any unique identifier + the inode number, and the unique
> > identifier is only limited by the size of the filehandle.
> 
> So how do you choose the unique identifier? It's limited by FUSE to
> 32bit and therefore can't be a global counter, it can't be a timestamp

AFAICS fuse gives you a 64-bit inode number and a 32-bit generation
counter. That is still 96 bits == 79 228 162 514 264 337 593 543 950 336
(or roughly 8*10^28) unique values if you use it as a single counter.

IOW: start allocating inode numbers incrementally from 0 - 2^64, then
each time you overflow the 64-bit inode number counter, bump the
generation number. You'll have to skip those inode numbers that are
already allocated in the subsequent generations, but the total number of
unique combinations is still likely to be more than large enough not to
be a worry.

> because the system clock may not have enough resolution, and it can't be
> a per-inode counter because then I can't discard the counter after the
> inode has been deleted.

If you need more unique values, then modify fuse to allow your
filesystem to manage the exportfs interface. The fuse ABI is versioned,
and can be extended to support new features.

Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

