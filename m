Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:39243 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754384AbcIPXbz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Sep 2016 19:31:55 -0400
Subject: Re: nfs broken on Fedora-24, 32-bit?
To: Trond Myklebust <trondmy@primarydata.com>
References: <de68a5b5-fa21-1ca4-68e9-feeea009e6d3@candelatech.com>
 <DE7D6150-4E55-4940-8BD8-3FF2484E3313@primarydata.com>
 <1a99ef05-d1f2-8d3d-6dca-3a81728708ef@candelatech.com>
Cc: List Linux NFS Mailing <linux-nfs@vger.kernel.org>
From: Ben Greear <greearb@candelatech.com>
Message-ID: <08ad07ee-72e2-b478-d70d-87b08c24452f@candelatech.com>
Date: Fri, 16 Sep 2016 16:31:51 -0700
MIME-Version: 1.0
In-Reply-To: <1a99ef05-d1f2-8d3d-6dca-3a81728708ef@candelatech.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/15/2016 04:06 PM, Ben Greear wrote:
> On 09/15/2016 04:00 PM, Trond Myklebust wrote:
>> Hi Ben,
>>
>>> On Sep 15, 2016, at 18:32, Ben Greear <greearb@candelatech.com> wrote:
>>>
>>> I have a Fedora-24 machine mounting an NFS server running Fedora-13 (kernel 2.6.34.9-69.fc13.x86_64).
>>>
>>> F24 machine has this in /etc/fstab:
>>>
>>> 192.168.100.3:/mnt/d2 /mnt/d2                   nfs     nfsvers=3       0 0
>>>
>>> When I copy a file from f24-32 to the F-13 machine, the file size is the same,
>>> but the file is corrupted on the file server.  I see a different md5sum each time.
>>>
>>> Various other systems (F21, F19, etc) can all copy to the F13 machine fine.
>>>
>>> And, F24-64 machine can copy to the F13 machine fine.
>>>
>>> Anyone seen something similar?
>>
>> Do you know if the corruption is happening on the read()s or on the write()s? Do you, for instance get the same corruption if you copy from a local file on
>> the F-24 client to the server? ..or if you copy from a file on the server to a local directory on the F-24 client?
>>
>> Cheers
>>   Trond
>>
>
> Seems to be a write issue:
>
> # This is the nfs server:
>
> [greearb@fs3 candela_cdrom.5.3.5]$ md5sum gua-f21-32
> ad4073fa8b806bb82b85a645e21f5e67  gua-f21-32
> [greearb@fs3 candela_cdrom.5.3.5]$ md5sum ../greearb/tmp/gua-f21-32
> 582bfea0cc8cc52aa38dc0f5048d0156  ../greearb/tmp/gua-f21-32
> [greearb@fs3 candela_cdrom.5.3.5]$
>
>
> # This is the v-f24-32 client:
>
> greearb@v-f24-32 ~]$ cp /mnt/d2/pub/candela_cdrom.5.3.5/gua-f21-32 ./
> [greearb@v-f24-32 ~]$ md5sum gua-f21-32
> ad4073fa8b806bb82b85a645e21f5e67  gua-f21-32
> [greearb@v-f24-32 ~]$ cp gua-f21-32 /mnt/d2/pub/greearb/tmp/
> [greearb@v-f24-32 ~]$ md5sum /mnt/d2/pub/greearb/tmp/gua-f21-32
> ad4073fa8b806bb82b85a645e21f5e67  /mnt/d2/pub/greearb/tmp/gua-f21-32
>
>
> Interesting that the client reads back the file it copied over as if it were correct, but
> it shows up wrong on the nfs server.  Maybe it is just reading a local cache?
>
> Thanks,
> Ben
>

Here is some more info on this:

We can only reproduce this on virtual machines using the KVM infrastructure, and only
when we use the rtl8139 virtual hardware (in bridge mode).  With the e1000 virtual hardware
we cannot reproduce the problem.

Also, multiple different nfs servers (including much newer kernels) all show the same
behaviour with this broken nfs client.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

