Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:56750 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751727AbeFEQNC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jun 2018 12:13:02 -0400
Subject: Re: [PATCH v2 1/1] Add check of clientaddr argument
To: Olga Kornievskaia <aglo@umich.edu>
References: <20180605155127.27429-1-kolga@netapp.com>
 <357ddb57-158d-f1ae-69db-88f398b734bb@candelatech.com>
 <CAN-5tyEB+VcENhOzVZBO5=s8zV5YEun1u_W6m4AM5WXPF_mfvA@mail.gmail.com>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Steve Dickson <steved@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
From: Ben Greear <greearb@candelatech.com>
Message-ID: <c0fde87c-310a-7d64-08f9-aba0a4e4565b@candelatech.com>
Date: Tue, 5 Jun 2018 09:12:59 -0700
MIME-Version: 1.0
In-Reply-To: <CAN-5tyEB+VcENhOzVZBO5=s8zV5YEun1u_W6m4AM5WXPF_mfvA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/05/2018 09:05 AM, Olga Kornievskaia wrote:
> On Tue, Jun 5, 2018 at 11:53 AM, Ben Greear <greearb@candelatech.com> wrote:
>> On 06/05/2018 08:51 AM, Olga Kornievskaia wrote:
>>>
>>> If the user supplies a clientaddr value, it should be either
>>> a special value of either IPv4/IPv6 any address or one of the
>>> machine's network addresses. Otherwise, the use of an arbitrary
>>> value of the clientaddr value is not allowed.
>>
>>
>> Is this finally going to let one bind to a local IP address?
>
> No this patch only checks for the validity of the arguments for the
> callback channel.
>
>> I have patches to do this for years now, would love to get that
>> feature upstream!
>
> Have you posted those patches to the mailing list?

Yes, several times, years ago.

https://www.spinics.net/lists/linux-nfs/msg34811.html

My current trees are here, and the NFS patches are near the bottom of my
patch set.  I am not sure we specifically tested this with 4.16 kernel yet, but
we tested it on the 4.13 kernel:

https://github.com/greearb?tab=repositories

The nfs-utils-ct repo has the patches to make nfs-utils support this.

If you or anyone else would like to shepherd these into the kernel
it would be appreciated.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

