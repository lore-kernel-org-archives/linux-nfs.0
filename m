Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:45982 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757794Ab1FJSk2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 14:40:28 -0400
Message-ID: <4DF26519.2030507@candelatech.com>
Date: Fri, 10 Jun 2011 11:40:25 -0700
From: Ben Greear <greearb@candelatech.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/7] nfs-utils:  Implement srcaddr binding in network.c
References: <1307729379-7702-1-git-send-email-greearb@candelatech.com> <1307729379-7702-5-git-send-email-greearb@candelatech.com> <7BC92EC0-31CE-4A5D-85F8-E409E812A819@oracle.com>
In-Reply-To: <7BC92EC0-31CE-4A5D-85F8-E409E812A819@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/10/2011 11:29 AM, Chuck Lever wrote:
>
> On Jun 10, 2011, at 2:09 PM, greearb@candelatech.com wrote:
>
>> From: Ben Greear<greearb@candelatech.com>
>>
>> Implement binding logic in get_socket() if local_ip
>> argument is not NULL.
>>
>> Note that this method had issues with supporting IPv6 before
>> this patch, and this patch does NOT resolve them.
>
> If get_socket() doesn't support IPv6, then I doubt it's used for string-based mounts.  You may not need any changes here.

Looks like you are correct.  I added printf to that method and
see nothing while doing mount/unmount.  I'll respin the patches
to remove that...should make things a good bit smaller.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

