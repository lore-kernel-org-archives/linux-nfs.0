Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:50197 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757372Ab2BHUAa convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Feb 2012 15:00:30 -0500
Subject: Re: NFS Mount Option 'nofsc'
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=US-ASCII
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4F32D273.9060001@ti.com>
Date: Wed, 8 Feb 2012 15:00:24 -0500
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <A0BFC63F-F357-45D8-B030-FB3217289430@oracle.com>
References: <4F31E1CA.8060105@ti.com> <1328676860.2954.9.camel@lade.trondhjem.org> <4F32BB43.6040209@ti.com> <24C2FE94-75EB-497D-ABA4-BADD068808D8@oracle.com> <4F32D273.9060001@ti.com>
To: Derek McEachern <derekm@ti.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 8, 2012, at 2:52 PM, Derek McEachern wrote:

> 
> 
> -------- Original Message --------
> Subject: Re: NFS Mount Option 'nofsc'
> From: Chuck Lever <chuck.lever@oracle.com>
> To: Derek McEachern <derekm@ti.com>
> CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>, "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
> Date: Wednesday, February 08, 2012 12:15:37 PM
> 
>>> So then what exact functionality if provided by the 'nofsc' option? It would seem to me from a write perspective that between noac and the sync option it is pretty close to forcedirectio.
>>> 
>>> From the man page describing sync "any system call that writes data to files on that mount point causes that data to be flushed to the server before the system call returns control to user  space."
>>> 
>>> Maybe I've answered one of my questions as flushing the data to the server before returning to user space is really what I'm after. The userspace app should be blocked until the write has been acknowledged by the server and if the server is an NFS appliance then I don't necessarily care if it has committed the data to disk as I expect it to managed its cache properly.
>>> 
>>> Though I still want to understand what 'nofsc' is doing.
>> "nofsc" disables file caching on the client's local disk.  It has nothing to do with direct I/O.
>> 
> 
> If 'nofsc' disables file caching on the client's local disk does that mean that write from userspace could go to kernel memory, then potentially to client's local disk, before being committed over network to the nfs server?
> 
> This seems really odd. What would be the use case for this?

With "fsc", writes are indeed slower, but reads of a very large file that rarely changes are on average much better.  If a file is significantly larger than a client's page cache, a client can cache that file on its local disk, and get local read speeds instead of going over the wire.

Additionally if multiple clients have to access the same large file, it reduces the load on the storage server if they have their own local copies of that file, since the file is too large for the clients to cache in their page cache.  This also has the benefit of keeping the file data cached across client reboots.

This feature is an optimization for HPC workloads, where a large number of clients access very large read-mostly datasets on a handful of storage servers.  The clients' local fsc absorbs much of the aggregate read workload, allowing storage servers to scale to a larger number of clients.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




