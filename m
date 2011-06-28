Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:50253 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758781Ab1F1SeS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jun 2011 14:34:18 -0400
Subject: Re: [PATCH 1/1] nfs-utils: Don't hard code source and destination args
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4E0A166B.1000707@debian.org>
Date: Tue, 28 Jun 2011 14:33:56 -0400
Cc: Prem Karat <prem.karat@linux.vnet.ibm.com>, linux-nfs@vger.kernel.org
Message-Id: <CAC69680-53D9-4676-B6CF-7145D17014BE@oracle.com>
References: <20110628104138.GB6600@d6fc318.ibm.com> <FA506314-750E-4E20-B80C-B507D032D962@oracle.com> <20110628165954.GA13059@d6fc318.ibm.com> <42653612-BD54-4049-B8F8-ACDFB6FE6DA3@oracle.com> <4E0A166B.1000707@debian.org>
To: Luk Claes <luk@debian.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jun 28, 2011, at 1:59 PM, Luk Claes wrote:

> On 06/28/2011 07:49 PM, Chuck Lever wrote:
>> 
>> On Jun 28, 2011, at 12:59 PM, Prem Karat wrote:
>> 
>>> On 06/28/11 12:02pm, Chuck Lever wrote:
>>>> 
>>>> On Jun 28, 2011, at 6:41 AM, Prem Karat wrote:
>>>> 
>>>>> 
>>>>> Currently souce and destination parameters should be passed as first and 
>>>>> second paramter while using mount.nfs. This patch allows them to be passed 
>>>>> anywhere while mounting.
>>>>> 
>>>>> Current functionality is
>>>>> 	mount.nfs source destn -o <options>
>>>>> This patch will allow to do this
>>>>> 	mount.nfs -o <options> source destn
>>>>> 		or
>>>>> 	mount.nfs -o <options> source -o <options> destn
>>>> 
>>>> Yep, that's clear, but why is this desirable?  mount.nfs should be invoked only by the mount command.  It's not meant to be run by humans.
>>> Bare with me if my understanding is incorrect, however the man page does say that
>>> it can be used as a standalone command with limited functionality.
>> 
>> Yes, it can be used that way, but it rarely is, and that's by design.
>> 
>>> Also it makes sense to use it if a newbie wants to know the nfs specific
>>> options. The mount.nfs command shows a pointer to the correct man page for
>>> nfs specific options.

The mount(8) man page already has a pointer to nfs(5), it looks like.  IMO mount(8) probably shouldn't even mention mount.nfs.

>> I don't understand.  Why would a "newbie" invoke mount.nfs?  Is there a new use case that requires the additional flexibility?
>> 
>> I don't have a specific objection here, but this seems like an arbitrary change.
> 
> When debugging, it's quite handy that one can switch from mount to
> mount.nfs without having to change the order of the arguments.

Do any of the other mount subcommands (eg. mount.fuse, mount.cifs, mount.tmpfs) need this change too?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




