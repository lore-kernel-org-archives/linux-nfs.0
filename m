Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:62890 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752513Ab0A2R6v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jan 2010 12:58:51 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Message-Id: <E6773BE9-D21C-47E5-8EE4-3146A62592A6@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Quentin Barnes <qbarnes+nfs@yahoo-inc.com>
In-Reply-To: <20100129165756.GA26747@yahoo-inc.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: Random I/O over NFS has horrible performance due to small I/O transfers
Date: Fri, 29 Jan 2010 12:58:35 -0500
References: <20091226204531.GA3356@yahoo-inc.com> <E7A7B701-B471-4D14-8D45-B0FF691D1CCC@oracle.com> <20100121011238.GA30642@yahoo-inc.com> <B02A2206-CFEB-4FF4-8825-E953CFD7637C@oracle.com> <20100124184634.GA19426@yahoo-inc.com> <A9262578-3560-4EEE-87BC-8AA339F77B10@oracle.com> <20100129165756.GA26747@yahoo-inc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

[BTW: every time I reply to you, the e-mail to your address bounces.   
I assume you are able to see my replies through the two reflectors  
that are cc'd].

On Jan 29, 2010, at 11:57 AM, Quentin Barnes wrote:
>>> If the flush call has no data to flush, the GETATTR is pointless.
>>> The file's cached attribute information is already as valid as can
>>> ever be hoped for with NFS and its life is limited by the normal
>>> attribute timeout.  On the other hand, if the flush has cached data
>>> to write out, I would expect the WRITE will return the updated
>>> attributes with the post-op attribute status, again making the
>>> GETATTR on close pointless.  Can you explain what I'm not following?
>>
>> The Linux NFS client does not use the post-op attributes to update  
>> the
>> cached attributes for the file.  Because there is no guarantee that
>> the WRITE replies will return in the same order the WRITEs were sent,
>> it's simply not reliable.  If the last reply to be received was for  
>> an
>> older write, then the mtime and ctime (and possibly the size) would  
>> be
>> stale, and would trigger a false data cache invalidation the next  
>> time
>> a full inode validation is done.
>
> Ah, yes, the out of order WRITE replies problem.  I knew I was
> forgetting something.
>
> This may be a stupid question, but why not use the post-op attribute
> information to update the inode whenever the fattr mtime exceeds the
> inode mtime and just ignore using the post-op update all the other
> times since that would indicate an out of order arrival?

I seem to recall that older versions of our client used to do that,  
and we may still in certain cases.  Take a look at the post-op  
attribute handling near nfs_update_inode() in fs/nfs/inode.c.

One problem is that WRITE replies are entirely asynchronous with  
application writes, and are handled in a different kernel context  
(soft IRQ?  I can't remember).  Serializing updates to the attribute  
cache between different contexts is difficult.  The solution used  
today means that attributes are updated only in synchronous contexts,  
so we can get a handle on the many race conditions without causing  
deadlocks.

For instance, post-op attributes can indicate that the client has to  
invalidate the page cache for a file.  That's tricky to do correctly  
in a context that can't sleep, since invalidating a page needs to take  
the page lock.  Setting NFS_INO_INVALID_ATTR is one way to preserve  
that indication until the client is running in a context where a data  
cache invalidation is safe to do.

> (Of course
> other fields would want to be checked to see if the file suddenly
> changed other state information warranting general invalidation.)
> I would assume that there are other out of order arrivals for other
> op replies that prevent such a trivial algorithm?
>
> This out-of-order post-op attribute data invalidating cache sounds
> like a well-known problem that people have been trying to solve for
> a long time or have proved that it can't be solved.  If there's a
> white paper you can point me to that discuss the problem at length,
> I'd like to read it.

I don't know of one.

>>> However, I tore into the code to better understand what was  
>>> triggering
>>> the GETATTR on close.  A close(2) does two things, a flush
>>> (nfs_file_flush) and a release (nfs_file_release).  I had thought  
>>> the
>>> GETATTR was happening as part of the nfs_file_flush().  It's not.   
>>> The
>>> GETATTR is triggered by the nfs_file_release().  As part of it  
>>> doing a
>>> put_nfs_open_context() -> nfs_close_context() ->
>>> nfs_revalidate_inode(),
>>> that triggers the NFS_PROTO(inode)->getattr()!
>>>
>>> I'm not sure, but I suspect that O_DIRECT files take the
>>> put_nfs_open_context() path that results in the extraneous GETATTR
>>> on close(2) because filp->private_data is non-NULL where for regular
>>> files it's NULL.  Is that right?  If so, can this problem be easily
>>> fixed?
>>
>> I'm testing a patch to use an asynchronous close for O_DIRECT files.
>> This will skip the GETATTR for NFSv2/v3 O_DIRECT files, and avoid
>> waiting for the CLOSE for NFSv4 O_DIRECT files.
>
> When you're ready for external testing, will you be publishing it here
> on the NFS mailing list?  Any guess when it might be ready?

I have a pair of patches in my kernel git repo at git.linux-nfs.org  
(cel).  One fixes close, the other attempts to address open.  I'm  
still working on the open part.  I'm hoping to get these into 2.6.34.   
I'm sure these are not working quite right yet, but you might want to  
review the work, as it probably looks very similar to what you've  
already done internally.

I've also noticed that our client still sends a lot of ACCESS requests  
in the simple open-write-close use case.  Too many ACCESS requests  
seem to be a perennial problem.  I'm going to look at that next.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




