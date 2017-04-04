Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45224 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754533AbdDDVb6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Apr 2017 17:31:58 -0400
Subject: Re: [PATCH 1/2] nfsd: Allow the caller to turn off NFSv4.0 without
 turning off NFSv4.x
To: Trond Myklebust <trondmy@primarydata.com>
References: <20170224003344.113724-1-trond.myklebust@primarydata.com>
 <20170224003344.113724-2-trond.myklebust@primarydata.com>
 <1ec88fba-7bdb-ee59-e4cf-20970f45bd1d@RedHat.com>
 <1491337561.14806.1.camel@primarydata.com>
 <4d26d8f6-74af-9225-d98d-6e2c42a22e09@RedHat.com>
 <4B984CF4-7D50-4B11-B26E-886845068329@primarydata.com>
Cc: James Bruce Fields <bfields@fieldses.org>,
        "neilb@suse.com" <neilb@suse.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <4a409f78-9dfb-cfa4-67e7-6c67b8d263ac@RedHat.com>
Date: Tue, 4 Apr 2017 17:31:56 -0400
MIME-Version: 1.0
In-Reply-To: <4B984CF4-7D50-4B11-B26E-886845068329@primarydata.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/04/2017 05:11 PM, Trond Myklebust wrote:
> 
>> On Apr 4, 2017, at 17:07, Steve Dickson <SteveD@RedHat.com <mailto:SteveD@RedHat.com>> wrote:
>>
>>
>>
>> On 04/04/2017 04:26 PM, Trond Myklebust wrote:
>>> On Tue, 2017-04-04 at 16:07 -0400, Steve Dickson wrote:
>>>> Hey Trond,
>>>>
>>>> My apologies for taking so long to address this... 
>>>>
>>>> On 02/23/2017 07:33 PM, Trond Myklebust wrote:
>>>>> The new semantic is that '-N4' turns off all NFSv4 minor versions,
>>>>> while
>>>>> '-V4' turns them all on. In order to turn off just minor version x
>>>>> (x >= 0),
>>>>> use -N4.x, and to turn it back on. '-V4.x'.
>>>>>
>>>>> Note that on older kernels, attempting to use -N4.0 and -V4.0 is
>>>>> equivalent to specifying -N4 or -V4.
>>>>
>>>> doing a 
>>>>
>>>> nfsd -d -N4.0 -V4.1 -V4.2 
>>>> nfsd: Writing version string to kernel: -2 +3 -4 +4.1 +4.2
>>>>
>>>> does the right thing but when I do a
>>>>
>>>> nfsd -d -N4.0 
>>>> nfsd: Writing version string to kernel: -2 +3 -4
>>>>
>>>> It brings down all of the v4 minor versions, Is that
>>>> intentional? It seems to me doing a -N4.0 should only
>>>> stop 4.0 from coming up not v4.1 or v4.2
>>>
>>> That is unfortunately not possible for older kernels. They lack the
>>> kernel API to turn off NFSv4.0 only. We could perhaps try to return an
>>> error if you were to specify these flags for those kernels, but that
>>> would require us to hard-code a "minimal" kernel version in nfs-utils.
>> Well we already do that in the legacy mounting code to figure out
>> what mount version to use, but looking at that code it would be pain
>> to pull it out. 
>>
>> But I'm thinking the expectation of nfsd -N4.0 is to only 
>> turn off v4.0 and not work the same as -N4 which turns all of
>> v4 off which is expected. 
>>
>> When you say old kernel... How old?
> 
> Linux 4.10 or older.
So what will happen when this is done
    nfsd -d -N4.0 -V4.1 -V4.2
on an older kernel?

Also looking at the code when -N4.0 is used
it zero out the entire minorversset which means 
the -4.1 and -4.2 is not written out to the versions file

nfsd -d -N4
nfsd: Writing version string to kernel: -2 +3 -4 -4.1 -4.2

nfsd -d -N4.0
nfsd: Writing version string to kernel: -2 +3 -4

I'm not sure if this matters or not... but it is different.

steved.
