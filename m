Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:26142 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230Ab0AYQoL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jan 2010 11:44:11 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Message-Id: <A9262578-3560-4EEE-87BC-8AA339F77B10@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Quentin Barnes <qbarnes+nfs@yahoo-inc.com>
In-Reply-To: <20100124184634.GA19426@yahoo-inc.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: Random I/O over NFS has horrible performance due to small I/O transfers
Date: Mon, 25 Jan 2010 11:43:28 -0500
References: <20091226204531.GA3356@yahoo-inc.com> <E7A7B701-B471-4D14-8D45-B0FF691D1CCC@oracle.com> <20100121011238.GA30642@yahoo-inc.com> <B02A2206-CFEB-4FF4-8825-E953CFD7637C@oracle.com> <20100124184634.GA19426@yahoo-inc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Jan 24, 2010, at 1:46 PM, Quentin Barnes wrote:
>>> I'm sure I didn't have actimeo=0 or noac.  What I was referring to
>>> is the code in nfs_revalidate_file_size() which forces revalidation
>>> with O_DIRECT files.  According to the comments this is done to
>>> minimize the window (race) with other clients writing to the file.
>>> I saw this behavior as well in wireshark/tcpdump traces I collected.
>>> With O_DIRECT, the attributes would often be refetched from the
>>> server prior to each file operation.  (Might have been just for
>>> write and lseek file operations.)  I could dig up traces if you
>>> like.
>>
>> nfs_revalidate_file_size() is not invoked in the O_DIRECT read path.
>> You were complaining about read-ahead.  So I'd say this problem is
>> independent of the issues you reported earlier with read-ahead.
>
> Sorry for the confusion in the segue.  To summarize, the app
> on another OS was originally was designed to use O_DIRECT as a
> side-effect to disable read-ahead.  However, when ported to Linux,
> the O_DIRECT flag with NFS files triggers a new GETATTR every time
> the app did an lseek(2), write(2), or close(2).  As an alternative,
> I experimented with having the app on Linux not use O_DIRECT but
> call posix_fadvise(...,POSIX_FADV_RANDOM).  That got rid of the
> extra GETATTRs and the read-aheads, but then that caused the larger
> read(2)s to run very inefficiently with the dozens of 4K page-sized
> NFS READs.
>
>>> Aside from O_DIRECT not using cached file attributes before file
>>> I/O, this also has an odd side-effect on closing a file.  After
>>> a write(2) is done by the app, the following close(2) triggers a
>>> refetch of the attributes.  I don't care what the file attributes
>>> are -- just let the file close already!  For example, here in user
>>> space I'm doing a:
>>>  fd = open(..., O_RDWR|O_DIRECT);
>>>  write(fd, ...);
>>>  sleep(3);
>>>  close(fd);
>>>
>>> Which results in:
>>>  4.191210 NFS V3 ACCESS Call, FH:0x0308031e
>>>  4.191391 NFS V3 ACCESS Reply
>>>  4.191431 NFS V3 LOOKUP Call, DH:0x0308031e/scr2
>>>  4.191613 NFS V3 LOOKUP Reply, FH:0x29f0b5d0
>>>  4.191645 NFS V3 ACCESS Call, FH:0x29f0b5d0
>>>  4.191812 NFS V3 ACCESS Reply
>>>  4.191852 NFS V3 WRITE Call, FH:0x29f0b5d0 Offset:0 Len:300  
>>> FILE_SYNC
>>>  4.192095 NFS V3 WRITE Reply Len:300 FILE_SYNC
>>>  7.193535 NFS V3 GETATTR Call, FH:0x29f0b5d0
>>>  7.193724 NFS V3 GETATTR Reply Regular File mode:0644 uid:28238 gid:
>>> 100
>>>
>>> As you can see by the first column time index that the GETATTR is  
>>> done
>>> after the sleep(3) as the file is being closed.  (This was collected
>>> on a 2.6.32.2 kernel.)
>>>
>>> Is there any actual need for doing that GETATTR on close that I  
>>> don't
>>> understand, or is it just a goof?
>>
>> This GETATTR is required generally for cached I/O and close-to-open
>> cache coherency.  The Linux NFS FAQ at nfs.sourceforge.net has more
>> information on close-to-open.
>
> I know CTO well.  In my version of nfs.ko, I've added a O_NFS_NOCTO
> flag to the open(2) syscall.  We need the ability to fine tune
> specifically which files have "no CTO" feature active.  The "nocto"
> mount flag is too sweeping.  Has a per-file "nocto" feature been
> discussed before?

Probably, but that's for another thread (preferably on linux-nfs@vger.kernel.org 
  only).

>> For close-to-open to work, a close(2) call must flush any pending
>> changes, and the next open(2) call on that file needs to check that
>> the file's attributes haven't changed since the file was last  
>> accessed
>> on this client.  The mtime, ctime, and size are compared between the
>> two to determine if the client's copy of the file's data is stale.
>
> Yes, that's the client's way to validate its cached CTO data.
>
>> The flush done by a close(2) call after a write(2) may cause the
>> server to update the mtime, ctime, and size of the file.  So, after
>> the flush, the client has to grab the latest copy of the file's
>> attributes from the server (the server, not the client, maintains the
>> values of mtime, ctime, and size).
>
> When referring to "flush" above, are you refering to the NFS flush
> call (nfs_file_flush) or the action of flushing cached data from
> client to server?

