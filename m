Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:59547 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101AbZIXSGj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Sep 2009 14:06:39 -0400
Message-ID: <4ABBB531.2050103@candelatech.com>
Date: Thu, 24 Sep 2009 11:06:41 -0700
From: Ben Greear <greearb@candelatech.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Some NFS performance numbers for 2.6.31
References: <4AB96F06.5040703@candelatech.com> <4ABAB3C5.9060808@candelatech.com> <20090924175439.GA10385@fieldses.org>
In-Reply-To: <20090924175439.GA10385@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/24/2009 10:54 AM, J. Bruce Fields wrote:
> On Wed, Sep 23, 2009 at 04:48:21PM -0700, Ben Greear wrote:
>> On 09/22/2009 05:42 PM, Ben Greear wrote:
>>> I'm running some performance tests on NFSv3 on a slightly hacked 2.6.31
>>> kernel.
>>
>> I realized that LRO on the NICs was disabled because I had enabled ip-forwarding.
>>
>> I re-enabled that, and now can get about 18Gbps read rates (on the wires), using MTU
>> 1500.
>
> On a 10 gig nic?  (Oh, sorry, I see: 2 10 gig nics.  OK!)  Just out of
> curiosity: have you done any testing with real drives?  Which kernel is
> this?

I see similar performance on real drivers, but I haven't done any tests with *only*
using physical drivers.  Since that would exercise only a single mount, I'm
not sure if it would scale as well as using multiple mounts with multiple
virtual interfaces, but that is just pure hypothesizing on my part.

This is 2.6.31 kernel, 64-bit, most kernel related debugging disabled.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

