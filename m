Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:39703 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750943Ab1FHSj1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2011 14:39:27 -0400
Message-ID: <4DEFC1DC.4050809@candelatech.com>
Date: Wed, 08 Jun 2011 11:39:24 -0700
From: Ben Greear <greearb@candelatech.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils:  Support binding to source address.
References: <1307554748-31757-1-git-send-email-greearb@candelatech.com> <20110608183608.GA3513@merit.edu>
In-Reply-To: <20110608183608.GA3513@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/08/2011 11:36 AM, Jim Rees wrote:
> greearb@candelatech.com wrote:
>
>    +	if (local_ip&&  local_ip->is_set) {
>    +		sa = (struct sockaddr *)(char *)(&local_ip->addr);
>    +		salen = local_ip->addrlen;
>    +	} else {
>    +		switch (family) {
>    +		case AF_INET:
>    +			sa = (struct sockaddr *)(char *)&sin;
>    +			salen = sizeof(sin);
>    +			break;
>    +		case AF_INET6:
>    +			sa = (struct sockaddr *)(char *)&sin6;
>    +			salen = sizeof(sin6);
>    +		default:
>    +			break;
>    +		}
>
> Are the double casts actually necessary?  And if so, shouldn't the inner one
> be (void *)?

They are not, as far as I know..I was copying some
similar code I found elsewhere in nfs-utils.

Unless someone knows a reason to keep this, I'll just
remove the inner cast.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

