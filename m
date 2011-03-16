Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from milhouse.imppc.org ([213.151.98.37]:29639 "EHLO
	milhouse.imppc.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116Ab1CPLpg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Mar 2011 07:45:36 -0400
Message-ID: <4D80A2DE.2030507@imppc.org>
Date: Wed, 16 Mar 2011 12:45:34 +0100
From: Judith Flo Gaya <jflo@imppc.org>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: problem with nfs latency during high IO
References: <4D7B6DE5.8010008@imppc.org> <526EE4AA-ABD2-4452-9C3A-C000BD3CFC60@oracle.com> <4D7FA11F.5020604@imppc.org> <21A84B17-E061-4441-9181-100AC8E473E2@oracle.com> <4D7FDB14.6090908@imppc.org> <9CC4990D-6969-4788-8B52-BA5AF2743DE3@oracle.com> <4D7FE0E8.5050701@imppc.org> <16BF52F0-4D1A-4B68-ADEE-DC70255A139C@oracle.com>
In-Reply-To: <16BF52F0-4D1A-4B68-ADEE-DC70255A139C@oracle.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello Chuck,

On 03/15/2011 11:10 PM, Chuck Lever wrote:
>
> On Mar 15, 2011, at 5:58 PM, Judith Flo Gaya wrote:
>
>>
>> I saw that the value was 20, I don't know the impact of changing the number by units or tens... Should I test with 10 or this is too much? I assume that the behavior will change immediately right?
>
> I believe the dirty ratio is the percentage of physical memory that can be consumed by one file's dirty data before the VM starts flushing its pages asynchronously.  Or it could be the amount of dirty data allowed across all files... one file or many doesn't make any difference if you are writing a single very large file.
>
> If your client memory is large, a small number should work without problem.  One percent of a 16GB client is still quite a bit of memory.  The current setting means you can have 20% of said 16GB client, or 3.2GB, of dirty file data on that client before it will even think about flushing it.  Along comes "ls -l" and you will have to wait for the client to flush 3.2GB before it can send the GETATTR.
>
> I believe this setting does take effect immediately, but you will have to put the setting in /etc/sysctl.conf to make it last across a reboot.
>

I made some tests with a value of 10 for the vm_dirty_ratio and indeed 
the ls-hang-time has decreased a lot, from 3min avg to 1.5min.
I was wondering what is the minimum number that it is safe to use? I'm 
sure that you have already dealt with the side-effects/collateral 
damages of this action,  I don't want to fix a problem creating another 
one..

Regarding the modification of the inode.c file, what do you think that 
will be the next step? And how can I apply it to my system? Should I 
modify the file by myself and recompile the kernel to have the changed 
applied?

Thanks a lot,
j
