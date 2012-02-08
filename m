Return-Path: linux-nfs-owner@vger.kernel.org
Received: from devils.ext.ti.com ([198.47.26.153]:44834 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753077Ab2BHSNZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Feb 2012 13:13:25 -0500
Message-ID: <4F32BB43.6040209@ti.com>
Date: Wed, 8 Feb 2012 12:13:23 -0600
From: Derek McEachern <derekm@ti.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS Mount Option 'nofsc'
References: <4F31E1CA.8060105@ti.com> <1328676860.2954.9.camel@lade.trondhjem.org>
In-Reply-To: <1328676860.2954.9.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



-------- Original Message --------
Subject: Re: NFS Mount Option 'nofsc'
From: Myklebust, Trond <Trond.Myklebust@netapp.com>
To: Derek McEachern <derekm@ti.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Tuesday, February 07, 2012 10:55:04 PM
> On Tue, 2012-02-07 at 20:45 -0600, Derek McEachern wrote:
>> I joined the mailing list shortly after Neil sent out a request for
>> volunteer to update the nfs man page documenting the 'fsc'/'nofsc'
>> options. I suspect this may stem from a ticket we opened with Suse
>> inquiring about these options.
>>
>> Coming from a Solaris background we typically use the 'forcedirectio'
>> option for certain mounts and I was looking for the same thing in Linux.
>> The typically advice seems to be use 'noac' but the description in the
>> man page doesn't seem to match what I would expect from 'forcedirectio',
>> namely no buffering on the client.
>>
>> Poking around the kernel I found the 'fsc'/'nofsc' options and my
>> question is does 'nofsc' provide 'forcedirectio' functionality?
> No. There is no equivalent to the Solaris "forcedirectio" mount option
> in Linux.
> Applications that need to use uncached i/o are required to use the
> O_DIRECT open() mode instead, since pretty much all of them need to be
> rewritten to deal with the subtleties involved anyway.
>
> Trond

So then what exact functionality if provided by the 'nofsc' option? It 
would seem to me from a write perspective that between noac and the sync 
option it is pretty close to forcedirectio.

 From the man page describing sync "any system call that writes data to 
files on that mount point causes that data to be flushed to the server 
before the system call returns control to user  space."

Maybe I've answered one of my questions as flushing the data to the 
server before returning to user space is really what I'm after. The 
userspace app should be blocked until the write has been acknowledged by 
the server and if the server is an NFS appliance then I don't 
necessarily care if it has committed the data to disk as I expect it to 
managed its cache properly.

Though I still want to understand what 'nofsc' is doing.

Derek
