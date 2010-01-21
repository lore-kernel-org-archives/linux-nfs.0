Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mrout1-b.corp.re1.yahoo.com ([69.147.107.20]:39152 "EHLO
	mrout1-b.corp.re1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750807Ab0AUBOy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Jan 2010 20:14:54 -0500
Date: Wed, 20 Jan 2010 19:12:38 -0600
From: Quentin Barnes <qbarnes+nfs@yahoo-inc.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: Random I/O over NFS has horrible performance due to small I/O transfers
Message-ID: <20100121011238.GA30642@yahoo-inc.com>
References: <20091226204531.GA3356@yahoo-inc.com> <E7A7B701-B471-4D14-8D45-B0FF691D1CCC@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E7A7B701-B471-4D14-8D45-B0FF691D1CCC@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Dec 29, 2009 at 09:10:52AM -0800, Chuck Lever wrote:
> On Dec 26, 2009, at 3:45 PM, Quentin Barnes wrote:
[...]
> > In porting some application code to Linux, its performance over
> > NFSv3 on Linux is terrible.  I'm posting this note to LKML since
> > the problem was actually tracked back to the VFS layer.
> >
> > The app has a simple database that's accessed over NFS.  It always
> > does random I/O, so any read-ahead is a waste.  The app uses
> > O_DIRECT which has the side-effect of disabling read-ahead.
> >
> > On Linux accessing an O_DIRECT opened file over NFS is much akin to
> > disabling its attribute cache causing its attributes to be refetched
> > from the server before each NFS operation.
> 
> NFS O_DIRECT is designed so that attribute refetching is avoided.   
> Take a look at nfs_file_read() -- right at the top it skips to the  
> direct read code.  Do you perhaps have the actimeo=0 or noac mount  
> options specified?

Sorry I've been slow in responding.  I had a recent death in my
family which has been occupying all my time for the last three
weeks.

I'm sure I didn't have actimeo=0 or noac.  What I was referring to
is the code in nfs_revalidate_file_size() which forces revalidation
with O_DIRECT files.  According to the comments this is done to
minimize the window (race) with other clients writing to the file.
I saw this behavior as well in wireshark/tcpdump traces I collected.
With O_DIRECT, the attributes would often be refetched from the
server prior to each file operation.  (Might have been just for
write and lseek file operations.)  I could dig up traces if you
like.

Aside from O_DIRECT not using cached file attributes before file
I/O, this also has an odd side-effect on closing a file.  After
a write(2) is done by the app, the following close(2) triggers a
refetch of the attributes.  I don't care what the file attributes
are -- just let the file close already!  For example, here in user
space I'm doing a:
   fd = open(..., O_RDWR|O_DIRECT);
   write(fd, ...);
   sleep(3);
   close(fd);

Which results in:
   4.191210 NFS V3 ACCESS Call, FH:0x0308031e
   4.191391 NFS V3 ACCESS Reply
   4.191431 NFS V3 LOOKUP Call, DH:0x0308031e/scr2
   4.191613 NFS V3 LOOKUP Reply, FH:0x29f0b5d0
   4.191645 NFS V3 ACCESS Call, FH:0x29f0b5d0
   4.191812 NFS V3 ACCESS Reply
   4.191852 NFS V3 WRITE Call, FH:0x29f0b5d0 Offset:0 Len:300 FILE_SYNC
   4.192095 NFS V3 WRITE Reply Len:300 FILE_SYNC
   7.193535 NFS V3 GETATTR Call, FH:0x29f0b5d0
   7.193724 NFS V3 GETATTR Reply Regular File mode:0644 uid:28238 gid:100

As you can see by the first column time index that the GETATTR is done
after the sleep(3) as the file is being closed.  (This was collected on
a 2.6.32.2 kernel.)

Is there any actual need for doing that GETATTR on close that I don't
understand, or is it just a goof?

> > After some thought,
> > given the Linux behavior of O_DIRECT on regular hard disk files to
> > ensure file cache consistency, frustratingly, that's probably the
> > more correct answer to emulate this file system behavior for NFS.
> > At this point, rather than expecting Linux to somehow change to
> > avoid the unnecessary flood of GETATTRs, I thought it best for the
> > app not to just use the O_DIRECT flag on Linux.  So I changed the
> > app code and then added a posix_fadvise(2) call to keep read-ahead
> > disabled.  When I did that, I ran into an unexpected problem.
> >
> > Adding the posix_fadvise(..., POSIX_FADV_RANDOM) call sets
> > ra_pages=0.  This has a very odd side-effect in the kernel.  Once
> > read-ahead is disabled, subsequent calls to read(2) are now done in
> > the kernel via ->readpage() callback doing I/O one page at a time!
> 
> Your application could always use posix_fadvise(...,  
> POSIX_FADV_WILLNEED).  POSIX_FADV_RANDOM here means the application  
> will perform I/O requests in random offset order, and requests will be  
> smaller than a page.

I agree with your first assertion, but I disagree with your second.
There's nothing to imply about the size of a POSIX_FADV_RANDOM
transaction being a page size or smaller.

Anyways, this whole problem was corrected by Wu Fengguang in his
fix to the readahead code that my patch prompted over in LKML.

> > Pouring through the code in mm/filemap.c I see that the kernel has
> > commingled read-ahead and plain read implementations.  The algorithms
> > have much in common, so I can see why it was done, but it left this
> > anomaly of severely pimping read(2) calls on file descriptors with
> > read-ahead disabled.
> 
> The problem is that do_generic_file_read() conflates read-ahead and  
> read coalescing, which are really two different things (and this use  
> case highlights that difference).
> 
> Above you said that "any readahead is a waste."  That's only true if  
> your database is significantly larger than available physical memory.   

It is.  It's waaaay larger than all available physical memory on
a given client machine.  (Think of tens of millions of users' email
accounts.)

> Otherwise, you are simply populating the local page cache faster than  
> if your app read exactly what was needed each time.

It's a multithreaded app running across many clients accessing many
servers.  Any excess network traffic at all to the database is a
very bad idea being detrimental to both to the particular client's
throughput but all other clients wanting to access files on the
burdened NFS servers.

> On fast modern  
> networks there is little latency difference between reading a single  
> page and reading 16 pages in a single NFS read request.  The cost is a  
> larger page cache footprint.

Believe me, the extra file accesses do make a huge difference.

> Caching is only really harmful if your database file is shared between  
> more than one NFS client.

It is.  Many clients.  But as far as the usual caching problems, I
don't think those exist.  I think there are high level protocols
in place to prevent multiple clients from stepping on each other's
work, but not positive.  It's something I need to verify.

> In fact, I think O_DIRECT will be more of a  
> hindrance if your simple database doesn't do its own caching, since  
> your app will generate more NFS reads in the O_DIRECT case, meaning it  
> will wait more often.  You're almost always better off letting the O/S  
> handle data caching.

Maybe.  That's what I'm trying to determine.  I think O_DIRECT was
more or less used simply to keep the apps from doing any readahead
rather than truly wanting to disable file data caching.  It's a
tradeoff I'm currently analyzing.

> If you leave read ahead enabled, theoretically, the read-ahead context  
> should adjust itself over time to read the average number of pages in  
> each application read request.  Have you seen any real performance  
> problems when using normal cached I/O with read-ahead enabled?

Yes, HUGE problems.  As measured under load, we're talking on an
order of magnitude slower throughput and then some.

The kernel can't adjust its strategy over time.  There is no history
maintained because the app opens a given file, updates it, closes
it, then moves on to the next file.  The file descriptor is not kept
open beyond just one or two read or write operations.  Also, the
chance of the same file needing to be updated by the same client
within any reasonable time frame is very small.

Hope all this helps understand the problems I'm dealing with.

[...]
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Quentin
