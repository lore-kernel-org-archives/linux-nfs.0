From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: FLushing cached writes in nfs_getattr() and stat() delay
Date: Thu, 6 Nov 2008 14:45:34 -0500
Message-ID: <B01C5173-08DF-4EF9-8186-BEBDA8EE9862@oracle.com>
References: <200811061034.06486.asid@hp.com> <1225997396.387.30.camel@heimdal.trondhjem.org> <200811061422.58920.alexandre.sidorenko@hp.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Alex Sidorenko <alexandre.sidorenko@hp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:20278 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733AbYKFTpp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Nov 2008 14:45:45 -0500
In-Reply-To: <200811061422.58920.alexandre.sidorenko@hp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 6, 2008, at Nov 6, 2008, 2:22 PM, Alex Sidorenko wrote:
> On November 6, 2008 01:49:56 pm Trond Myklebust wrote:
>> On Thu, 2008-11-06 at 10:34 -0500, Alex Sidorenko wrote:
>>> I understand the reasoning behind that. From application point of  
>>> view,
>>> NFS file/directory should behave the same as on local FS. If we have
>>> queued many writes, without this patch stat() will return incorrect
>>> results, both for mtime and file length. Some applications may  
>>> depend on
>>> stat() results being correct.
>>>
>>> At the same time, the fact that we have to wait forever while  
>>> copying big
>>> files and doing 'ls -l' on that directory (or on the file being  
>>> written)
>>> is not very good either (two HP customers have complained about this
>>> after migrating from RHEL4 to RHEL5).
>>
>> In order to relax that requirement, we'd have to introduce some
>> mechanism for the application to notify the filesystem that they  
>> don't
>> care about strictly correct c/mtimes. As you noted above, returning
>> incorrect mtimes may trip up some applications (backup  
>> applications, and
>> mail readers are a couple of business critical cases that come to  
>> mind).
>>
>>> The problem is still there in 2.6.27. I am not sure what can be  
>>> done to
>>> both reduce the stat() delay and guarantee reasonable stat()  
>>> results.
>>>
>>> It is interesting that with 'noac' stat() returns much faster  
>>> (just 1-3s
>>> delay).
>>
>> That would be because 'noac' enforces synchronous writes. If you  
>> don't
>> care about the degraded write performance, you can do the same thing
>> without all the extra getattr clutter that noac introduces, by simply
>> mounting with -osync.
>
> Hi Trond,
>
> In my experiments on 2.6.24 I saw practically no performance  
> degradation while
> doing 'cp' of a 4Gb file with 'noac', with 'sync' the performance is  
> really
> bad. And writes are still definitely ASYNC, here is what I see using
> Systemtap script on entry to rpc_execute

There's a difference between an asynchronous RPC request, and an  
asynchronous write request.

An async RPC means the process doesn't wait for the request to finish,  
it can perform other housekeeping.

An async write means that the client delays sending NFS writes,  
maintaining the dirty data in its memory.  It can send the NFS write  
requests by means of an async RPC if it wishes.  A synchronous write  
means that the client will block the application until the server has  
replied that the dirty data is on the server's disk.

> from /etc/mtab:
>
> cats:/data /mnt nfs rw,udp,noac,hard,intr,addr=192.168.0.33 0 0
>
> $ dd if=/dev/zero of=/mnt/win/big bs=100m count=1
>
> From stap output:
> rpc_execute p_proc=7 WRITE qlen=0 prio=1 flags=0x1
> --ts=4
> rpc_execute p_proc=7 WRITE qlen=0 prio=1 flags=0x1
> ...
>
> So we still have RPC_TASK_ASYNC set.

See above.

> I did not check experimentally 'noac' on 2.6.27 but I still think  
> that 'noac'
> does not make writes sync. nfs_commit_rpcsetup() still sets  
> RPC_TASK_ASYNC by
> default and I don't see NFS_MOUNT_NOACL setting FLUSH_SYNC anywhere.

Again, RPC_TASK_ASYNC has nothing to do with whether the application  
is blocked until the server says the write is permanent.

> So I still don't quite understand why 'noac' eliminates the delay.  
> Chuck Lever
> says that "noac" never caches writes on the client. Printing
> xprt->backlog->qlen in my experiments I can still see a significant  
> backlog
> even with 'noac', e.g.
>
> --ts=32
> rpc_execute p_proc=7 WRITE qlen=3086 prio=1 flags=0x1
>
> but 'stat' delay is just 1-2s.
>
> Regards,
> Alex
>
> -- 
> ------------------------------------------------------------------
> Alexandre Sidorenko             email: asid@hp.com
> Global Solutions Engineering:   Unix Networking
> Hewlett-Packard (Canada)
> ------------------------------------------------------------------
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




