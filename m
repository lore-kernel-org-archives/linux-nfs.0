Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f177.google.com ([209.85.128.177]:58433 "EHLO
	mail-ve0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443AbaFDV4e convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jun 2014 17:56:34 -0400
Received: by mail-ve0-f177.google.com with SMTP id db11so156137veb.22
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jun 2014 14:56:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <006301cf803c$fe1f2200$fa5d6600$@iozone.org>
References: <004501cf8013$7a3373c0$6e9a5b40$@iozone.org>
	<005d01cf801f$363aabf0$a2b003d0$@iozone.org>
	<CAHQdGtQ9ceYQJD0eEehLhq1T2KsWRv11hkOVg9=NdpS9h4OJLA@mail.gmail.com>
	<006101cf8038$79c71d90$6d5558b0$@iozone.org>
	<CAHQdGtR6CL-M4gi8qMEoX+E65gA8X2AHA3ya_B__T3KNcCBVSw@mail.gmail.com>
	<006301cf803c$fe1f2200$fa5d6600$@iozone.org>
Date: Wed, 4 Jun 2014 17:56:33 -0400
Message-ID: <CAHQdGtSkGey_abep4uJb5dUKSxyr6RTKaTuOpaZX_4BvBfqo+Q@mail.gmail.com>
Subject: Re: FW: Forwarding request at suggestion from support
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Don Capps <capps@iozone.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 4, 2014 at 5:36 PM, Iozone <capps@iozone.org> wrote:
> Trond,
>
>            I have traces where there are indeed a bunch of async reads issued, and
>         the replies come back. One with data, and all of the rest with zero bytes
>         transferred, indicating EOF.  This was followed by a bunch more async
>         reads, all of which come back with zero bytes transferred.  It appears
>         that if the user requested 16MB, and the file was 4k, then there will
>         be 16MB of transfers issued regardless of the fact that all but one
>         are returning zero bytes....
>
>
>         Business case:
>            This not only could this impact benchmarks... but it also has the potential
>         of opening a door for a DOS type attack on an NFS server.   All it would take
>         is one small file, and a bunch of clients going after 1GB reads on that file
>         with O_DIRECT, and the poor NFS server is going to get slammed with
>         requests at a phenomenal rate (as the client is issuing these back-to-back
>         async, and the server is responding with back-to-back zero length
>         transfer replies).  The client burns very little CPU, and the NFS server
>         is buried, doing zero length transfers... pretty much in a very tight loop....

Sorry, but no, that's not convincing. There are plenty of things you
can do using NFS to force the server to do unnecessary work. Fire up
1000 threads and your one client can slam it with stat() calls,
open(), readdir, or anything else you care to name. The server can and
should throttle the TCP connection if it wants to push back on a
particular client to slow down the rate.

As I indicated earlier, the main question here is what is the value of
this functionality to specific applications that need to use O_DIRECT.


> Thank you,
> Don Capps
>
>
> -----Original Message-----
> From: Trond Myklebust [mailto:trond.myklebust@primarydata.com]
> Sent: Wednesday, June 04, 2014 4:15 PM
> To: capps@iozone.org
> Cc: Linux NFS Mailing List
> Subject: Re: FW: Forwarding request at suggestion from support
>
> On Wed, Jun 4, 2014 at 5:03 PM, Iozone <capps@iozone.org> wrote:
>> Trond,
>>
>>         Ok... but as the replies are coming back, all but one with EOF and zero bytes
>>         transferred, does it still make sense to keep issuing reads that are beyond EOF ?
>
> It depends. The reads should all be sent asynchronously, so it isn't clear to me that the client will see the EOF until all the RPC requests are in flight.
>
> That said, it is true that we do not have any machinery right now to stop further submissions if we see that we have already collected enough information to complete the read() syscall. Are there any good use cases for O_DIRECT that justify adding such machinery? Oracle doesn't seem to need it.
>
> Cheers
>   Trond
>
>> Enjoy,
>> Don Capps
>>
>> -----Original Message-----
>> From: Trond Myklebust [mailto:trond.myklebust@primarydata.com]
>> Sent: Wednesday, June 04, 2014 3:42 PM
>> To: capps@iozone.org
>> Cc: Linux NFS Mailing List
>> Subject: Re: FW: Forwarding request at suggestion from support
>>
>> Hi Don,
>>
>> On Wed, Jun 4, 2014 at 2:02 PM, Iozone <capps@iozone.org> wrote:
>>>
>>>
>>> From: Iozone [mailto:capps@iozone.org]
>>> Sent: Wednesday, June 04, 2014 11:39 AM
>>> To: linux-nfs@vger.kernel.org
>>> Subject: Forwarding request at suggestion from support
>>>
>>>                 Dear kernel folks,
>>>
>>>                                 Please take a look at Bugzilla bug:
>>>
>>> https://bugzilla.redhat.com/show_bug.cgi?id=1104696
>>>
>>> Description of problem:
>>>
>>>    Linux NFSv3 clients can issue extra reads beyond EOF.
>>>
>>> Condition of the test:  (32KB_file is a file that is 32KB in size)
>>>           File is being read over an NFSv3 mount.
>>>
>>>           dd if=/mnt/32KB_file  of=/dev/null iflag=direct bs=1M
>>> count=1
>>>
>>> What one should expect over the wire:
>>>           NFSv3_read for 32k, or NFS_read for 1M
>>>           NFSv3_read Reply return of 32KB and EOF set.
>>>
>>> What happens with Linux NFSv3 client:
>>>           NFSv3 read for 128k
>>>           NFSv3 read for 128k,
>>>           NFSv3 read for 128k,
>>>           NFSv3 read for 128k,
>>>           NFSv3 read for 128k,
>>>           NFSv3 read for 128k,
>>>           NFSv3 read for 128k,
>>>           NFSv3 read for 128k.
>>>        followed by:
>>>           NFSv3 read reply of 32k,
>>>           NFSv3 read reply of 0,
>>>           NFSv3 read reply of 0,
>>>           NFSv3 read reply of 0,
>>>           NFSv3 read reply of 0,
>>>           NFSv3 read reply of 0,
>>>           NFSv3 read reply of 0,
>>>           NFSv3 read reply of 0.
>>>
>>> So… instead of a single round trip with a short read length returned,
>>> there were 8 async I/O ops sent to the NFS server, and 8 replies from
>>> the NFS server.
>>> The client knew the file size before even sending the very first
>>> request, but went ahead and issued an large number of reads that it
>>> should have known were beyond EOF.
>>>
>>> This client behavior hammers NFS servers with requests that are
>>> guaranteed to always fail, and burn CPU cycles, for operations that
>>> it knew were pointless.
>>>
>>> While the application is getting correct answers to the API calls,
>>> the poor client and server are beating each other senseless over the wire.
>>>
>>> NOTE: This only happens if O_DIRECT is being used… (thus the
>>> iflag=direct)
>>
>> Yes. This behaviour is intentional in the case of O_DIRECT. The reason why we should not change it is that we don't ever want to rely on cached values for the file size when doing uncached I/O.
>> An application such as Oracle may have out-of-band information about writes to the file that were made by another client directly to the server, in which case it would be wrong for the kernel to truncate those reads based on its cached information.
>>
>> Cheers
>>   Trond
>>
>> --
>> Trond Myklebust
>>
>> Linux NFS client maintainer, PrimaryData
>>
>> trond.myklebust@primarydata.com
>>
>
>
>
> --
> Trond Myklebust
>
> Linux NFS client maintainer, PrimaryData
>
> trond.myklebust@primarydata.com
>



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
