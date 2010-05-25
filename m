Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:64518 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754317Ab0EYRLt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 May 2010 13:11:49 -0400
Message-ID: <4BFC046F.7000005@oracle.com>
Date: Tue, 25 May 2010 10:10:07 -0700
From: Sunil Mushran <sunil.mushran@oracle.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: Pavel Machek <pavel@ucw.cz>, Lukas Hejtmanek <xhejtman@ics.muni.cz>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, salvet@ics.muni.cz
Subject: Re: Deadlock in NFSv4 in all kernels
References: <20100507153920.GP28167@ics.muni.cz>	 <20100524212422.GA1286@ucw.cz> <1274790520.2949.20.camel@heimdal.trondhjem.org>
In-Reply-To: <1274790520.2949.20.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/25/2010 05:28 AM, Trond Myklebust wrote:
>>> I encountered the following problem. We use short expiration time for
>>> kerberos contexts created by rpc.gssd (some patches were included in mainline
>>> nfs-utils). In particular, we use 120secs expiration time.
>>>
>>> Now, I run application that eats 80% of available RAM. Then I run 10 parallel
>>> dd processes that write data into NFS4 volume with sec=krb5.
>>>
>>> As soon as the kerberos context expires (i.e., up to 120 secs), the whole
>>> system gets stuck in do_page_fault and succesive functions. It is because
>>> there is no free memory in kernel, all free memory is used as cache for NFS4
>>> (due to dd traffic), kernel ask NFS to write back its pages but NFS cannot do
>>> anything as it is missing valid context. NFS contacts rpc.gssd to provide
>>> a renewed context, the rpc.gssd does not provide the context as it needs some memory
>>> to scan /tmp for a ticket. I.e., it deadlocks.
>>>
>>> Longer context expiration time is no real solution as it only makes the
>>> deadlock less often.
>>>
>>> Any ideas what can be done here? (Please cc me.) We could preallocate some
>>> memory in rpc.gssd and use mlockall but not sure whether this proctects also
>>> kernel malloc for things related to rpc.gssd and context creation (new file
>>> descriptors and so on).
>>>
>>> This is seen in 2.6.32 kernel but most probably this is related to all kernel
>>> versions.
>>>        
>> Seems like pretty fundamental problem in nfs :-(. Limiting writeback
>> caches for nfs, so that system has enough memory to perform rpc calls
>> with the rest might do the trick, but...
>>      
> It's the same problem that you have for any file or storage system that
> has initiators in userland. On the storage side, iSCSI in particular has
> the same problem. On the filesystem side, CIFS, AFS, coda, .... do too.
> The clustered filesystems can deadlock if the node that is running the
> DLM runs out of memory...
>    

Not so trivially. In ocfs2, the dlm allocates small blocks with GFP_NOFS.
Furthermore, in the time-sensitive recovery thread, it preallocates buffers,
what it can, at create time. That does not mean it is not affected by
memory pressure. It is. But that shows up as slower response and not
a deadlock.

