Return-Path: <SRS0=AoDj=NU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D47A5C43441
	for <linux-nfs@archiver.kernel.org>; Fri,  9 Nov 2018 09:59:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8480F20855
	for <linux-nfs@archiver.kernel.org>; Fri,  9 Nov 2018 09:59:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8480F20855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727781AbeKITi5 convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 9 Nov 2018 14:38:57 -0500
Received: from mx1.redhat.com ([209.132.183.28]:51268 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727532AbeKITi5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Nov 2018 14:38:57 -0500
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 3ADA1C067C37;
        Fri,  9 Nov 2018 09:59:07 +0000 (UTC)
Received: from 117.195.187.81.in-addr.arpa (unknown [10.33.36.27])
        by smtp.corp.redhat.com (Postfix) with ESMTP id D47E7601A2;
        Fri,  9 Nov 2018 09:59:05 +0000 (UTC)
Subject: Re: Support for VRF in NFS?
To:     Ben Greear <greearb@candelatech.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        David Windsor <dwindsor@redhat.com>
References: <b608aeda-358d-18c9-ebcd-753b698580e9@candelatech.com>
 <20181108011429.GC30776@fieldses.org>
 <efe334ad-4905-fc24-1b36-3c4129b72888@candelatech.com>
 <20181108153136.GA4947@fieldses.org>
 <90f8e9ba-3953-e2d1-56f4-421a4991cef8@candelatech.com>
From:   Steven Whitehouse <swhiteho@redhat.com>
Message-ID: <74f0a2e8-f631-8d8d-5b98-8248dadf5aa6@redhat.com>
Date:   Fri, 9 Nov 2018 09:59:04 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.5.2
MIME-Version: 1.0
In-Reply-To: <90f8e9ba-3953-e2d1-56f4-421a4991cef8@candelatech.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8BIT
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Fri, 09 Nov 2018 09:59:07 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi,


On 08/11/18 16:35, Ben Greear wrote:
>
>
> On 11/08/2018 07:31 AM, J. Bruce Fields wrote:
>> On Wed, Nov 07, 2018 at 09:08:16PM -0800, Ben Greear wrote:
>>>
>>>
>>> On 11/07/2018 05:14 PM, J. Bruce Fields wrote:
>>>> On Tue, Nov 06, 2018 at 01:03:54PM -0800, Ben Greear wrote:
>>>>> Hello,
>>>>>
>>>>> I made a stab at implementing VRF support in NFS, but it appears
>>>>> fairly complicated and I ended up reverting my changes....
>>>>>
>>>>> Is anyone working on this?
>>>>>
>>>>> And, if not, if anyone would like to be sponsored to work on this, 
>>>>> please
>>>>> let me know.
>>>>
>>>> Um, sorry--what's VRF?
>>>
>>> Virtual Router logic.  It is sort of like network stack containers,
>>> and has been solid and fully featured in the kernel since 4.16 or so.
>>>
>>> In the end, you effectively need to call the logic that SO_BINDTODEVICE
>>> calls on the socket before binding to an IP.
>>>
>>> The NFS and RPC logic is a giant tangled mess to my eyes, so
>>> hoping I could bribe someone else to do it :)
>>
>> So it's not enough to support network namespaces?
>>
>> What's your motivation for this?
>
> Network namespaces are difficult to uses for lots of use cases, and 
> thus VRF
> was born.
>
> My own motivation is that it allows me to make hundreds or thousands
> of individual NFS mounts from local mac-vlan (or other 
> virtual/physical interfaces),
> for testing purposes.
>
> Similar to my patch set that binds to local IP address, which gives 
> similar feature
> set for non-VRF configurations.  These bind-local-IP patches are not 
> upstream and were rejected in
> the past as un-wanted.  I'm hoping VRF support would be more acceptable.
>
> Thanks,
> Ben
>

For similar reasons David Windsor has been looking at some extensions 
for DLM along these lines. Improving our ability to test seems to me 
like it should be a good thing to do - in both cases. Likewise VRF 
support seems also like it should be useful in a number of contexts.

Do you have a reference to your past work? I think it would be 
interesting to get some discussion going here - maybe it would be 
possible to have some common approach between kernel-side socket users, 
and/or bounce some ideas around,

Steve.


