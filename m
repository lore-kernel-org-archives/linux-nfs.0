Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:32388 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754127Ab1FHUpR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2011 16:45:17 -0400
Subject: Re: [PATCH] nfs-utils:  Support binding to source address.
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4DEFC1DC.4050809@candelatech.com>
Date: Wed, 8 Jun 2011 16:45:05 -0400
Cc: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
Message-Id: <7E0EDB94-D658-407D-B096-531BA35F6726@oracle.com>
References: <1307554748-31757-1-git-send-email-greearb@candelatech.com> <20110608183608.GA3513@merit.edu> <4DEFC1DC.4050809@candelatech.com>
To: Ben Greear <greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jun 8, 2011, at 2:39 PM, Ben Greear wrote:

> On 06/08/2011 11:36 AM, Jim Rees wrote:
>> greearb@candelatech.com wrote:
>> 
>>   +	if (local_ip&&  local_ip->is_set) {
>>   +		sa = (struct sockaddr *)(char *)(&local_ip->addr);
>>   +		salen = local_ip->addrlen;
>>   +	} else {
>>   +		switch (family) {
>>   +		case AF_INET:
>>   +			sa = (struct sockaddr *)(char *)&sin;
>>   +			salen = sizeof(sin);
>>   +			break;
>>   +		case AF_INET6:
>>   +			sa = (struct sockaddr *)(char *)&sin6;
>>   +			salen = sizeof(sin6);
>>   +		default:
>>   +			break;
>>   +		}
>> 
>> Are the double casts actually necessary?  And if so, shouldn't the inner one
>> be (void *)?
> 
> They are not, as far as I know..I was copying some
> similar code I found elsewhere in nfs-utils.
> 
> Unless someone knows a reason to keep this, I'll just
> remove the inner cast.

Using (char *) tells the compiler to ignore pointer aliasing rules.

Instead, use "union nfs_sockaddr" where you can.  I'm not sure the double cast is needed for the latter two examples above.


-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




