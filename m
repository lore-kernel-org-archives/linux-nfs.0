Return-Path: linux-nfs-owner@vger.kernel.org
Received: from devils.ext.ti.com ([198.47.26.153]:50155 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757210Ab2BHTwZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Feb 2012 14:52:25 -0500
Message-ID: <4F32D273.9060001@ti.com>
Date: Wed, 8 Feb 2012 13:52:19 -0600
From: Derek McEachern <derekm@ti.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS Mount Option 'nofsc'
References: <4F31E1CA.8060105@ti.com> <1328676860.2954.9.camel@lade.trondhjem.org> <4F32BB43.6040209@ti.com> <24C2FE94-75EB-497D-ABA4-BADD068808D8@oracle.com>
In-Reply-To: <24C2FE94-75EB-497D-ABA4-BADD068808D8@oracle.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



-------- Original Message --------
Subject: Re: NFS Mount Option 'nofsc'
From: Chuck Lever <chuck.lever@oracle.com>
To: Derek McEachern <derekm@ti.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>, 
"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Wednesday, February 08, 2012 12:15:37 PM

>> So then what exact functionality if provided by the 'nofsc' option? It would seem to me from a write perspective that between noac and the sync option it is pretty close to forcedirectio.
>>
>>  From the man page describing sync "any system call that writes data to files on that mount point causes that data to be flushed to the server before the system call returns control to user  space."
>>
>> Maybe I've answered one of my questions as flushing the data to the server before returning to user space is really what I'm after. The userspace app should be blocked until the write has been acknowledged by the server and if the server is an NFS appliance then I don't necessarily care if it has committed the data to disk as I expect it to managed its cache properly.
>>
>> Though I still want to understand what 'nofsc' is doing.
> "nofsc" disables file caching on the client's local disk.  It has nothing to do with direct I/O.
>

If 'nofsc' disables file caching on the client's local disk does that 
mean that write from userspace could go to kernel memory, then 
potentially to client's local disk, before being committed over network 
to the nfs server?

This seems really odd. What would be the use case for this?

Derek

