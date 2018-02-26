Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35968 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753299AbeBZOHQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 26 Feb 2018 09:07:16 -0500
Subject: Re: [PATCH 1/1] NFS guard against incorrect vers inputs from
 nfs-utils
To: Olga Kornievskaia <aglo@umich.edu>,
        Trond Myklebust <trondmy@primarydata.com>
Cc: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "kolga@netapp.com" <kolga@netapp.com>
References: <20180222192806.67911-1-kolga@netapp.com>
 <034fb5f1-eba5-030b-aad2-6ac5e87f2066@RedHat.com>
 <CAN-5tyE2wqrgkQuHSFy7=EDricmx6jPKA9=PnqSdf8rr_0rxwQ@mail.gmail.com>
 <6e314995-964f-e70d-cc45-fc1716b4ec81@RedHat.com>
 <1519412975.8738.3.camel@primarydata.com>
 <CAN-5tyHzWrC7FVzCj+bSdvQFdN=5+1f750u1wWMs=2jub6y5-w@mail.gmail.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <aa18c5d2-efc6-eb79-1ee5-966e69c84d29@RedHat.com>
Date: Mon, 26 Feb 2018 09:07:14 -0500
MIME-Version: 1.0
In-Reply-To: <CAN-5tyHzWrC7FVzCj+bSdvQFdN=5+1f750u1wWMs=2jub6y5-w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/23/2018 02:28 PM, Olga Kornievskaia wrote:
> On Fri, Feb 23, 2018 at 2:09 PM, Trond Myklebust
> <trondmy@primarydata.com> wrote:
>> On Fri, 2018-02-23 at 13:45 -0500, Steve Dickson wrote:
>>>
>>> On 02/23/2018 12:05 PM, Olga Kornievskaia wrote:
>>>> On Fri, Feb 23, 2018 at 11:24 AM, Steve Dickson <SteveD@redhat.com>
>>>> wrote:
>>>>> Hey Olga,
>>>>>
>>>>> On 02/22/2018 02:28 PM, Olga Kornievskaia wrote:
>>>>>> It is possible that userland can pass to the kernel mismatching
>>>>>> inputs for the minorversion. like vers=4.1,minorversion=0.
>>>>>> Instead
>>>>>> of making the kernel responposible for 'choosing' the
>>>>>> minorversion,
>>>>>> make the userland always responsible for not sending a
>>>>>> mismatch.
>>>>>
>>>>> I'm thinking this is probably more of mount problem...
>>>>
>>>> Yes the problem is a broken user land sending incorrect arguments
>>>> but
>>>> I still think the kernel needs to do sanity checking on arguments
>>>> to
>>>> prevent this from happening again.
>>>>
>>>>> mount -t nfs4 -o minorversion=0 server:/export /mnt
>>>>>
>>>>> shouldn't this be a  v4.0 mount instead of a 4.2 mount?
>>>>
>>>> Yes I would think this should create a v4.0 mount.
>>>
>>> Way back when... there was some talk about deprecating
>>> minorversion= flag... Since it is broken, maybe this is
>>> a good time to do it?
>>>
>>> Thoughts?
>>
>> I've never liked the separate v4-only 'minorversion' keyword, which is
>> why I introduced the 'version=4.x' format. My preference is therefore
>> that we continue to deprecate use of 'minorversion' with a view to
>> killing it off completely.
> 
> It all seems like a good idea except I wonder how widely used and
> relied on "minorversion" option is. Steve you might have a good idea
> about it.
I have no idea... Actually I'm not sure how to deprecate a mount
option... I don't think that has every happen before... But 
I'm sure it will break something! ;-) 

steved.

> 
>>
>> --
>> Trond Myklebust
>> Linux NFS client maintainer, PrimaryData
>> trond.myklebust@primarydata.com
