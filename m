Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mrout2-b.corp.re1.yahoo.com ([69.147.107.21]:25333 "EHLO
	mrout2-b.corp.re1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751079Ab0AXSs4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2010 13:48:56 -0500
Date: Sun, 24 Jan 2010 12:46:34 -0600
From: Quentin Barnes <qbarnes+nfs@yahoo-inc.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: Random I/O over NFS has horrible performance due to small I/O transfers
Message-ID: <20100124184634.GA19426@yahoo-inc.com>
References: <20091226204531.GA3356@yahoo-inc.com> <E7A7B701-B471-4D14-8D45-B0FF691D1CCC@oracle.com> <20100121011238.GA30642@yahoo-inc.com> <B02A2206-CFEB-4FF4-8825-E953CFD7637C@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <B02A2206-CFEB-4FF4-8825-E953CFD7637C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> > Sorry I've been slow in responding.  I had a recent death in my
> > family which has been occupying all my time for the last three
> > weeks.
> 
> My condolences.

Thank you.

> > I'm sure I didn't have actimeo=0 or noac.  What I was referring to
> > is the code in nfs_revalidate_file_size() which forces revalidation
> > with O_DIRECT files.  According to the comments this is done to
> > minimize the window (race) with other clients writing to the file.
> > I saw this behavior as well in wireshark/tcpdump traces I collected.
> > With O_DIRECT, the attributes would often be refetched from the
> > server prior to each file operation.  (Might have been just for
> > write and lseek file operations.)  I could dig up traces if you
> > like.
> 
> nfs_revalidate_file_size() is not invoked in the O_DIRECT read path.   
> You were complaining about read-ahead.  So I'd say this problem is  
> independent of the issues you reported earlier with read-ahead.

Sorry for the confusion in the segue.  To summarize, the app
on another OS was originally was designed to use O_DIRECT as a
side-effect to disable read-ahead.  However, when ported to Linux,
the O_DIRECT flag with NFS files triggers a new GETATTR every time
the app did an lseek(2), write(2), or close(2).  As an alternative,
I experimented with having the app on Linux not use O_DIRECT but
call posix_fadvise(...,POSIX_FADV_RANDOM).  That got rid of the
extra GETATTRs and the read-aheads, but then that caused the larger
read(2)s to run very inefficiently with the dozens of 4K page-sized
NFS READs.

> > Aside from O_DIRECT not using cached file attributes before file
> > I/O, this also has an odd side-effect on closing a file.  After
> > a write(2) is done by the app, the following close(2) triggers a
> > refetch of the attributes.  I don't care what the file attributes
> > are -- just let the file close already!  For example, here in user
> > space I'm doing a:
> >   fd = open(..., O_RDWR|O_DIRECT);
> >   write(fd, ...);
> >   sleep(3);
> >   close(fd);
> >
> > Which results in:
> >   4.191210 NFS V3 ACCESS Call, FH:0x0308031e
> >   4.191391 NFS V3 ACCESS Reply
> >   4.191431 NFS V3 LOOKUP Call, DH:0x0308031e/scr2
> >   4.191613 NFS V3 LOOKUP Reply, FH:0x29f0b5d0
> >   4.191645 NFS V3 ACCESS Call, FH:0x29f0b5d0
> >   4.191812 NFS V3 ACCESS Reply
> >   4.191852 NFS V3 WRITE Call, FH:0x29f0b5d0 Offset:0 Len:300 FILE_SYNC
> >   4.192095 NFS V3 WRITE Reply Len:300 FILE_SYNC
> >   7.193535 NFS V3 GETATTR Call, FH:0x29f0b5d0
> >   7.193724 NFS V3 GETATTR Reply Regular File mode:0644 uid:28238 gid: 
> > 100
> >
> > As you can see by the first column time index that the GETATTR is done
> > after the sleep(3) as the file is being closed.  (This was collected  
> > on a 2.6.32.2 kernel.)
> >
> > Is there any actual need for doing that GETATTR on close that I don't
> > understand, or is it just a goof?
> 
> This GETATTR is required generally for cached I/O and close-to-open  
> cache coherency.  The Linux NFS FAQ at nfs.sourceforge.net has more  
> information on close-to-open.

I know CTO well.  In my version of nfs.ko, I've added a O_NFS_NOCTO
flag to the open(2) syscall.  We need the ability to fine tune
specifically which files have "no CTO" feature active.  The "nocto"
mount flag is too sweeping.  Has a per-file "nocto" feature been
discussed before?

> For close-to-open to work, a close(2) call must flush any pending  
> changes, and the next open(2) call on that file needs to check that  
> the file's attributes haven't changed since the file was last accessed  
> on this client.  The mtime, ctime, and size are compared between the  
> two to determine if the client's copy of the file's data is stale.

Yes, that's the client's way to validate its cached CTO data.

> The flush done by a close(2) call after a write(2) may cause the  
> server to update the mtime, ctime, and size of the file.  So, after  
> the flush, the client has to grab the latest copy of the file's  
> attributes from the server (the server, not the client, maintains the  
> values of mtime, ctime, and size).

When referring to "flush" above, are you refering to the NFS flush
call (nfs_file_flush) or the action of flushing cached data from
client to server?

If the flush call has no data to flush, the GETATTR is pointless.
The file's cached attribute information is already as valid as can
ever be hoped for with NFS and its life is limited by the normal
attribute timeout.  On the other hand, if the flush has cached data
to write out, I would expect the WRITE will return the updated
attributes with the post-op attribute status, again making the
GETATTR on close pointless.  Can you explain what I'm not following?

However, I tore into the code to better understand what was triggering
the GETATTR on close.  A close(2) does two things, a flush
(nfs_file_flush) and a release (nfs_file_release).  I had thought the
GETATTR was happening as part of the nfs_file_flush().  It's not.  The
GETATTR is triggered by the nfs_file_release().  As part of it doing a
put_nfs_open_context() -> nfs_close_context() -> nfs_revalidate_inode(),
that triggers the NFS_PROTO(inode)->getattr()!

I'm not sure, but I suspect that O_DIRECT files take the
put_nfs_open_context() path that results in the extraneous GETATTR
on close(2) because filp->private_data is non-NULL where for regular
files it's NULL.  Is that right?  If so, can this problem be easily
fixed?

> Otherwise, the client would have  
> cached file attributes that were valid _before_ the flush, but not  
> afterwards.  The next open(2) would be spoofed into thinking that the  
> file had been changed by some other client, when it was its own  
> activity that caused the mtime/ctime/size change.

I just don't see how that can happen.  The attributes should be
automatically updated by the post-op reply, right?

> But again, you would only see this for normal cached accesses, or for  
> llseek(SEEK_END).  The O_DIRECT path splits off well before that  
> nfs_revalidate_file_size() call in nfs_file_write().
> 
> For llseek(SEEK_END), this is the preferred way to get the size of a  
> file through an O_DIRECT file descriptor.  This is precisely because  
> O_DIRECT does not guarantee that the client's copy of the file's  
> attributes are up to date.

Yes, that makes sense and is what the code comments help with
understanding.

> I see that the WRITE from your trace is a FILE_SYNC write.  In this  
> case, perhaps the GETATTR is really not required for close-to-open.   
> Especially if the server has returned post-op attributes in the WRITE  
> reply, the client would already have up-to-date file attributes  
> available to it.

Yes, FILE_SYNC is normal for O_DIRECT WRITEs on NFSv3 and v4.

> >> Above you said that "any readahead is a waste."  That's only true if
> >> your database is significantly larger than available physical memory.
> >
> > It is.  It's waaaay larger than all available physical memory on
> > a given client machine.  (Think of tens of millions of users' email
> > accounts.)
> 
> If the accesses on any given client are localized in the file (eg.  
> there are only a few e-mail users on that client) this should be  
> handily dealt with by normal O/S caching behavior, even with an  
> enormous database file.  It really depends on the file's resident set  
> on each client.

As to how the incoming requests are assigned to specific or random
clients, I am unsure.  I'm not on their team.  I've just been assisting
with the backend issues (NFS client performance).

In this particular use case, there isn't a single enormous database.
Each user has their own file which itself is their private database.
(Better for privacy and security.)

> >> Otherwise, you are simply populating the local page cache faster than
> >> if your app read exactly what was needed each time.
> >
> > It's a multithreaded app running across many clients accessing many
> > servers.  Any excess network traffic at all to the database is a
> > very bad idea being detrimental to both to the particular client's
> > throughput but all other clients wanting to access files on the
> > burdened NFS servers.
> 
> Which is why you might be better off relying on client-side caches in  
> this case.  Efficient client caching is absolutely required for good  
> network and server scalability with such workloads.

It is a very unusual workload due to the sheer number of files
and their access patterns.  Data cache hits are typically very
low because of the large amount of data and the bimodal access
patterns between MTAs and users, and users are pretty arbitrary too.
Attribute cache hits are typically low too, but due to their small
size, the attributes are more likely to stay in their cache.

> If all of this data is contained in a single large file, your  
> application is relying on a single set of file attributes to determine  
> whether the client's cache for all the file data is stale.  So  
> basically, read ahead is pulling a bunch of data into the client's  
> page cache, then someone changes one byte in the file, and all that  
> data is invalidated in one swell foop.  In this case, it's not  
> necessarily read-ahead that's killing your performance, it's excessive  
> client data cache invalidations.

That's not the general case here since we're dealing with tens of
millions of files on one server, but I didn't know that all the data
of a file pulled gets invalidated like that.  I would expect only
the page (4K) to be marked, not the whole set.

> >> On fast modern
> >> networks there is little latency difference between reading a single
> >> page and reading 16 pages in a single NFS read request.  The cost  
> >> is a
> >> larger page cache footprint.
> >
> > Believe me, the extra file accesses do make a huge difference.
> 
> If your rsize is big enough, the read-ahead traffic usually won't  
> increase the number of NFS READs on the wire; it increases the size of  
> each request.

rsize is 32K.  That's generally true (especially after Wu's fix),
but that extra network traffic is overburdening the NFS servers.

> Client read coalescing will attempt to bundle the  
> additional requested data into a minimal number of wire READs.  A  
> closer examination of the on-the-wire READ count vs. the amount of  
> data read might be interesting.  It might also be useful to see how  
> often the same client reads the same page in the file repeatedly.

Because the app was designed with O_DIRECT in mind, the app does its
own file buffering in user space.

If for the Linux port we can move away from O_DIRECT, it would be
interesting to see if that extra user space buffering could be
disabled and let the kernel do its job.

> > The kernel can't adjust its strategy over time.  There is no history
> > maintained because the app opens a given file, updates it, closes
> > it, then moves on to the next file.  The file descriptor is not kept
> > open beyond just one or two read or write operations.  Also, the
> > chance of the same file needing to be updated by the same client
> > within any reasonable time frame is very small.
> 
> Yes, read-ahead context is abandoned when a file descriptor is  
> closed.  That immediately suggests that file descriptors should be  
> left open, but that's only as practical as your application allows.

Not in this case with tens of millions of files.

> > Hope all this helps understand the problems I'm dealing with.
> 
> Yes, this is more clear, thanks.

Glad it helped!

> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Quentin
