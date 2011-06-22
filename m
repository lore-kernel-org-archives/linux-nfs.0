Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27466 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758596Ab1FVS54 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jun 2011 14:57:56 -0400
Message-ID: <4E023B30.4030507@RedHat.com>
Date: Wed, 22 Jun 2011 14:57:52 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Ben Greear <greearb@candelatech.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 0/6] nfs-utils:  Support binding to source address.
References: <1308000408-13690-1-git-send-email-greearb@candelatech.com> <4DFF8604.1050508@candelatech.com> <4E01FC5B.1000509@RedHat.com> <4E020205.1000308@candelatech.com>
In-Reply-To: <4E020205.1000308@candelatech.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 06/22/2011 10:53 AM, Ben Greear wrote:
> On 06/22/2011 07:29 AM, Steve Dickson wrote:
>> Sorry for the delay.. I was traveling last week..
>>
>> On 06/20/2011 01:40 PM, Ben Greear wrote:
>>> On 06/13/2011 02:26 PM, greearb@candelatech.com wrote:
>>>> From: Ben Greear<greearb@candelatech.com>
>>>>
>>>> This lets one specify the source IP address for
>>>> sockets, allowing users to leverage routing rules
>>>> on multi-homed systems.
>>>>
>>>> Kernel patches to RPC and NFS are needed to complete
>>>> full functionality.
>>>
>>> Any feedback on this?  Good enough for inclusion upstream?
>> Question, are there kernel patches needed to complete this work?
>>
>> steved.
> 
> Yes, posted a week or two ago as RFC:
> 
> http://www.spinics.net/lists/linux-nfs/msg21802.html
Fair enough... When that kernel code hit's Trond tree, I'll
make sure the mount command will be able to use it.. 

steved.
