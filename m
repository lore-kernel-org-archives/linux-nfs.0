Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:36080 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753516AbdAZVU3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2017 16:20:29 -0500
Received: by mail-io0-f170.google.com with SMTP id j13so47000805iod.3
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jan 2017 13:20:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1485464316.3367.3.camel@primarydata.com>
References: <CAN-5tyEo-VS6y1-WVJMDXSzN2vxDtJOSckiYK=HmqLyPvBpWFQ@mail.gmail.com>
 <1485464316.3367.3.camel@primarydata.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 26 Jan 2017 16:20:18 -0500
Message-ID: <CAN-5tyEbG6mA0HNdEQF+OkR7j3__VFce9=KLGy9sGDxG-fTO9w@mail.gmail.com>
Subject: Re: regression from commit 24408f5282
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 26, 2017 at 3:58 PM, Trond Myklebust
<trondmy@primarydata.com> wrote:
> On Thu, 2017-01-26 at 15:01 -0500, Olga Kornievskaia wrote:
>> Hi Trond,
>>
>> There is regression in the upstream code, it leaves dangling DS
>> mounts. Problem didn't exist in 4.9 and appeared in 4.10.
>>
>> Simple test is : mount, echo 1 > /mnt/foobar, unmount /mnt. Watch the
>> DS mount keep going.
>>
>> The last commit at which the code works is: fe1cf9469d7 "pNFS: Clear
>> all layout segment state in pnfs_mark_layout_stateaid_invalid".
>>
>> Applying commit 24408f5282 "pNFS: Fix bugs in _pnfs_return_layout"
>> introduces the problem.
>>
>> From what I can tell the code is either missing setting
>> NFS_LAYOUT_RETURN_REQUESTED somewhere but I'm not sure.
>>
>> Or if the intent was to just never return the layout even on the
>> unmount, then we need to drop the ref count on the layout here so
>> that
>> unmount can proceed.
>>
>> Can you clarify what should be happening here (or maybe something
>> else
>> entirely)?
>>
>
> Does the patch I just sent you fix the regression?

Yes! that fixes the problem. Thank you.

>
> Cheers,
>   Trond
>
> --
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
