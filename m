From: Ben Greear <greearb@candelatech.com>
Subject: Re: Possible bug in nfs-utils source.
Date: Wed, 21 Jan 2009 14:53:36 -0800
Message-ID: <4977A770.90507@candelatech.com>
References: <4977A0EC.3050103@candelatech.com> <2055BE67-5060-4D4E-BB0A-A8E61152A2EC@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35973 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753598AbZAUWxk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jan 2009 17:53:40 -0500
In-Reply-To: <2055BE67-5060-4D4E-BB0A-A8E61152A2EC@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> On Jan 21, 2009, at Jan 21, 2009, 5:25 PM, Ben Greear wrote:
>> I'm working on adding support to bind to local addresses, and
>> I noticed this code in nfs/getport.c
>>
>> I believe the sizeof should probably be sizeof(*lb_addr) ?
> 
> Yes.  Can you submit a patch to Steve and copy the list?

Sure, but will be a bit...I'm half through passing local_address
everywhere so I can bind to local IP addresses explicitly on
multi-homed devices....

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

