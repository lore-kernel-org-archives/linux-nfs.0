Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:45370 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753320Ab2DJA1y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Apr 2012 20:27:54 -0400
Received: by iagz16 with SMTP id z16so6584707iag.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 Apr 2012 17:27:53 -0700 (PDT)
Message-ID: <4F837E87.3070204@gmail.com>
Date: Mon, 09 Apr 2012 19:27:51 -0500
From: Calvin Owens <jcalvinowens@gmail.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [GSoC Project] Implementing NFS v4.2
References: <4F7E32D4.3030201@gmail.com> <1333682276.4792.32.camel@lade.trondhjem.org>
In-Reply-To: <1333682276.4792.32.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/05/2012 10:17 PM, Myklebust, Trond wrote:
> On Thu, 2012-04-05 at 19:03 -0500, Calvin Owens wrote:
>> Hello all,
>>
>> I'm interested in implementing the draft specification for NFS v4.2 as a
>> Google Summer of Code project. That includes server-side copying, sparse
>> files, and carrying fadvise() calls through to the server, among other
>> things.
>>
>> The current document can be found here:
>> http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-07
>>
>> Is this something that you need to be done? If so, I'd very much like to
>> be involved. :)
>
> Hi Calvin,
>
> Labelled NFS is likely to be merged into 3.5 (if Dave Q finds the time
> to port his existing code).
 >
> Copy offload already exists in prototype form. The main remaining issue
> is working out the user syscall interface, which really requires getting
> all the interested filesystem maintainers to agree (we've started on
> doing that).
>
> If you'd like to contribute, then I'd suggest looking into SEEK (for
> providing lseek(SEEK_HOLE/SEEK_DATA) support. There is also the hole
> punching/space reservation, that should fit nicely into the fallocate()
> system call.

Yes, that sounds good. I'll start looking into that.

> The efficient sparse file read and fadvise support might be nice too,
> but I'd like to see numbers for how they improve matters before I feel
> comfortable saying yea or nay to adding those specific features.

I definitely see your point. It does seem to be a lot of added 
complexity for a negligible benefit.

> Note that there are also a bunch of NFSv4.1 features that have yet to be
> implemented, so the above list of tasks is not exhaustive. I'd be happy
> to work with you to find something...

What else, precisely, would you like to get done? I need to get some 
more detailed objectives to put into my application. (Forgive me for so 
blatantly not looking myself, but it seems more efficient than me 
digging through the code finding missing features and lobbing them at 
you for approval, when I'm sure you know exactly where your priorities 
are...)

Thanks very much,
Calvin Owens
