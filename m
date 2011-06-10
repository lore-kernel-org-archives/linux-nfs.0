Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:37027 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754222Ab1FJWTN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 18:19:13 -0400
Message-ID: <4DF2985E.9010300@candelatech.com>
Date: Fri, 10 Jun 2011 15:19:10 -0700
From: Ben Greear <greearb@candelatech.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 3/6] nfs-utils:  Implement srcaddr binding in rpc_socket
References: <1307740096-19933-1-git-send-email-greearb@candelatech.com> <1307740096-19933-4-git-send-email-greearb@candelatech.com> <A2323BA3-3082-4416-A4C4-062726F15D6F@oracle.com>
In-Reply-To: <A2323BA3-3082-4416-A4C4-062726F15D6F@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/10/2011 03:06 PM, Chuck Lever wrote:
>
> On Jun 10, 2011, at 5:08 PM, greearb@candelatech.com wrote:
>
>> From: Ben Greear<greearb@candelatech.com>
>>
>> This implements the actual binding, if we are passed
>> a non-null local_ip structure.
>
> Why not _always_ pass a valid local_ip structure, and simply set .addr to an appropriate ANYADDR by default?  Then .is_set wouldn't be necessary, would it?  It would also simplify the logic in nfs_validate_options().

I like it as is because almost none of the new code is actually
used unless users pass in the srcaddr= option.  So, if I *did*
introduce any bugs, hopefully they would be limited to users
of the new option, and not a real regression.

Maybe after the srcaddr= code is used a bit I could go back and
do that cleanup.

But, I don't feel strongly about it, so if you think it's
worth the bother, I'll try changing the code as you suggest.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

