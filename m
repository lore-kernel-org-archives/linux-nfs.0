From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/5] Support IPv6 in libexport.a
Date: Tue, 31 Aug 2010 16:36:37 -0400
Message-ID: <2F44C575-10D5-4B34-B4D1-038F318E9867@oracle.com>
References: <20100824162926.2433.7535.stgit@matisse.1015granger.net> <4C7D5B63.9060907@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:50750 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755482Ab0HaUik convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Aug 2010 16:38:40 -0400
In-Reply-To: <4C7D5B63.9060907-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 31, 2010, at 3:43 PM, Steve Dickson wrote:

> 
> 
> On 08/24/2010 12:35 PM, Chuck Lever wrote:
>> Hi Steve-
>> 
>> This patch set should encapsulate IPv6-related changes needed in
>> support/export/client.c .  It updates logic that parses presentation
>> addresses and netmasks, and logic that compares socket addresses.
>> 
>> ---
>> 
>> Chuck Lever (5):
>>      libexport.a: IPv6 support in client_check()
>>      libexport.a: IPv6 support for client_init_subnet()
>>      libexport.a: Prepare init_subnetwork() for IPv6 support
>>      libexport.a: Use host helper to parse address in client_init()
>>      libexport.a: Prepare to recognize IPv6 addresses in client_gettype()
>> 
>> 
>> support/export/client.c |  208 +++++++++++++++++++++++++++++++++++------------
>> 1 files changed, 153 insertions(+), 55 deletions(-)
>> 
> All 5 Committed...

Thanks.  Can you push these to your repo on linux-nfs.org?

> As far as "bending the cardinal rule of not
> using "#ifdef" inside functions"... I too did not see a cleaner
> way of doing it... so I don't think its a big deal.. but maybe
> down the road we can rework things where those ifdef are not
> needed... but only time will tell...
> 
> steved.

-- 
chuck[dot]lever[at]oracle[dot]com




