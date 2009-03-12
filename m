Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from vps680.inmotionhosting.com ([74.124.198.230]:39311 "EHLO
	vps680.inmotionhosting.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750809AbZCLVJt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Mar 2009 17:09:49 -0400
Message-ID: <49B96C0F.3060405@temerity.us>
Date: Thu, 12 Mar 2009 16:09:51 -0400
From: Jim Callahan <callahan@temerity.us>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: NFS and RPC queues
References: <49B8186F.5070601@temerity.us> <1236809248.12697.44.camel@heimdal.trondhjem.org>
In-Reply-To: <1236809248.12697.44.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust wrote:
> Jim Callahan wrote:
>   
>> I'm trying to diagnose an NFS performance problem and need to know a bit 
>> more about how the Linux NFS client works internally.  I've got a single 
>> NFS client which is connected to a network appliance file server via 1Gb 
>>     
>                                      NetApp ?
>   
Actually, not.   Its one of the other supposedly high performance 
commercial products though...  I'd rather not say which at this time in 
the interest of encouraging their help resolving this.

>> ...
>>
>> Is the RPC queue used by NFS processed in a serial fashion for each 
>> mount to a unique IP address?  One possible explanation is that the 
>> GETATTR requests are simply waiting in line behind READ/WRITES in the 
>> one network case and that explains the drop in performance.  So does 
>> using a different IP address for the second mount create a second RPC 
>> queue which is processed in an asynchronous manner?  That might explain 
>> the lack of interaction between the GETATTR's and READ/WRITES in our 
>> second test...
>>     
>
> Try increasing the value of the sunrpc.tcp_slot_table_entries sysctl
> entry on the Linux client. That sysctl controls the maximum number of
> simultaneous RPC messages that are allowed on the TCP connection.
>
> The default is 16, but it can be increased to 128. Just make sure that
> you umount all NFS partitions before changing it. (Doing 'mount
> -oremount' won't work...)
>
> Trond
>   
Thanks for clearing up what "sunrpc.tcp_slot_table_entries" meant.   Its 
odd however that even with a default size of 16 we should still see 
contention between only two OS level processes generating NFS requests 
though.  Shouldn't that only be using 2 of the 16 entries?  Even our 
worse case would only generate 17 processes running in parallel.  Or do 
I misunderstand the granularity?   If I have an NFS rsize/wsize of 32k 
and perform a C read()/write() of 64k, this will get chunked into two 
32k READ/WRITE NFS requests, correct?  But do both of these low level 
requests from a single process and read()/write() call get run in 
parallel if there are at least 2 slots in the RPC table available?  In 
other words, is there an interaction between the rsize/wsize and the 
number of slots in the RPC table that are used for a single C 
read()/write()?  Would increasing the rsize/wsize for files larger than 
this size lead to less utilization of the RPC table and therefore less 
contention?

Also, can someone please answer whether there is an RPC request table 
for each NFS mount to a different IP address or one shared table for all 
mounts?  I'd like to have a better understanding of why running our 
GETATTR requests down a different mount would eliminate the contention 
with the READ/WRITE requests going down the other mount.

We'll definitely be bumping up the "sunrpc.tcp_slot_table_entries" to 
128 and re-running our tests though.  Thanks for the help so far...

-- 
Jim Callahan - President - Temerity Software <www.temerity.us>
