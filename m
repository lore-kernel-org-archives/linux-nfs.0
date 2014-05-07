Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail2.candelatech.com ([208.74.158.173]:38727 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932916AbaEGNsj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 May 2014 09:48:39 -0400
Message-ID: <536A386E.4070202@candelatech.com>
Date: Wed, 07 May 2014 06:43:10 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Crash in 3.14.0+ (plus hacks)
References: <5346D22A.10102@candelatech.com> <20140425104803.GD22295@fieldses.org> <20140425110409.GA27561@infradead.org> <2191C93E-A3D0-493B-8459-931CE9C59B53@oracle.com>
In-Reply-To: <2191C93E-A3D0-493B-8459-931CE9C59B53@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/25/2014 06:30 AM, Chuck Lever wrote:
> 
> On Apr 25, 2014, at 7:04 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
>> On Fri, Apr 25, 2014 at 06:48:03AM -0400, J. Bruce Fields wrote:
>>> On Thu, Apr 10, 2014 at 10:17:30AM -0700, Ben Greear wrote:
>>>> This could be related to some changes I made to nfs, but in case the
>>>> problem is obvious, here's the stack trace.
>>>
>>> There's also a report here:
>>>
>>> 	https://bugzilla.kernel.org/show_bug.cgi?id=74721
>>>
>>> While I'm travelling, I'm cc'ing Christoph in case this might be a
>>> consequence of his recent ACL cleanup?
>>
>> Chuck already sent a patch in reply to this bug report:
>>
>> 	[PATCH] tmpfs: Fix simple_set_acl()
> 
> FWIW, Ben reports this patch fixes the crash for him.

>From what I can tell, this patch has not yet made it into 3.14 stable.

Probably it should be submitted to stable??

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

