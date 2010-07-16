Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:19152 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966004Ab0GPQ07 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Jul 2010 12:26:59 -0400
Message-ID: <4C40882A.2070203@oracle.com>
Date: Fri, 16 Jul 2010 12:26:18 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: Tom H <tom@limepepper.co.uk>
CC: linux-nfs@vger.kernel.org
Subject: Re: why do attempts to access a nfs v3 filesystem (ro,soft) block
 the process for minutes at a time? (when the nfs server is down)
References: <4C4078AE.5070300@limepepper.co.uk> <4C4079CC.8070205@oracle.com> <4C408470.1090709@limepepper.co.uk>
In-Reply-To: <4C408470.1090709@limepepper.co.uk>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/16/10 12:10 PM, Tom H wrote:
> Chuck Lever wrote:
>> On 07/16/2010 11:20 AM, Tom H wrote:
>>>
>>> (also I noticed that it seems to timeout quicker with the mount options
>>> set like (soft, timeo=7, retrans=3) which is unexpected, because they
>>> are supposed to be the default)
>>
>> They are the default settings for UDP mounts, but you didn't specify
>> UDP. TCP is the default transport protocol, and has been for some
>> time. TCP uses a long retransmit timeout. See nfs(5).
>>
> OK, I see that now. Thanks.!
>
> However further experimentation with mount options
> (ro,soft,retrans=0,timeo=0,intr,proto=tcp) - requests to a failed nfs
> file-system still block the apache process for some apparently random
> time up to 3 minutes.

I don't know exactly what retrans=0 and timeo=0 might do, but short 
timeouts over TCP are not recommended.  If you want it to fail sooner 
(and your network is clean enough), use proto=udp.
