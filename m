Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27460 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760020Ab1F1R3Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jun 2011 13:29:25 -0400
Message-ID: <4E0A0F71.9080207@RedHat.com>
Date: Tue, 28 Jun 2011 13:29:21 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Prem Karat <prem.karat@linux.vnet.ibm.com>
CC: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] nfs-utils: Don't hard code source and destination
 args
References: <20110628104138.GB6600@d6fc318.ibm.com> <FA506314-750E-4E20-B80C-B507D032D962@oracle.com> <20110628165954.GA13059@d6fc318.ibm.com>
In-Reply-To: <20110628165954.GA13059@d6fc318.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 06/28/2011 12:59 PM, Prem Karat wrote:
> On 06/28/11 12:02pm, Chuck Lever wrote:
>>
>> On Jun 28, 2011, at 6:41 AM, Prem Karat wrote:
>>
>>>
>>> Currently souce and destination parameters should be passed as first and 
>>> second paramter while using mount.nfs. This patch allows them to be passed 
>>> anywhere while mounting.
>>>
>>> Current functionality is
>>> 	mount.nfs source destn -o <options>
>>> This patch will allow to do this
>>> 	mount.nfs -o <options> source destn
>>> 		or
>>> 	mount.nfs -o <options> source -o <options> destn
>>
>> Yep, that's clear, but why is this desirable?  mount.nfs should be invoked only by the mount command.  It's not meant to be run by humans.
> Bare with me if my understanding is incorrect, however the man page does say that
> it can be used as a standalone command with limited functionality.
> 
> Also it makes sense to use it if a newbie wants to know the nfs specific
> options. The mount.nfs command shows a pointer to the correct man page for
> nfs specific options.
I agree.... I always thought it as a bit annoying that the command
would only take arguments in an unnatural way...

steved. 
