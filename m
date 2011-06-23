Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:38431 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759608Ab1FWP3x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jun 2011 11:29:53 -0400
Message-ID: <4E035BED.3040105@candelatech.com>
Date: Thu, 23 Jun 2011 08:29:49 -0700
From: Ben Greear <greearb@candelatech.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/11] NFS: Support binding to source address
References: <1308778611-9370-1-git-send-email-greearb@candelatech.com> <F37E8424-9A40-4C4F-A2F6-431FDA831E0D@oracle.com>
In-Reply-To: <F37E8424-9A40-4C4F-A2F6-431FDA831E0D@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/23/2011 07:59 AM, Chuck Lever wrote:
>
> On Jun 22, 2011, at 3:36 PM, greearb@candelatech.com wrote:
>
>> From: Ben Greear<greearb@candelatech.com>
>>
>> This lets one specify the source IP address for
>> sockets, allowing users to leverage routing rules
>> on multi-homed systems.
>
> Do you need changes to send NLM requests from the right source address?

Not for my testing so far...but maybe I'm not utilizing whatever NLM
does.  What sort of things would require/use it?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
