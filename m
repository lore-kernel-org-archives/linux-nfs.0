Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:42966 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752248Ab0AURFI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jan 2010 12:05:08 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Message-Id: <B02A2206-CFEB-4FF4-8825-E953CFD7637C@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Quentin Barnes <qbarnes+nfs@yahoo-inc.com>
In-Reply-To: <20100121011238.GA30642@yahoo-inc.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: Random I/O over NFS has horrible performance due to small I/O transfers
Date: Thu, 21 Jan 2010 12:04:40 -0500
References: <20091226204531.GA3356@yahoo-inc.com> <E7A7B701-B471-4D14-8D45-B0FF691D1CCC@oracle.com> <20100121011238.GA30642@yahoo-inc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Jan 20, 2010, at 8:12 PM, Quentin Barnes wrote:
> On Tue, Dec 29, 2009 at 09:10:52AM -0800, Chuck Lever wrote:
>> On Dec 26, 2009, at 3:45 PM, Quentin Barnes wrote:
> [...]
>>> In porting some application code to Linux, its performance over
>>> NFSv3 on Linux is terrible.  I'm posting this note to LKML since
>>> the problem was actually tracked back to the VFS layer.
>>>
>>> The app has a simple database that's accessed over NFS.  It always
>>> does random I/O, so any read-ahead is a waste.  The app uses
>>> O_DIRECT which has the side-effect of disabling read-ahead.
>>>
>>> On Linux accessing an O_DIRECT opened file over NFS is much akin to
>>> disabling its attribute cache causing its attributes to be refetched
>>> from the server before each NFS operation.
>>
>> NFS O_DIRECT is designed so that attribute refetching is avoided.
>> Take a look at nfs_file_read() -- right at the top it skips to the
>> direct read code.  Do you perhaps have the actimeo=0 or noac mount
>> options specified?
>
> Sorry I've been slow in responding.  I had a recent death in my
> family which has been occupying all my time for the last three
> weeks.

My condolences.

> I'm sure I didn't have actimeo=0 or noac.  What I was referring to
> is the code in nfs_revalidate_file_size() which forces revalidation
> with O_DIRECT files.  According to the comments this is done to
> minimize the window (race) with other clients writing to the file.
> I saw this behavior as well in wireshark/tcpdump traces I collected.
> With O_DIRECT, the attributes would often be refetched from the
> server prior to each file operation.  (Might have been just for
> write and lseek file operations.)  I could dig up traces if you
> like.

nfs_revalidate_file_size() is not invoked in the O_DIRECT read path.   
You were complaining about read-ahead.  So I'd say this problem is  
independent of the issues you reported earlier with read-ahead.

> Aside from O_DIRECT not using cached file attributes before file
> I/O, this also has an odd side-effect on closing a file.  After
> a write(2) is done by the app, the following close(2) triggers a
> refetch of the attributes.  I don't care what the file attributes
> are -- just let the file close already!  For example, here in user
> space I'm doing a:
>   fd = open(..., O_RDWR|O_DIRECT);
>   write(fd, ...);
>   sleep(3);
>   close(fd);
>
> Which results in:
>   4.191210 NFS V3 ACCESS Call, FH:0x0308031e
>   4.191391 NFS V3 ACCESS Reply
>   4.191431 NFS V3 LOOKUP Call, DH:0x0308031e/scr2
>   4.191613 NFS V3 LOOKUP Reply, FH:0x29f0b5d0
>   4.191645 NFS V3 ACCESS Call, FH:0x29f0b5d0
>   4.191812 NFS V3 ACCESS Reply
>   4.191852 NFS V3 WRITE Call, FH:0x29f0b5d0 Offset:0 Len:300 FILE_SYNC
>   4.192095 NFS V3 WRITE Reply Len:300 FILE_SYNC
>   7.193535 NFS V3 GETATTR Call, FH:0x29f0b5d0
>   7.193724 NFS V3 GETATTR Reply Regular File mode:0644 uid:28238 gid: 
> 100
>
> As you can see by the first column time index that the GETATTR is done
> after the sleep(3) as the file is being closed.  (This was collected  
> on
> a 2.6.32.2 kernel.)
>
> Is there any actual need for doing that GETATTR on close that I don't
> understand, or is it just a goof?

This GETATTR is required generally for cached I/O and close-to-open  
cache coherency.  The Linux NFS FAQ at nfs.sourceforge.net has more  
information on close-to-open.

For close-to-open to work, a close(2) call must flush any pending  
changes, and the next open(2) call on that file needs to check that  
the file's attributes haven't changed since the file was last accessed  
on this client.  The mtime, ctime, and size are compared between the  
two to determine if the client's copy of the file's data is stale.

The flush done by a close(2) call after a write(2) may cause the  
server to update the mtime, ctime, and size of the file.  So, after  
the flush, the client has to grab the latest copy of the file's  
attributes from the server (the server, not the client, maintains the  
values of mtime, ctime, and size).  Otherwise, the client would have  
cached file attributes that were valid _before_ the flush, but not  
afterwards.  The next open(2) would be spoofed into thinking that the  
file had been changed by some other client, when it was its own  
activity that caused the mtime/ctime/size change.

But again, you would only see this for normal cached accesses, or for  
llseek(SEEK_END).  The O_DIRECT path splits off well before that  
nfs_revalidate_file_size() call in nfs_file_write().

