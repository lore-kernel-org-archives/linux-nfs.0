Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:60860 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758227Ab3JQSfE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 14:35:04 -0400
Message-ID: <52602DD7.6050708@candelatech.com>
Date: Thu, 17 Oct 2013 11:35:03 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: 'umount -f /mnt/foo' fails if server IP is gone.
References: <525D899F.5010604@candelatech.com>   <52601FED.6070708@candelatech.com>  <1382033137.3216.3.camel@leira.trondhjem.org>  <52602835.4000701@candelatech.com> <1382034747.3216.8.camel@leira.trondhjem.org>
In-Reply-To: <1382034747.3216.8.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=UTF-7
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/17/2013 11:32 AM, Myklebust, Trond wrote:
> On Thu, 2013-10-17 at 11:11 -0700, Ben Greear wrote:
>> On 10/17/2013 11:05 AM, Myklebust, Trond wrote:
>>> On Thu, 2013-10-17 at 10:35 -0700, Ben Greear wrote:
>>>> On 10/15/2013 11:29 AM, Ben Greear wrote:
>>>>> Is 'umount -f' supposed to always work, even if the file server
>>>>> goes away?
>>>>>
>>>>> I have a user's system that just hangs forever in this case.
>>>>>
>>>>> Could be local changes we have made, but I'm curious about
>>>>> the expected behaviour before I go digging too deep...
>>>>
>>>> Any input on this?  I don't mind trying to fix it, but I
>>>> would like to know how it is supposed to work.
>>>
>>> 'umount -f' has always been iffy. It just kills any pending RPC calls
>>> _before_ trying to unmount. Since the unmount itself can trigger
>>> writeback flushes (and hence more RPC calls), the trace you are seeing
>>> is indeed possible.
>>
>> I tried 'umount -f -l', and that also does not work.
>>
>> Any ideas on how to fix this properly?
> 
> 'umount -f -l' should normally work to at least hide the gruesome
> details of your hanging superblock.
> 
> I'm guessing that you're falling afoul of the path revalidation that
> Chuck alluded to. There should already be a fix for that problem with
> the path_umountat() patches that went into Linux 3.12-rc1. Are those
> failing to help?

I have not tried past 3.9.11+ kernel yet.  I will go look for those patches
you mention as well.  Did any of this go to -stable by chance?

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

