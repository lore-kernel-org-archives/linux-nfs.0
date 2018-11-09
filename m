Return-Path: <SRS0=AoDj=NU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E213C43441
	for <linux-nfs@archiver.kernel.org>; Fri,  9 Nov 2018 14:48:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3E14620883
	for <linux-nfs@archiver.kernel.org>; Fri,  9 Nov 2018 14:48:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E14620883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=candelatech.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727784AbeKJA3p (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 9 Nov 2018 19:29:45 -0500
Received: from mail2.candelatech.com ([208.74.158.173]:53958 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727735AbeKJA3p (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Nov 2018 19:29:45 -0500
Received: from [192.168.1.47] (unknown [50.34.223.145])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail2.candelatech.com (Postfix) with ESMTPSA id 38EAE40A626;
        Fri,  9 Nov 2018 06:48:43 -0800 (PST)
Subject: Re: Support for VRF in NFS?
To:     Steven Whitehouse <swhiteho@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
References: <b608aeda-358d-18c9-ebcd-753b698580e9@candelatech.com>
 <20181108011429.GC30776@fieldses.org>
 <efe334ad-4905-fc24-1b36-3c4129b72888@candelatech.com>
 <20181108153136.GA4947@fieldses.org>
 <90f8e9ba-3953-e2d1-56f4-421a4991cef8@candelatech.com>
 <74f0a2e8-f631-8d8d-5b98-8248dadf5aa6@redhat.com>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        David Windsor <dwindsor@redhat.com>
From:   Ben Greear <greearb@candelatech.com>
Message-ID: <d0a3a3fd-4952-db37-4ca7-54391edc3c48@candelatech.com>
Date:   Fri, 9 Nov 2018 06:48:41 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101
 Thunderbird/45.8.0
MIME-Version: 1.0
In-Reply-To: <74f0a2e8-f631-8d8d-5b98-8248dadf5aa6@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 11/09/2018 01:59 AM, Steven Whitehouse wrote:
> Hi,
>
>
> On 08/11/18 16:35, Ben Greear wrote:
>>
>>
>> On 11/08/2018 07:31 AM, J. Bruce Fields wrote:
>>> On Wed, Nov 07, 2018 at 09:08:16PM -0800, Ben Greear wrote:
>>>>
>>>>
>>>> On 11/07/2018 05:14 PM, J. Bruce Fields wrote:
>>>>> On Tue, Nov 06, 2018 at 01:03:54PM -0800, Ben Greear wrote:
>>>>>> Hello,
>>>>>>
>>>>>> I made a stab at implementing VRF support in NFS, but it appears
>>>>>> fairly complicated and I ended up reverting my changes....
>>>>>>
>>>>>> Is anyone working on this?
>>>>>>
>>>>>> And, if not, if anyone would like to be sponsored to work on this, please
>>>>>> let me know.
>>>>>
>>>>> Um, sorry--what's VRF?
>>>>
>>>> Virtual Router logic.  It is sort of like network stack containers,
>>>> and has been solid and fully featured in the kernel since 4.16 or so.
>>>>
>>>> In the end, you effectively need to call the logic that SO_BINDTODEVICE
>>>> calls on the socket before binding to an IP.
>>>>
>>>> The NFS and RPC logic is a giant tangled mess to my eyes, so
>>>> hoping I could bribe someone else to do it :)
>>>
>>> So it's not enough to support network namespaces?
>>>
>>> What's your motivation for this?
>>
>> Network namespaces are difficult to uses for lots of use cases, and thus VRF
>> was born.
>>
>> My own motivation is that it allows me to make hundreds or thousands
>> of individual NFS mounts from local mac-vlan (or other virtual/physical interfaces),
>> for testing purposes.
>>
>> Similar to my patch set that binds to local IP address, which gives similar feature
>> set for non-VRF configurations.  These bind-local-IP patches are not upstream and were rejected in
>> the past as un-wanted.  I'm hoping VRF support would be more acceptable.
>>
>> Thanks,
>> Ben
>>
>
> For similar reasons David Windsor has been looking at some extensions for DLM along these lines. Improving our ability to test seems to me like it should be a good thing to do - in both cases. Likewise VRF support seems also like it should be useful in a number of contexts.
>
> Do you have a reference to your past work? I think it would be interesting to get some discussion going here - maybe it would be possible to have some common approach between kernel-side socket users, and/or bounce some ideas around,
>
> Steve.

Here is an old thread on the topic.

https://www.spinics.net/lists/linux-nfs/msg34811.html

My patches are in all my 'ct' kernels, and the needed patches are also in my nfs-utils repo.

My 4.19 tree has just been ported, so no idea if it works or not.

https://github.com/greearb?tab=repositories

My patch work fine using routing table rules without VRF, but they will not work with VRF.


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
