Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55823 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754856Ab1GNQVE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jul 2011 12:21:04 -0400
Message-ID: <4E1F1763.6090508@candelatech.com>
Date: Thu, 14 Jul 2011 09:20:51 -0700
From: Ben Greear <greearb@candelatech.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC] sunrpc:  Fix race between work-queue and rpc_killall_tasks.
References: <1309992581-25199-1-git-send-email-greearb@candelatech.com> <1309995932.5447.6.camel@lade.trondhjem.org> <4E173BE6.9000005@candelatech.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A198C7C@SACMVEXC2-PRD.hq.netapp.com> <4E177EA8.60109@candelatech.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A198E69@SACMVEXC2-PRD.hq.netapp.com> <4E1C8108.3020006@candelatech.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A295494@SACMVEXC2-PRD.hq.netapp.com> <4E1C84B2.2020807@candelatech.com>
In-Reply-To: <4E1C84B2.2020807@candelatech.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/12/2011 10:30 AM, Ben Greear wrote:
> On 07/12/2011 10:25 AM, Myklebust, Trond wrote:
>>> -----Original Message-----
>>> From: Ben Greear [mailto:greearb@candelatech.com]
>>> Sent: Tuesday, July 12, 2011 1:15 PM
>>> To: Myklebust, Trond
>>> Cc: linux-nfs@vger.kernel.org; linux-kernel@vger.kernel.org
>>> Subject: Re: [RFC] sunrpc: Fix race between work-queue and
>>> rpc_killall_tasks.
>>>

>>> I added lots of locking around the calldata, work-queue logic, and
>>> such, and
>>> still the problem persists w/out hitting any of the debug warnings or
>>> poisoned
>>> values I put in. It almost seems like tk_calldata is just assigned to
>>> two
>>> different tasks.
>>>
>>> While poking through the code, I noticed that 'map' is static in
>>> rpcb_getport_async.
>>>
>>> That would seem to cause problems if two threads called this method at
>>> the same time, possibly causing tk_calldata to be assigned to two
>>> different
>>> tasks???
>>>
>>> Any idea why it is static?
>>
>> Doh! That is clearly a typo dating all the way back to when Chuck
>> wrote that function.
>>
>> Yes, that would definitely explain your problem.
>
> Ok, patch sent. I assume someone will propagate this to stable
> as desired?
>
> And assuming this fixes it, can I get some brownie points towards
> review of the ip-addr binding patches? :)

Just to close this issue:  We ran a clean 24+ hour test mounting and
unmounting 200 mounts every 30 seconds, and it ran with zero problems.

This was with 2.6.38.8+ with this fix applied.

3.0-rc7+ is still flaky in various other ways, but I see no more
NFS problems at least.

So, that was the problem I was hitting, and it appears to be the
last problem in this area.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

