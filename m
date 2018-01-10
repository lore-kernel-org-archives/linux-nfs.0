Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53120 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751175AbeAJR0L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 10 Jan 2018 12:26:11 -0500
Subject: Re: [PATCH RFC 0/3] Add server-side support for junctions to
 nfs-utils
To: Bruce Fields <bfields@fieldses.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20180108213356.20133.54161.stgit@manet.1015granger.net>
 <20180109192100.GB18087@fieldses.org>
 <492B1883-83EE-40AF-AA8C-1B797D842E5E@oracle.com>
 <01acd06d-98d4-c6ff-5ef1-b6edbb447405@RedHat.com>
 <20180110171704.GB26882@fieldses.org>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <a1d86617-608c-c4bc-6f96-c5deff60c7fb@RedHat.com>
Date: Wed, 10 Jan 2018 12:26:10 -0500
MIME-Version: 1.0
In-Reply-To: <20180110171704.GB26882@fieldses.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/10/2018 12:17 PM, Bruce Fields wrote:
> On Wed, Jan 10, 2018 at 12:13:39PM -0500, Steve Dickson wrote:
>>
>>
>> On 01/09/2018 02:36 PM, Chuck Lever wrote:
>>>
>>>
>>>> On Jan 9, 2018, at 2:21 PM, bfields@fieldses.org wrote:
>>>>
>>>> Thanks for doing this!  I may not get the chance to do a real review,
>>>> but I'm in favor of the basic idea.
>>>
>>> How do you feel about building support for junctions into mountd,
>>> and getting rid of the libnfsjunct DLL ?
>> I would rather not put new functionality in daemons that needs rpcbind.
>> With the idea of, someday, having clean v4-only configuration
>> (aka no mountd, statd, or lockd).  
> 
> rpc.mountd is used by v4 for a lot of stuff already, so it's not going
> away.  
Understood.... I guess I'm looking for a way to replace it with
a command the kernel can call to only do v4 stuff.
Would something like that make sense?

> Is it trying to register with rpcbind in the case it's called
> with -N2 -N3?  That would be a bug.
Looking at the code... probably not... 

steved.
> 
> --b.
> 
