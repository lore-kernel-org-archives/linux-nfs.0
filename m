Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:47854 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726775AbeILBlp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Sep 2018 21:41:45 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: A NFS client partial file corruption problem in recent/current
 kernels
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <78ca0a56d72cda910b38a37cadd4780e112c7906.camel@hammerspace.com>
Date: Tue, 11 Sep 2018 16:40:20 -0400
Cc: "cks@cs.toronto.edu" <cks@cs.toronto.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <E2172838-41D5-46E5-B8C7-D5CFD9459DBF@oracle.com>
References: <20180911180218.9A66C322562@apps1.cs.toronto.edu>
 <78ca0a56d72cda910b38a37cadd4780e112c7906.camel@hammerspace.com>
To: Trond Myklebust <trondmy@hammerspace.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Sep 11, 2018, at 4:00 PM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>=20
> On Tue, 2018-09-11 at 14:02 -0400, Chris Siebenmann wrote:
>>>> We've found a readily reproducable situation where the current
>>>> NFS client code will provide zero bytes instead of actual data at
>>>> the end of the file (sort of) to user programs. This can result
>>>> in program failure, or permanent file corruption if the program
>>>> reading the file writes the bad data back to the file; otherwise,
>>>> the corruption goes away when the client's cached data is pushed
>>>> out
>>>> of memory (or explicitly dropped by dropping the pagecache
>>>> through
>>>> /proc/sys/vm/drop_caches).
>>=20
>> [...]
>>> Please see http://nfs.sourceforge.net/#faq_a8
>>=20
>> I don't think this is a close to open consistency issue, or if it is
>> I would argue that it is a clear bug on the Linux NFS client. I have
>> a number of reasons for saying this:
>>=20
>> - the client clearly sees the new attributes; it knows that the file
>>  has been extended from the previous state that it knew of. My demo
>>  program specifically waits until user-level fstat() returns a
>> different
>>  result, which I believe means that the client kernel has seen a
>> different
>>  GETATTR result and so should have purged its cache (based on what
>> the
>>  FAQ says).
>>=20
>>  (Unless the FAQ means that the kernel absolutely refuses to
>> guarantee
>>  anything about file consistency unless you close and then reopen
>> the
>>  file, even if it *knows* that the file has changed on the server,
>>  which isn't clear from how the FAQ is currently written.)
>>=20
>> - the client is fetching some new data from the fileserver (data
>> after
>>  the partial 4 KB page at the old end of the file).
>>=20
>> - the client isn't writing to the file in my demonstration program;
>> it's
>>  only opening it in read-write mode and then reading it. Also, this
>>  doesn't happen if the client does exactly the same set of
>> operations
>>  but has the file open read-only (with it staying open throughout).
>>=20
>> - this didn't happen in older kernels.
>>=20
>> In addition, although I didn't mention it in my original email, this
>> happens on a NFS filesystem mounted 'noac'.
>>=20
>> Pragmatically, Alpine used to work with NFS mounted filesystems where
>> email was appended to them from other machines and it no longer does,
>> and the only difference is the kernel version involved on the client.
>> This breakage is actively dangerous.
>=20
> Sure, but unless you are locking the file, or you are explicitly using
> O_DIRECT to do uncached I/O, then you are in violation of the =
close-to-
> open consistency model, and the client is going to behave as you
> describe above. NFS uses a distributed filesystem model, not a
> clustered one.

I would expect Alpine to work if "vers=3D3,noac" is in use.


--
Chuck Lever
