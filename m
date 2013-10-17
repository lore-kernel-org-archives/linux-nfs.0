Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:52428 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758168Ab3JQSIx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 14:08:53 -0400
Message-ID: <526027B0.5010608@candelatech.com>
Date: Thu, 17 Oct 2013 11:08:48 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: 'umount -f /mnt/foo' fails if server IP is gone.
References: <525D899F.5010604@candelatech.com> <52601FED.6070708@candelatech.com> <758E075A-2DCD-4456-848F-FD983FECF5E5@oracle.com>
In-Reply-To: <758E075A-2DCD-4456-848F-FD983FECF5E5@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/17/2013 11:03 AM, Chuck Lever wrote:
>
> On Oct 17, 2013, at 1:35 PM, Ben Greear <greearb@candelatech.com> wrote:
>
>> On 10/15/2013 11:29 AM, Ben Greear wrote:
>>> Is 'umount -f' supposed to always work, even if the file server
>>> goes away?
>>>
>>> I have a user's system that just hangs forever in this case.
>>>
>>> Could be local changes we have made, but I'm curious about
>>> the expected behaviour before I go digging too deep...
>>
>> Any input on this?  I don't mind trying to fix it, but I
>> would like to know how it is supposed to work.
>
> Recent kernels emit a GETATTR at umount time.  It is probably this operation that is stuck.

It seems a 'mkdir' process is trying to complete at the same time,
not sure if that is cause or effect.

How can I go about cleaning up these stuck operations?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

