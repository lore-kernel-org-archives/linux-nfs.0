Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:49528 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211Ab0HRSR6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 14:17:58 -0400
Subject: Re: Proposal: Use hi-res clock for file timestamps
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20100818173203.GC32430@fieldses.org>
Date: Wed, 18 Aug 2010 14:15:51 -0400
Cc: Neil Brown <neilb@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>,
        "Patrick J. LoPresti" <lopresti@gmail.com>,
        Andi Kleen <andi@firstfloor.org>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
Message-Id: <0F91AB9D-0E14-4384-ADD6-0A467C3ABFAC@oracle.com>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com> <87aaolwar8.fsf@basil.nowhere.org> <20100817174134.GA23176@fieldses.org> <20100817182920.GD18161@basil.fritz.box> <20100817190447.GA28049@fieldses.org> <AANLkTi=w1UA5ZZDBigpxMiL7A7DnbnQhLkg62JZpC6Ri@mail.gmail.com> <20100817203941.729830b7@lxorguk.ukuu.org.uk> <20100817192937.GD26609@fieldses.org> <20100818155359.66b9ddb6@notabene> <20100818173203.GC32430@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 18, 2010, at 1:32 PM, J. Bruce Fields wrote:

> On Wed, Aug 18, 2010 at 03:53:59PM +1000, Neil Brown wrote:
>> I'm not sure you even want to pay for a per-filesystem atomic access when
>> updating mtime.  mnt_want_write - called at the same time - seems to go to
>> some lengths to avoid an atomic operation.
>> 
>> I think that nfsd should be the only place that has to pay the atomic
>> penalty, as it is where the need is.
>> 
>> I imagine something like this:
>> - Create a global struct timespec which is protected by a seqlock
>>   Call it current_nfsd_time or similar.
>> - file_update_time reads this and uses it if it is newer than
>>   current_fs_time.
>> - nfsd updates it whenever it reads an mtime out of an inode that matches
>>   current_fs_time to the granularity of 1/HZ.
> 
> We can also skip the update whenever current_nfsd_time is greater than
> the inode's mtime--that's enough to ensure that the next
> file_update_time() call will get a time different from the inode's
> current mtime.

Would it help if we only did this for directories, for now?

Files have close-to-open.  Directories... don't.  So we have the problem where directory changes (ie file creation and deletion) takes a long time (some times an infinitely long time) to propagate to clients.  Plus: directories don't change very often, so using fine-grained time stamps only on directories wouldn't impact heavy I/O workloads.

> And that means that a sequence like
> 
> 	file_update_time()
> 	N nfsd_getattr()'s
> 
> doesn't make N updates to current_nfsd_time, when only 1 was necessary.
> 
>>   If the current value is before current_kernel_time, it
>>   is set to current_kernel_time, otherwise tv_nsec is incremented -
>>   unless that increases
>>   beyond jiffies_to_usec(1)*1000 beyond current_kernel_time.
> 
> ... which would only happen on hardware that could process a getattr and
> a data update per nanosecond continuously for a jiffy.
> 
>> - the global 'struct timespec' is zeroed whenever system time is set
>>   backwards.
> 
> OK, got it, I think: so this is the same as a global version of Alan's
> clock, except that the extra ticks only happen when they need to.
> 
> The properties it satisfies:
> 
> 	- It's still a single global clock, so it's consistent between
> 	  files.
> 	- It degenerates to jiffies in the absence of getattr's from
> 	  nfsd.
> 	- It need only invalidate the other cpus' cached value of the
> 	  clock on the first getattr of a file that follows less than a
> 	  jiffy after an update of the file's data.
> 	- Absent utime(), time going backwards, or futuristic hardware,
> 	  it guarantees that two nfsd reads of an inode's mtime will
> 	  return different values iff the inode's data was modified in
> 	  between the two.
> 
> Shortcomings:
> 
> 	- The clock advances in units only of either 1 jiffy or 1 ns.
> 	  This will look odd.  But when the alternative is units of 1
> 	  jiffy or 0 ns, it seems an improvement....
> 	- A slowdown due to inodes being file_update_time() marking inodes
> 	  dirty more frequently?
> 	- Doesn't help with ext3.  Oh well.
> 
> Would the extra expense rule out treating sys_stat() the same as nfsd?
> It would be nice to be able to solve the same problem for userspace
> nfsd's (or any other application that might be using mtime to save
> rereading data).
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
chuck[dot]lever[at]oracle[dot]com




