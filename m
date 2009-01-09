From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [patch 10/14] sunrpc: Reorganise the queuing of cache upcalls.
Date: Sat, 10 Jan 2009 10:29:43 +1100
Message-ID: <4967DDE7.40106@melbourne.sgi.com>
References: <20090108082510.050854000@sgi.com> <20090108082604.517918000@sgi.com> <20090108195747.GB19312@fieldses.org> <4966B92F.8060008@melbourne.sgi.com> <20090109212921.GC5466@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:39129 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752592AbZAIXhh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Jan 2009 18:37:37 -0500
In-Reply-To: <20090109212921.GC5466@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Fri, Jan 09, 2009 at 01:40:47PM +1100, Greg Banks wrote:
>   
>> J. Bruce Fields wrote:
>>     
>>
>   
>>>  static ssize_t
>>>  cache_read(struct file *filp, char __user *buf, size_t count, loff_t *ppos)
>>>  {
>>> -	struct cache_reader *rp = filp->private_data;
>>> -	struct cache_request *rq;
>>> +	struct cache_request *rq = filp->private_data;
>>>  	struct cache_detail *cd = PDE(filp->f_path.dentry->d_inode)->data;
>>> +	struct list_head *queue = &cd->queue;
>>>  	int err;
>>>  
>>>  	if (count == 0)
>>> @@ -711,60 +703,45 @@ cache_read(struct file *filp, char __user *buf, size_t count, loff_t *ppos)
>>>  	mutex_lock(&queue_io_mutex); /* protect against multiple concurrent
>>>  			      * readers on this file */
>>>   
>>>       
>> Ah, so you still have a single global lock which is serialising all
>> reads and writes to all caches.
>>     
>
> Yes, making this per-cd seems sensible (though if the problem is
> typically a single cache (auth_unix) then I don't know how significant a
> help it is).
>   
The usual pattern of traffic I see (on a SLES10 platform with the older
set of export caches) when the first NFS packet arrives during a client
mounts is:

 - upcall to mountd via auth.unix.ip cache
 - mountd writes pre-emptively to nfsd.export and nfsd.expkey caches
 - mountd write reply to auth.unix.ip cache

So it's not just a single cache.

However, I have no measurements for any performance improvement.  Based
on earlier experience I believe the elapsed mounting time to be
dominated by the latency of the forward and reverse DNS lookup that
mountd does, so the improvement is probably small.

>   
>>
>> I think partial reads are Just Too Hard to do properly, i.e. without
>> risk of racy message corruption under all combinations of message size
>> and userspace behaviour .  In particular I think your code will corrupt
>> upcall data if multiple userspace threads race to do partial reads on
>> the same struct file (as rpc.mountd is doing at SGI's customer sites).
>>     
>
> Yes, but what mountd's doing is just dumb, as far as I can tell; is
> there any real reason not to just keep a separate open for each thread?
>   
None at all.  The current rpc.mountd behaviour is a historical accident
of the "look, we can put a fork() here and everything will Just Work"
variety.  I was hoping to avoid changes to the current userspace
behaviour to limit deployment hassles with shipping a fix, but
ultimately it can be changed.

> If we just tell userland to keep a number of opens equal to the number
> of concurrent upcalls it wants to handle, and then all of this becomes
> very easy.
>   
If we put that requirement on userspace, and partial reads are still
necessary, then your approach of using filp->private_data as a parking
spot for requests currently being read would be the right way to go.

> Forget sharing a single struct file between tasks that do too-small
> reads: we should make sure that we don't oops, but that's all.
>   
We should definitely not oops :-)  Consistently delivering correct
messages to userspace would be nice too.

> So, the somewhat depressing situation with spkm3, which was to be the
> public-key-based gss mechanism for nfs: we (citi) implemented it (modulo
> this problem and maybe one or two others), but found some problems along
> the way that required revising the spec.
This is frequently the way with specs :-/

> [...]
> So: the immediate pressure for larger upcalls is probably gone.
Sweet.

> That said, I think it's easy enough to handle just the case of multiple
> reads on unshared struct files that it might make sense to keep that
> piece.
>
>   
>> A smaller issue is that you keep a single list and use the value of the
>> CACHE_PENDING bit to tell the difference between states. [...]
>>     
>
> OK.  When exactly do they get moved between lists?
Immediately after being copied out to userspace in cache_read().

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

