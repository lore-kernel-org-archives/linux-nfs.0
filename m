Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64917 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750809AbZCLVa7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Mar 2009 17:30:59 -0400
Subject: Re: NFS and RPC queues
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Callahan <callahan@temerity.us>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <49B96C0F.3060405@temerity.us>
References: <49B8186F.5070601@temerity.us>
	 <1236809248.12697.44.camel@heimdal.trondhjem.org>
	 <49B96C0F.3060405@temerity.us>
Content-Type: text/plain
Date: Thu, 12 Mar 2009 17:30:47 -0400
Message-Id: <1236893447.7179.53.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2009-03-12 at 16:09 -0400, Jim Callahan wrote:
> Thanks for clearing up what "sunrpc.tcp_slot_table_entries" meant.   Its 
> odd however that even with a default size of 16 we should still see 
> contention between only two OS level processes generating NFS requests 
> though.  Shouldn't that only be using 2 of the 16 entries?  Even our 
> worse case would only generate 17 processes running in parallel.  Or do 
> I misunderstand the granularity?   If I have an NFS rsize/wsize of 32k 
> and perform a C read()/write() of 64k, this will get chunked into two 
> 32k READ/WRITE NFS requests, correct?  But do both of these low level 
> requests from a single process and read()/write() call get run in 
> parallel if there are at least 2 slots in the RPC table available?  In 
> other words, is there an interaction between the rsize/wsize and the 
> number of slots in the RPC table that are used for a single C 
> read()/write()?  Would increasing the rsize/wsize for files larger than 
> this size lead to less utilization of the RPC table and therefore less 
> contention?

The kernel readahead algorithm will cause a single process to create
more than 1 on-the-wire READ request at a time: the process won't wait
for the first READ request to complete before sending the next. The
different READ requests will execute in parallel, and will contend for
slots.

Write-behind does the same for WRITE requests.

You should note, however, that a single process is not allowed to use
more than 16 slots before it has to allow other processes access to the
slot table (however if no other processes have outstanding RPC requests,
then the it is allowed to hog the whole table).

> Also, can someone please answer whether there is an RPC request table 
> for each NFS mount to a different IP address or one shared table for all 
> mounts?  I'd like to have a better understanding of why running our 
> GETATTR requests down a different mount would eliminate the contention 
> with the READ/WRITE requests going down the other mount.

That depends on which kernel you are running. More recent kernels will
tend to multiplex traffic through a slot table that is shared between
all mounts to a single IP address.
Mounts to different IP addresses will, however never share a slot table.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
