Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:42235 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758276Ab1FWQFx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jun 2011 12:05:53 -0400
Message-ID: <4E03645C.5080503@candelatech.com>
Date: Thu, 23 Jun 2011 09:05:48 -0700
From: Ben Greear <greearb@candelatech.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/11] NFS: Support binding to source address
References: <1308778611-9370-1-git-send-email-greearb@candelatech.com> <F37E8424-9A40-4C4F-A2F6-431FDA831E0D@oracle.com> <4E035BED.3040105@candelatech.com> <C4E3B7E9-47D7-4A93-B88F-0021D0450ACC@oracle.com>
In-Reply-To: <C4E3B7E9-47D7-4A93-B88F-0021D0450ACC@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/23/2011 08:46 AM, Chuck Lever wrote:
> Hi Ben-
>
> On Jun 23, 2011, at 9:29 AM, Ben Greear wrote:
>
>> On 06/23/2011 07:59 AM, Chuck Lever wrote:
>>>
>>> On Jun 22, 2011, at 3:36 PM, greearb@candelatech.com wrote:
>>>
>>>> From: Ben Greear<greearb@candelatech.com>
>>>>
>>>> This lets one specify the source IP address for
>>>> sockets, allowing users to leverage routing rules
>>>> on multi-homed systems.
>>>
>>> Do you need changes to send NLM requests from the right source address?
>>
>> Not for my testing so far...but maybe I'm not utilizing whatever NLM
>> does.  What sort of things would require/use it?
>
> File locking.  NLM support should be a requirement for a complete implementation of srcaddr=, IMO.

Ok, I think I have some patches for this already, but didn't re-add them when
breaking up the big patch for submission.  I'll set up a test case with
file locking and double-check that I have it working correctly.

Thanks,
Ben

>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