close(2) uses nfs_file_flush() to flush dirty data.

> If the flush call has no data to flush, the GETATTR is pointless.
> The file's cached attribute information is already as valid as can
> ever be hoped for with NFS and its life is limited by the normal
> attribute timeout.  On the other hand, if the flush has cached data
> to write out, I would expect the WRITE will return the updated
> attributes with the post-op attribute status, again making the
> GETATTR on close pointless.  Can you explain what I'm not following?

The Linux NFS client does not use the post-op attributes to update the  
cached attributes for the file.  Because there is no guarantee that  
the WRITE replies will return in the same order the WRITEs were sent,  
it's simply not reliable.  If the last reply to be received was for an  
older write, then the mtime and ctime (and possibly the size) would be  
stale, and would trigger a false data cache invalidation the next time  
a full inode validation is done.

So, post-op attributes are used to detect the need for an attribute  
cache update.  At some later point, the client will perform the update  
by sending a GETATTR, and that will update the cached attributes.   
That's what NFS_INO_INVALID_ATTR is for.

The goal is to use a few extra operations on the wire to prevent  
spurious data cache invalidations.  For large files, this could mean  
significantly fewer READs on the wire.

> However, I tore into the code to better understand what was triggering
> the GETATTR on close.  A close(2) does two things, a flush
> (nfs_file_flush) and a release (nfs_file_release).  I had thought the
> GETATTR was happening as part of the nfs_file_flush().  It's not.  The
> GETATTR is triggered by the nfs_file_release().  As part of it doing a
> put_nfs_open_context() -> nfs_close_context() ->  
> nfs_revalidate_inode(),
> that triggers the NFS_PROTO(inode)->getattr()!
>
> I'm not sure, but I suspect that O_DIRECT files take the
> put_nfs_open_context() path that results in the extraneous GETATTR
> on close(2) because filp->private_data is non-NULL where for regular
> files it's NULL.  Is that right?  If so, can this problem be easily
> fixed?

I'm testing a patch to use an asynchronous close for O_DIRECT files.   
This will skip the GETATTR for NFSv2/v3 O_DIRECT files, and avoid  
waiting for the CLOSE for NFSv4 O_DIRECT files.

>> If all of this data is contained in a single large file, your
>> application is relying on a single set of file attributes to  
>> determine
>> whether the client's cache for all the file data is stale.  So
>> basically, read ahead is pulling a bunch of data into the client's
>> page cache, then someone changes one byte in the file, and all that
>> data is invalidated in one swell foop.  In this case, it's not
>> necessarily read-ahead that's killing your performance, it's  
>> excessive
>> client data cache invalidations.
>
> That's not the general case here since we're dealing with tens of
> millions of files on one server, but I didn't know that all the data
> of a file pulled gets invalidated like that.  I would expect only
> the page (4K) to be marked, not the whole set.
>
>>>> On fast modern
>>>> networks there is little latency difference between reading a  
>>>> single
>>>> page and reading 16 pages in a single NFS read request.  The cost
>>>> is a
>>>> larger page cache footprint.
>>>
>>> Believe me, the extra file accesses do make a huge difference.
>>
>> If your rsize is big enough, the read-ahead traffic usually won't
>> increase the number of NFS READs on the wire; it increases the size  
>> of
>> each request.
>
> rsize is 32K.  That's generally true (especially after Wu's fix),
> but that extra network traffic is overburdening the NFS servers.
>
>> Client read coalescing will attempt to bundle the
>> additional requested data into a minimal number of wire READs.  A
>> closer examination of the on-the-wire READ count vs. the amount of
>> data read might be interesting.  It might also be useful to see how
>> often the same client reads the same page in the file repeatedly.
>
> Because the app was designed with O_DIRECT in mind, the app does its
> own file buffering in user space.
>
> If for the Linux port we can move away from O_DIRECT, it would be
> interesting to see if that extra user space buffering could be
> disabled and let the kernel do its job.

You mentioned in an earlier e-mail that the application has its own  
high-level data cache coherency protocol, and it appears that your  
application is using NFS to do what is more or less real-time data  
exchange between MTAs and users, with permanent storage as a side- 
effect.  In that case, the application should manage its own cache,  
since it can better optimize the number of READs required to keep its  
local data caches up to date.  That would address the "too many data  
cache invalidations" problem.

In terms of maintaining the Linux port of your application, you  
probably want to stay as close to the original as possible, yes?    
Given all this, we'd be better off getting O_DIRECT to perform better.

You say above that llseek(2), write(2), and close(2) cause excess  
GETATTR traffic.

llseek(SEEK_END) on an O_DIRECT file pretty much has to do a GETATTR,  
since the client can't trust it's own attribute cache in this case.

I think we can get rid of the GETATTR at close(2) time on O_DIRECT  
files.  On open(2), I think the GETATTR is delayed until the first  
access that uses the client's data cache.  So we shouldn't have an  
extra GETATTR on open(2) of an O_DIRECT file.

You haven't mentioned a specific case where an O_DIRECT write(2)  
generates too many GETATTRs before, unless I missed it.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




