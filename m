Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bear.ext.ti.com ([192.94.94.41]:52495 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750863Ab2BHVQ5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 16:16:57 -0500
Message-ID: <4F32E643.8050601@ti.com>
Date: Wed, 8 Feb 2012 15:16:51 -0600
From: Derek McEachern <derekm@ti.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS Mount Option 'nofsc'
References: <4F31E1CA.8060105@ti.com> <1328676860.2954.9.camel@lade.trondhjem.org> <4F32BB43.6040209@ti.com> <24C2FE94-75EB-497D-ABA4-BADD068808D8@oracle.com> <4F32D273.9060001@ti.com> <A0BFC63F-F357-45D8-B030-FB3217289430@oracle.com>
In-Reply-To: <A0BFC63F-F357-45D8-B030-FB3217289430@oracle.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



-------- Original Message --------
Subject: Re: NFS Mount Option 'nofsc'
From: Chuck Lever <chuck.lever@oracle.com>
To: Derek McEachern <derekm@ti.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>, 
"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Wednesday, February 08, 2012 2:00:24 PM
> On Feb 8, 2012, at 2:52 PM, Derek McEachern wrote:
>
>> If 'nofsc' disables file caching on the client's local disk does that mean that write from userspace could go to kernel memory, then potentially to client's local disk, before being committed over network to the nfs server?
>>
>> This seems really odd. What would be the use case for this?
> With "fsc", writes are indeed slower, but reads of a very large file that rarely changes are on average much better.  If a file is significantly larger than a client's page cache, a client can cache that file on its local disk, and get local read speeds instead of going over the wire.
>
> Additionally if multiple clients have to access the same large file, it reduces the load on the storage server if they have their own local copies of that file, since the file is too large for the clients to cache in their page cache.  This also has the benefit of keeping the file data cached across client reboots.
>
> This feature is an optimization for HPC workloads, where a large number of clients access very large read-mostly datasets on a handful of storage servers.  The clients' local fsc absorbs much of the aggregate read workload, allowing storage servers to scale to a larger number of clients.
>

Thank you, this makes sense for 'fsc'. I'm going to assume then that the 
default is 'nofsc' if nothing is specified.

Derek