For llseek(SEEK_END), this is the preferred way to get the size of a  
file through an O_DIRECT file descriptor.  This is precisely because  
O_DIRECT does not guarantee that the client's copy of the file's  
attributes are up to date.

I see that the WRITE from your trace is a FILE_SYNC write.  In this  
case, perhaps the GETATTR is really not required for close-to-open.   
Especially if the server has returned post-op attributes in the WRITE  
reply, the client would already have up-to-date file attributes  
available to it.

>>> After some thought,
>>> given the Linux behavior of O_DIRECT on regular hard disk files to
>>> ensure file cache consistency, frustratingly, that's probably the
>>> more correct answer to emulate this file system behavior for NFS.
>>> At this point, rather than expecting Linux to somehow change to
>>> avoid the unnecessary flood of GETATTRs, I thought it best for the
>>> app not to just use the O_DIRECT flag on Linux.  So I changed the
>>> app code and then added a posix_fadvise(2) call to keep read-ahead
>>> disabled.  When I did that, I ran into an unexpected problem.
>>>
>>> Adding the posix_fadvise(..., POSIX_FADV_RANDOM) call sets
>>> ra_pages=0.  This has a very odd side-effect in the kernel.  Once
>>> read-ahead is disabled, subsequent calls to read(2) are now done in
>>> the kernel via ->readpage() callback doing I/O one page at a time!
>>
>> Your application could always use posix_fadvise(...,
>> POSIX_FADV_WILLNEED).  POSIX_FADV_RANDOM here means the application
>> will perform I/O requests in random offset order, and requests will  
>> be
>> smaller than a page.
>
> I agree with your first assertion, but I disagree with your second.
> There's nothing to imply about the size of a POSIX_FADV_RANDOM
> transaction being a page size or smaller.

My second assertion is true on Linux.  Certainly POSIX does not  
require the request size limitation.

> Anyways, this whole problem was corrected by Wu Fengguang in his
> fix to the readahead code that my patch prompted over in LKML.

I was pleased to see that fix.

>>> Pouring through the code in mm/filemap.c I see that the kernel has
>>> commingled read-ahead and plain read implementations.  The  
>>> algorithms
>>> have much in common, so I can see why it was done, but it left this
>>> anomaly of severely pimping read(2) calls on file descriptors with
>>> read-ahead disabled.
>>
>> The problem is that do_generic_file_read() conflates read-ahead and
>> read coalescing, which are really two different things (and this use
>> case highlights that difference).
>>
>> Above you said that "any readahead is a waste."  That's only true if
>> your database is significantly larger than available physical memory.
>
> It is.  It's waaaay larger than all available physical memory on
> a given client machine.  (Think of tens of millions of users' email
> accounts.)

If the accesses on any given client are localized in the file (eg.  
there are only a few e-mail users on that client) this should be  
handily dealt with by normal O/S caching behavior, even with an  
enormous database file.  It really depends on the file's resident set  
on each client.

>> Otherwise, you are simply populating the local page cache faster than
>> if your app read exactly what was needed each time.
>
> It's a multithreaded app running across many clients accessing many
> servers.  Any excess network traffic at all to the database is a
> very bad idea being detrimental to both to the particular client's
> throughput but all other clients wanting to access files on the
> burdened NFS servers.

Which is why you might be better off relying on client-side caches in  
this case.  Efficient client caching is absolutely required for good  
network and server scalability with such workloads.

If all of this data is contained in a single large file, your  
application is relying on a single set of file attributes to determine  
whether the client's cache for all the file data is stale.  So  
basically, read ahead is pulling a bunch of data into the client's  
page cache, then someone changes one byte in the file, and all that  
data is invalidated in one swell foop.  In this case, it's not  
necessarily read-ahead that's killing your performance, it's excessive  
client data cache invalidations.

>> On fast modern
>> networks there is little latency difference between reading a single
>> page and reading 16 pages in a single NFS read request.  The cost  
>> is a
>> larger page cache footprint.
>
> Believe me, the extra file accesses do make a huge difference.

If your rsize is big enough, the read-ahead traffic usually won't  
increase the number of NFS READs on the wire; it increases the size of  
each request.  Client read coalescing will attempt to bundle the  
additional requested data into a minimal number of wire READs.  A  
closer examination of the on-the-wire READ count vs. the amount of  
data read might be interesting.  It might also be useful to see how  
often the same client reads the same page in the file repeatedly.

>> If you leave read ahead enabled, theoretically, the read-ahead  
>> context
>> should adjust itself over time to read the average number of pages in
>> each application read request.  Have you seen any real performance
>> problems when using normal cached I/O with read-ahead enabled?
>
> Yes, HUGE problems.  As measured under load, we're talking on an
> order of magnitude slower throughput and then some.
>
> The kernel can't adjust its strategy over time.  There is no history
> maintained because the app opens a given file, updates it, closes
> it, then moves on to the next file.  The file descriptor is not kept
> open beyond just one or two read or write operations.  Also, the
> chance of the same file needing to be updated by the same client
> within any reasonable time frame is very small.

Yes, read-ahead context is abandoned when a file descriptor is  
closed.  That immediately suggests that file descriptors should be  
left open, but that's only as practical as your application allows.

> Hope all this helps understand the problems I'm dealing with.

Yes, this is more clear, thanks.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



