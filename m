Return-Path: linux-nfs-owner@vger.kernel.org
Received: from partagas.dragonet.es ([217.70.240.130]:50829 "EHLO
	partagas.dragonet.es" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753809Ab2BBNaA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Feb 2012 08:30:00 -0500
Message-ID: <4F2A8FBC.1010101@steve-ss.com>
Date: Thu, 02 Feb 2012 14:29:32 +0100
From: steve <steve@steve-ss.com>
MIME-Version: 1.0
To: tigran.mkrtchyan@desy.de
CC: linux-nfs@vger.kernel.org
Subject: Re: nfs4 keytabs [was:Re: where can I ask user qns about nfs4]?
References: <4F2A2F9E.6030908@steve-ss.com> <CAGue13owEdBsr+anLKrbW931QZHYC7RbwiSH_7WjBb5aXw4JJQ@mail.gmail.com> <4F2A74A7.4060905@steve-ss.com> <CAGue13p5pQyo7Ny2KPSw3zndF9Rh__W-v0XWKo3DaS2dM6Tn0g@mail.gmail.com>
In-Reply-To: <CAGue13p5pQyo7Ny2KPSw3zndF9Rh__W-v0XWKo3DaS2dM6Tn0g@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/02/2012 02:05 PM, Tigran Mkrtchyan wrote:
> On Thu, Feb 2, 2012 at 12:33 PM, steve<steve@steve-ss.com>  wrote:
>> On 02/02/12 11:58, Tigran Mkrtchyan wrote:
>>> Hi Steve,
>>>
>>>> I already use nfs4 to serve my Linux clients. I'm going to kerberize it.
>>>> My
>>>> clients already have machine and host principals. What else do they need?
>>>>
>>>> 1. nfs/client.domain.name
>>>> 2. nfs/server.domain/name
>>>> 3. neither
>>>> 4. both
>>>>
>>> We run kerberized NFS.
>>>
>>> our keytab contains:
>>>
>>> on server;
>>>    nfs/server.domain
>>>
>>> on client:
>>>    nfs/client.domain
>>>
>>> and, of course, you need a consistent  idmap configuration.
>>>
>>> Tigran.
>>>
>> Hi Tigran
>>
>> That's what we have on our test lan at the moment. I can understand that the
>> server would need the service principal:
>>    nfs/server.domain
>> but not the client, as it's not offering any kerberized service.
> The mount step happens on behalf of host as there are no user requests yet.
> Client host credentials are used at that time.
>
>> As an experiment, I removed the nfs/client.domain from a client keytab,
>> rebooted and remounted the share. We could still access the kerberized nfs
>> share. Maybe there were still some tickets left somewhere? That has me
>> really confused.
> Huh! did you enforce kerberos in /etc/exports?
>
Yes. /etc/exports exports as gss/krb5
I made a screenshot:

http://3.bp.blogspot.com/-g40b11Ys_DA/TypYtlO-ixI/AAAAAAAAAIc/cZdeRhnVuY4/s1600/s4all.png

That's why I'm confused.
Steve



